# SRE Todo Kubernetes Helm Chart

Dieses Helm Chart ermöglicht die Bereitstellung der SRE Todo-Anwendung mit OpenTelemetry-Observability in einem Kubernetes- oder OpenShift-Cluster.

## Voraussetzungen

- Kubernetes 1.19+ oder OpenShift 4.x+
- Helm 3.2.0+

## Erste Schritte

### Installation

1. **Repository klonen**
   ```bash
   git clone https://github.com/your-organization/sretodo.git # Durch Ihre Repository-URL ersetzen
   cd sretodo/kubernetes
   ```

2. **(Bei Verwendung einer privaten Registry wie GHCR) Image Pull Secret erstellen**
   Stellen Sie sicher, dass Sie in Ihrem Ziel-Namespace ein Secret erstellt haben, das das Abrufen von Images aus Ihrer privaten Container-Registry (z.B. `ghcr.io`) ermöglicht. Der standardmäßig vom Chart erwartete Secret-Name ist `ghcr-secret` (konfigurierbar über `global.image.pullSecret` in `values.yaml`).
   ```bash
   # Beispiel für GHCR
   kubectl create secret docker-registry ghcr-secret \
     --namespace=<ihr-namespace> \
     --docker-server=ghcr.io \
     --docker-username=<ihr-github-benutzername> \
     --docker-password=<ihr-github-pat> \
     --docker-email=<ihre-email>
   ```
   Möglicherweise müssen Sie dieses Secret auch mit dem Standard-Serviceaccount verknüpfen, wenn Ihre Pods diesen verwenden:
   ```bash
   kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name":"ghcr-secret"}]}' -n <ihr-namespace>
   ```

3. **Anpassen von `values.yaml` (Wichtig!)**
   - Überprüfen Sie `kubernetes/values.yaml`.
   - **Es ist entscheidend, das `tag`-Feld für jeden Anwendungsservice (`frontend`, `javaTodo`, `dotnetStatistik`, `pythonPomodoro`) auf einen gültigen, in Ihrer Registry vorhandenen Image-Tag zu setzen.** Die Verwendung von `latest` könnte fehlschlagen, wenn der Tag nicht existiert oder aufgrund von Caching.
   - Passen Sie andere Werte wie Replicas, Ressourcen oder aktivierte Komponenten nach Bedarf an.

4. **Helm Chart installieren**
   Stellen Sie das Chart mit Helm bereit und geben Sie Ihren Ziel-Namespace an:
   ```bash
   helm upgrade --install sretodo-release . -n <ihr-namespace>
   ```
   *(Die Verwendung von `upgrade --install` ist im Allgemeinen sicherer als nur `install`)*

Um Überschreibungen ohne Bearbeitung von `values.yaml` bereitzustellen:

```bash
helm upgrade --install sretodo-release . -n <ihr-namespace> --set frontend.replicas=2 --set javaTodo.tag=specific-tag-123
```

### Bereitstellung auf OpenShift

Das Helm Chart wurde für die OpenShift-Bereitstellung optimiert:

1. Alle Container sind so konfiguriert, dass sie als Nicht-Root-Benutzer ausgeführt werden
2. Frontend und NGINX-Gateway verwenden Port 8080 statt Port 80
3. SecurityContext ist eingestellt, um ordnungsgemäße Berechtigungen zu gewährleisten
4. Die Container verwenden einen uid-Bereich, der für OpenShift geeignet ist (1006530000)

Um auf OpenShift bereitzustellen:

```bash
helm install sretodo . -f values.yaml
```

## Architektur

Die SRE Todo-Anwendung besteht aus folgenden Komponenten:

- **Frontend**: Auf Angular basierende Weboberfläche, die aus der CI/CD-Pipeline erstellt wird
- **Java Todo Service**: Backend-Service zur Verwaltung von Todos
- **PostgreSQL**: Datenbank zum Speichern von Todos
- **NGINX Gateway**: API-Gateway für Frontend und Services
- **Observability Stack**:
  - OpenTelemetry Collector
  - Prometheus
  - Tempo
  - Loki
  - Grafana

## Konfiguration

### Globale Einstellungen (`global`-Block in `values.yaml`)
- `global.image.tag`: Standard-Image-Tag (obwohl jetzt servicespezifische Tags bevorzugt werden).
- `global.image.pullPolicy`: Standard-Pull-Policy (z.B. `Always`, `IfNotPresent`).
- `global.image.pullSecret`: Name des Kubernetes-Secrets zum Abrufen privater Images.
- `global.repositoryPrefix`: Die Basis-URL Ihrer Container-Registry (z.B. `ghcr.io/my-org`).

### Aktivieren/Deaktivieren von Komponenten

Jede Komponente kann über das `enabled`-Flag in der `values.yaml`-Datei aktiviert oder deaktiviert werden. Zum Beispiel:

```yaml
frontend:
  enabled: true

javaTodo:
  enabled: true

dotnetStatistik:
  enabled: false

pythonPomodoro:
  enabled: false
```

### Komponentenkonfiguration

Jede Komponente ermöglicht die Konfiguration von:

- `imageName`: Der spezifische Name des Images (Suffix nach dem globalen Präfix).
- `tag`: **(Wichtig)** Der spezifische Image-Tag, der für diesen Service bereitgestellt werden soll. Muss in der Registry existieren.
- Anzahl der Replicas
- Ressourcenlimits und -anforderungen
- Service-Typ
- Umgebungsvariablen (wo zutreffend)

