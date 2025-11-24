# AWS Greengrass V2 Edge AI: Car Counter on Docker

Este repositório contém uma implementação completa de um dispositivo **Edge AI** utilizando **AWS Greengrass V2** provisionado via **Docker** em ambiente **WSL2 (Ubuntu)**.

O projeto inclui a infraestrutura como código (Dockerfile) e um componente customizado de **Visão Computacional** capaz de detectar e contar veículos em tempo real e enviar telemetria para a nuvem.

## 🚀 Principais Tecnologias
*   **Infrastructure:** AWS Greengrass V2, Docker, WSL2 (Ubuntu 22.04).
*   **Edge AI:** Python 3.8+, YOLOv5 (Ultralytics), OpenCV.
*   **Cloud & IoT:** AWS IoT Core (MQTT), AWS S3 (Artifacts), Greengrass IPC.

## 🎯 Funcionalidades
*   🐳 **Containerização:** Setup automático do ambiente Greengrass com todas as dependências de ML pré-instaladas.
*   🚗 **Detecção de Objetos:** Componente `CarCounter` capaz de identificar carros, motos, ônibus e caminhões.
*   ☁️ **Integração Cloud:** Publicação automática da contagem e links de imagens anotadas via MQTT para o AWS IoT Core.
*   🔒 **Segurança:** Estrutura pronta para injeção segura de certificados (não inclusos no repo).
