#!/bin/bash

# Skript zum Bauen der Images und direkten Import in OpenShift (ohne GHCR)

# Farben für bessere Lesbarkeit
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== SRETodo: Bauen und Importieren der Images in OpenShift ===${NC}"

PROJECT_NS="valaise16-dev"  # Dein OpenShift Namespace/Projekt
REGISTRY="default-route-openshift-image-registry.apps.sandbox-m2.ll9k.p1.openshiftapps.com"

# 1. Frontend Service
echo -e "${GREEN}Baue Frontend Service...${NC}"
cd /Users/mistralnembot/ai-projects/sretodo/sretodo/frontend-angular
docker build -t sretodo-frontend:latest .
echo -e "${GREEN}Tagge Frontend Image für OpenShift Registry...${NC}"
docker tag sretodo-frontend:latest ${REGISTRY}/${PROJECT_NS}/sretodo-frontend:latest
echo -e "${GREEN}Pushe Frontend Image in OpenShift Registry...${NC}"
docker push ${REGISTRY}/${PROJECT_NS}/sretodo-frontend:latest
echo -e "${GREEN}Frontend Service wurde erfolgreich gebaut und gepusht.${NC}\n"

# 2. Java Todo Service
echo -e "${GREEN}Baue Java Todo Service...${NC}"
cd /Users/mistralnembot/ai-projects/sretodo/sretodo/service-java-todo
docker build -t sretodo-java-todo:latest .
echo -e "${GREEN}Tagge Java Todo Image für OpenShift Registry...${NC}"
docker tag sretodo-java-todo:latest ${REGISTRY}/${PROJECT_NS}/sretodo-java-todo:latest
echo -e "${GREEN}Pushe Java Todo Image in OpenShift Registry...${NC}"
docker push ${REGISTRY}/${PROJECT_NS}/sretodo-java-todo:latest
echo -e "${GREEN}Java Todo Service wurde erfolgreich gebaut und gepusht.${NC}\n"

# 3. .NET Statistik Service
echo -e "${GREEN}Baue .NET Statistik Service...${NC}"
cd /Users/mistralnembot/ai-projects/sretodo/sretodo/service-dotnet-statistik
docker build -t sretodo-dotnet-statistik:latest .
echo -e "${GREEN}Tagge .NET Statistik Image für OpenShift Registry...${NC}"
docker tag sretodo-dotnet-statistik:latest ${REGISTRY}/${PROJECT_NS}/sretodo-dotnet-statistik:latest
echo -e "${GREEN}Pushe .NET Statistik Image in OpenShift Registry...${NC}"
docker push ${REGISTRY}/${PROJECT_NS}/sretodo-dotnet-statistik:latest
echo -e "${GREEN}.NET Statistik Service wurde erfolgreich gebaut und gepusht.${NC}\n"

# 4. Python Pomodoro Service
echo -e "${GREEN}Baue Python Pomodoro Service...${NC}"
cd /Users/mistralnembot/ai-projects/sretodo/sretodo/service-python-pomodoro
docker build -t sretodo-python-pomodoro:latest .
echo -e "${GREEN}Tagge Python Pomodoro Image für OpenShift Registry...${NC}"
docker tag sretodo-python-pomodoro:latest ${REGISTRY}/${PROJECT_NS}/sretodo-python-pomodoro:latest
echo -e "${GREEN}Pushe Python Pomodoro Image in OpenShift Registry...${NC}"
docker push ${REGISTRY}/${PROJECT_NS}/sretodo-python-pomodoro:latest
echo -e "${GREEN}Python Pomodoro Service wurde erfolgreich gebaut und gepusht.${NC}\n"

echo -e "${BLUE}=== Alle Images wurden erfolgreich gebaut und in OpenShift Registry gepusht ===${NC}"

# Jetzt aktualisiere die values.yaml, um die ImageStreams zu verwenden
echo -e "${GREEN}Aktualisiere Helm values.yaml, um OpenShift Registry zu verwenden...${NC}"
cat > /Users/mistralnembot/ai-projects/sretodo/sretodo/kubernetes/values.yaml << EOF
# Default values for SRE Todo Helm chart

