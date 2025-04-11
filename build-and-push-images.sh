#!/bin/bash

# Skript zum Bauen und Pushen aller Docker-Images für die GitHub Container Registry

# Konfiguration
REGISTRY="ghcr.io/mistral-valaise"
TAG="latest"

# Farben für bessere Lesbarkeit
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== SRETodo: Bauen und Pushen aller Docker-Images für GHCR ===${NC}"

# Login-Aufforderung anzeigen (statt zu prüfen und zu beenden)
echo -e "${GREEN}Es wird empfohlen, bei GitHub Container Registry angemeldet zu sein:${NC}"
echo -e "${GREEN}docker login ghcr.io -u mistral-valaise${NC}"
echo -e "${GREEN}Drücke Enter, um fortzufahren...${NC}"
read -p ""

# 1. Frontend Service
echo -e "${GREEN}Baue Frontend Service...${NC}"
cd /Users/mistralnembot/ai-projects/sretodo/sretodo/frontend-angular
docker build -t ${REGISTRY}/sretodo-frontend:${TAG} .
docker push ${REGISTRY}/sretodo-frontend:${TAG}
echo -e "${GREEN}Frontend Service wurde erfolgreich gebaut und gepusht.${NC}\n"

# 2. Java Todo Service
echo -e "${GREEN}Baue Java Todo Service...${NC}"
cd /Users/mistralnembot/ai-projects/sretodo/sretodo/service-java-todo
docker build -t ${REGISTRY}/sretodo-java-todo:${TAG} .
docker push ${REGISTRY}/sretodo-java-todo:${TAG}
echo -e "${GREEN}Java Todo Service wurde erfolgreich gebaut und gepusht.${NC}\n"

# 3. .NET Statistik Service
echo -e "${GREEN}Baue .NET Statistik Service...${NC}"
cd /Users/mistralnembot/ai-projects/sretodo/sretodo/service-dotnet-statistik
docker build -t ${REGISTRY}/sretodo-dotnet-statistik:${TAG} .
docker push ${REGISTRY}/sretodo-dotnet-statistik:${TAG}
echo -e "${GREEN}.NET Statistik Service wurde erfolgreich gebaut und gepusht.${NC}\n"

# 4. Python Pomodoro Service
echo -e "${GREEN}Baue Python Pomodoro Service...${NC}"
cd /Users/mistralnembot/ai-projects/sretodo/sretodo/service-python-pomodoro
docker build -t ${REGISTRY}/sretodo-python-pomodoro:${TAG} .
docker push ${REGISTRY}/sretodo-python-pomodoro:${TAG}
echo -e "${GREEN}Python Pomodoro Service wurde erfolgreich gebaut und gepusht.${NC}\n"

echo -e "${BLUE}=== Alle Images wurden erfolgreich gebaut und in die GitHub Container Registry gepusht ===${NC}"
echo -e "${BLUE}Sie können jetzt Helm erneut ausführen, um die Anwendung in OpenShift zu deployen:${NC}"
echo -e "${GREEN}helm upgrade --install sretodo-release ./kubernetes${NC}"