Siehe die `values.yaml`-Datei für alle verfügbaren Konfigurationsoptionen.

## Sicherheit

Alle Komponenten sind so konfiguriert, dass sie als Nicht-Root-Benutzer mit den minimal erforderlichen Berechtigungen ausgeführt werden:

- `securityContext.runAsUser`: 1006530000 (OpenShift-kompatibler Benutzer)
- `securityContext.runAsGroup`: 0
- `securityContext.fsGroup`: 1006530000 (für Volume-Berechtigungen)

## Observability

Der Observability-Stack ist standardmäßig aktiviert und umfasst:

- **OpenTelemetry Collector**: Sammelt Metriken, Traces und Logs
- **Prometheus**: Speichert und fragt Metriken ab
- **Tempo**: Speichert und fragt Traces ab
- **Loki**: Speichert und fragt Logs ab
- **Grafana**: Bietet Dashboards zur Visualisierung aller Telemetriedaten

Zugriff auf das Grafana-Dashboard unter `http://<cluster-ip>:<port>/grafana` (IP mit `kubectl get svc` abrufen).

## Fehlerbehebung

Bei Problemen mit der Bereitstellung:

1. Status der Pods überprüfen:
```bash
kubectl get pods
```

2. Logs eines bestimmten Pods überprüfen:
```bash
kubectl logs <pod-name>
```

3. Wenn ein Pod nicht startet, beschreiben Sie ihn für weitere Details:
```bash
kubectl describe pod <pod-name>
```

- **ImagePullBackOff / ErrImagePull / manifest unknown:**
  - Überprüfen Sie, ob der in `values.yaml` angegebene `tag` für den fehlerhaften Service in Ihrer Registry (`ghcr.io/...`) existiert.
  - Prüfen Sie, ob die `imagePullSecrets` (`ghcr-secret` standardmäßig) im Namespace existieren.
  - Stellen Sie sicher, dass das Secret gültige Anmeldeinformationen (korrekter Benutzername, PAT mit `read:packages`-Scope) für `ghcr.io` enthält.
  - Bestätigen Sie, dass das Secret mit dem `default`-Serviceaccount verknüpft ist (`kubectl get sa default -o yaml`).
- **Gateway Timeout (504):**
  - Überprüfen Sie, ob der Ziel-Pod (z.B. Frontend, Java-Todo) läuft (`kubectl get pods`).
  - Überprüfen Sie, ob der Ziel-Service korrekt konfiguriert ist (Ports stimmen überein, Selektor entspricht Pod-Labels) (`kubectl get svc <service-name> -o yaml`).
  - Untersuchen Sie die Logs des Nginx-Gateways (`kubectl logs <nginx-gateway-pod>`).
  - Untersuchen Sie die Logs des Ziel-Pods (`kubectl logs <target-pod>`).
- **Frontend zeigt statische HTML-Seite:**
  - Überprüfen Sie, ob die ConfigMap in `frontend-deployment.yaml` entfernt wurde, die eine statische HTML-Seite anstelle der Angular-Anwendung bereitstellt.

## CI/CD mit GitHub Actions

Die Bereitstellung auf einem Kubernetes/OpenShift-Cluster wird automatisch durch einen GitHub Actions Workflow (`.github/workflows/deploy.yaml`) gesteuert. Bei jedem Push auf die Branches `main` oder `dev`:

1. Werden die Docker-Images für alle Services gebaut.
2. Werden die Images in die GitHub Container Registry (ghcr.io) gepusht.
3. Wird das Helm-Chart mit `helm upgrade --install` auf dem Zielcluster (konfiguriert über Secrets `OPENSHIFT_SERVER`, `OPENSHIFT_TOKEN`, `OPENSHIFT_NAMESPACE`) angewendet, wobei die neu gebauten Image-Tags verwendet werden.

Der Workflow unterstützt auch einen "deploy-only" Modus, der Konfigurationsänderungen ohne den Neubau von Images ermöglicht.

### Entfernen der Bereitstellung

Zum Entfernen der Anwendung von OpenShift gibt es zwei Möglichkeiten:

1. **Workflow "destroy.yaml" ausführen**:
   - Gehe zu "Actions" > "Destroy SRE ToDo Demo from OpenShift"
   - Klicke auf "Run workflow"
   - Wähle die Umgebung und gib optional den Release-Namen an
   - Klicke auf "Run workflow"

2. **Deploy-Workflow mit "destroy" Option ausführen**:
   - Gehe zu "Actions" > "Deploy SRE ToDo Demo to OpenShift"
   - Klicke auf "Run workflow"
   - Wähle "destroy" als Action
   - Klicke auf "Run workflow"

Beide Methoden entfernen das Helm-Release und bereinigen die zugehörigen Ressourcen im OpenShift-Cluster.

## Deinstallation

```bash
helm uninstall sretodo-release -n sretodo-demo
kubectl delete namespace sretodo-demo # (Optional)
```

## Aktuelle Herausforderungen / TODOs

- Grafana Dashboards anpassen/erstellen, da sie derzeit "No Data" anzeigen.
- Ressourcenlimits/-requests basierend auf dem tatsächlichen Verbrauch in OpenShift optimieren.
- Health Checks (Liveness/Readiness Probes) für alle Komponenten überprüfen und ggf. verbessern.
- Frontend-ConfigMap entfernen, um die korrekte Angular-Anwendung anstelle der statischen HTML-Seite anzuzeigen.