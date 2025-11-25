#!/bin/bash
set -e

echo "=== Greengrass Setup and Start ==="

cleanup() {
    echo "Cleaning up..."
    pkill -f "java.*Greengrass" || true
}
trap cleanup EXIT

# Verificar se já está instalado
if [ -f "/greengrass/v2/lib/Greengrass.jar" ] && [ -f "/greengrass/v2/config/config.yaml" ]; then
    echo "Greengrass already installed, starting..."
    cd /greengrass/v2
    exec su ggc_user -s /bin/bash -c "
        cd /greengrass/v2 && \
        exec java -Xmx512m -Djava.awt.headless=true \
        -Droot='/greengrass/v2' \
        -Dlog.store=FILE \
        -jar /greengrass/v2/lib/Greengrass.jar \
        --start
    "
fi

echo "Installing Greengrass..."
cd /tmp

# Extrair nucleus
if [ ! -d "GreengrassInstaller" ]; then
    echo "Extracting nucleus..."
    unzip -q greengrass-nucleus-latest.zip -d GreengrassInstaller
fi

# Criar diretório de configuração
mkdir -p /greengrass/v2/config

# Extrair connection kit
if [ ! -f "/greengrass/v2/config/config.yaml" ]; then
    echo "Extracting connection kit..."
    # Extrair para um diretório temporário primeiro
    mkdir -p /tmp/connection-kit
    unzip -q MeuCoreWSLDockerV2-connectionKit.zip -d /tmp/connection-kit
    
    # Listar conteúdo para debug
    echo "Connection kit contents:"
    find /tmp/connection-kit -type f
    
    # Copiar arquivos para o local correto
    if [ -f "/tmp/connection-kit/config.yaml" ]; then
        cp /tmp/connection-kit/config.yaml /greengrass/v2/config/
    fi
    
    # Copiar certificados
    find /tmp/connection-kit -name "*.pem*" -exec cp {} /greengrass/v2/config/ \;
    find /tmp/connection-kit -name "*.key*" -exec cp {} /greengrass/v2/config/ \;
    find /tmp/connection-kit -name "*.crt*" -exec cp {} /greengrass/v2/config/ \;
    
    # Se config.yaml não existir no root, procurar em subdiretórios
    if [ ! -f "/greengrass/v2/config/config.yaml" ]; then
        config_file=$(find /tmp/connection-kit -name "config.yaml" -type f | head -1)
        if [ -n "$config_file" ]; then
            cp "$config_file" /greengrass/v2/config/
        fi
    fi
    
    # Verificar se temos o config.yaml
    if [ ! -f "/greengrass/v2/config/config.yaml" ]; then
        echo "ERROR: config.yaml not found in connection kit!"
        echo "Contents of connection kit:"
        find /tmp/connection-kit -type f
        exit 1
    fi
    
    # Substituir placeholders no config.yaml
    sed -i 's|{{config_dir}}|/greengrass/v2/config|g' /greengrass/v2/config/config.yaml
    sed -i 's|{{nucleus_component}}|aws.greengrass.Nucleus|g' /greengrass/v2/config/config.yaml
fi

# Verificar arquivos necessários
echo "Checking configuration files..."
ls -la /greengrass/v2/config/

# Definir permissões
chown -R ggc_user:ggc_group /greengrass
chmod -R 755 /greengrass
chmod 600 /greengrass/v2/config/*.key* 2>/dev/null || true
chmod 644 /greengrass/v2/config/*.pem* 2>/dev/null || true
chmod 644 /greengrass/v2/config/*.crt* 2>/dev/null || true

echo "Running Greengrass installation..."
timeout 600 java -Droot="/greengrass/v2" \
    -Dlog.store=FILE \
    -Djava.awt.headless=true \
    -Dlogging.level.com.aws.greengrass=DEBUG \
    -jar ./GreengrassInstaller/lib/Greengrass.jar \
    --init-config /greengrass/v2/config/config.yaml \
    --component-default-user ggc_user:ggc_group \
    --setup-system-service false \
    --deploy-dev-tools false \
    --provision false || {
    echo "Installation failed, checking contents..."
    ls -la /greengrass/v2/
    ls -la /greengrass/v2/config/
    cat /greengrass/v2/config/config.yaml 2>/dev/null || echo "No config.yaml found"
    exit 1
}

echo "Starting Greengrass Nucleus..."
cd /greengrass/v2
exec su ggc_user -s /bin/bash -c "
    cd /greengrass/v2 && \
    exec java -Xmx512m -Djava.awt.headless=true \
    -Droot='/greengrass/v2' \
    -Dlog.store=FILE \
    -jar /greengrass/v2/lib/Greengrass.jar \
    --start
"