# Global settings
global:
  image:
    tag: latest # Default tag for application images
    pullPolicy: Always
  repositoryPrefix: ${REGISTRY}/${PROJECT_NS}

# Frontend Configuration
frontend:
  enabled: true
  replicas: 1
  # Image name suffix, prefix is global
  imageName: sretodo-frontend
  # Tag kommt nun aus global
  tag: latest
  # tag and pullPolicy come from global
  service:
    type: ClusterIP
    port: 8080 # Port changed for OpenShift compatibility
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 50m
      memory: 64Mi

# Java Todo Service
javaTodo:
  enabled: true
  replicas: 1
  # Image name suffix
  imageName: sretodo-java-todo
  # Tag kommt nun aus global
  tag: latest
  # tag and pullPolicy come from global
  service:
    type: ClusterIP
    port: 8080 # Standard Spring Boot port
  resources:
    limits:
      cpu: "1" # Changed to string
      memory: 1Gi
    requests:
      cpu: 100m
      memory: 128Mi

# .NET Statistik Service
dotnetStatistik:
  enabled: true
  replicas: 1
  # Image name suffix
  imageName: sretodo-dotnet-statistik
  # Tag kommt nun aus global
  tag: latest
  # tag and pullPolicy come from global
  service:
    type: ClusterIP
    port: 8080 # Port changed for OpenShift compatibility
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi

# Python Pomodoro Service
pythonPomodoro:
  enabled: true
  replicas: 1
  # Image name suffix
  imageName: sretodo-python-pomodoro
  # Tag kommt nun aus global
  tag: latest
  # tag and pullPolicy come from global
  service:
    type: ClusterIP
    port: 8002 # Example port for Python service
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi

# PostgreSQL Database
postgres:
  enabled: true
  replicas: 1
  # Keeping specific image for postgres
  image: postgres
  tag: "16-alpine" # Updated to 16
  pullPolicy: IfNotPresent
  service:
    type: ClusterIP
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi
  persistence:
    enabled: false # Disabled for simpler deployment, consider enabling for state
    size: 1Gi
  env:
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres # Consider using secrets
    POSTGRES_DB: sretodo

# Observability Stack - Keeping specific images/tags here
observabilityStack:
  enabled: true

  # OpenTelemetry Collector
  otelCollector:
    image: otel/opentelemetry-collector-contrib
    tag: 0.103.1 # Using a specific version
    pullPolicy: Always

  # Prometheus
  prometheus:
    image: prom/prometheus
    tag: v2.53.1 # Using a specific version
    pullPolicy: Always

  # Tempo
  tempo:
    image: grafana/tempo
    tag: 2.7.1 # Keeping specific version from techContext
    pullPolicy: Always

  # Loki
  loki:
    image: grafana/loki
    tag: 3.1.0 # Using a specific version
    pullPolicy: Always

  # Grafana
  grafana:
    image: grafana/grafana
    tag: 11.1.0 # Keeping specific version from techContext
    pullPolicy: Always

# NGINX Gateway
nginxGateway:
  enabled: true
  replicas: 1
  image: nginx
  tag: "1.27.0-alpine" # Using a specific alpine version
  pullPolicy: IfNotPresent
  service:
    type: ClusterIP
    port: 8080 # Port changed for OpenShift compatibility
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 50m
      memory: 64Mi
EOF

echo -e "${BLUE}Die Helm-Werte wurden aktualisiert, um die OpenShift Registry zu verwenden.${NC}"
echo -e "${BLUE}Bevor du Helm ausführst, stelle sicher, dass du bei der OpenShift Registry angemeldet bist:${NC}"
echo -e "${GREEN}oc registry login${NC}"
echo -e "${BLUE}Danach kannst du Helm erneut ausführen, um die Anwendung in OpenShift zu deployen:${NC}"
echo -e "${GREEN}helm upgrade --install sretodo-release ./kubernetes${NC}"