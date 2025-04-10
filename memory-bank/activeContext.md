# Active Context: Observability MVP Demo App

## Aktueller Fokus

Der Fokus liegt auf der Stabilisierung und Verfeinerung des OpenShift-Deployments via Helm. Nachdem die Probleme mit Image Pulls und der Erreichbarkeit des Frontends behoben wurden, sind die nächsten Schritte die Untersuchung der Grafana Dashboards und die Optimierung der Ressourcenkonfiguration.

## 2. Recent Activities

-   Basislogik für ToDo, Pomodoro, Statistik und Healthcheck implementiert.
-   Frontend zeigt Daten an und erlaubt Interaktion (ToDo Add/Delete/Toggle, Pomodoro Start/Stop).
-   **Nginx Gateway:** Implementiert als zentraler Einstiegspunkt (Port 80), leitet API- und Frontend-Anfragen weiter.
-   **CORS:** Probleme durch Gateway gelöst, Konfigurationen in Backends entfernt.
-   **Troubleshooting:** Diverse Start- und Konfigurationsprobleme mit Docker Compose, Nginx Volumes und Service-Timing behoben.
-   Frontend mit Countdown-Timer für Pomodoro erweitert.
-   **Helm Charts:** Erstellt für Kubernetes/OpenShift-Deployment mit allen Komponenten.
-   **OpenShift-Kompatibilität:** Implementiert durch Anpassungen für Non-Root-Ausführung und Port-Änderungen.
-   **GitHub Actions:** Workflow zur automatisierten Bereitstellung auf OpenShift eingerichtet, inkl. "deploy-only" Option.
-   **OpenShift Deployment Troubleshooting:** Probleme mit Image Pull, Gateway Timeout und Service Routing behoben.
-   **Dokumentation:** READMEs für Hauptprojekt, Kubernetes und Frontend aktualisiert mit OpenShift-spezifischen Informationen.

## 3. Next Steps

1.  ~~**Create Dockerfile for `service-java-todo`~~ **(Done)**
2.  ~~**Create Dockerfile for `service-dotnet-statistik`~~ **(Done)**
3.  ~~**Create Dockerfile for `service-python-pomodoro`~~ **(Done)**
4.  ~~**Create Dockerfile for `service-go-healthcheck`~~ **(Done)**
5.  ~~**Create Dockerfile for `frontend-angular`~~ **(Done)**
6.  ~~**Verify Docker Compose Build:**~~ **(Done)**
7.  ~~**Verify Docker Compose Up:**~~ **(Done)**
8.  ~~**Verify Telemetry:**~~ **(Done)**
9.  ~~**Update Memory Bank & Commit:**~~ **(Done)**
10. ~~**Implement Basic Logic (ToDo):**~~ **(Done)**
11. ~~**Implement Basic Logic (Pomodoro):**~~ **(Done)**
12. ~~**Implement Basic Logic (Statistik):**~~ **(Done)**
13. ~~**Implement Basic Logic (Healthcheck):**~~ **(Done)**
14. ~~**Implement Basic Logic (Frontend):**~~ **(Done - Anzeige, Add/Delete/Toggle, Pomodoro)**
15. ~~**Update Memory Bank & Commit (Pomodoro):**~~ **(Done)**
16. ~~**Update Memory Bank & Commit (Statistik):**~~ **(Done)**
17. ~~**Update Memory Bank & Commit (Healthcheck):**~~ **(Done)**
18. ~~**Update Memory Bank & Commit (Gateway & Frontend):**~~ **(Done)**
19. ~~**Define & Implement Next Feature/Refinement:**~~ **(Done - Grafana Dashboards erstellt, cAdvisor hinzugefügt)**
20. ~~**Dokumentieren & Committen:**~~ **(Done)**
21. ~~**Fehlerbehebung / Nächster Schritt:**~~ **(Nächstes Feature ausgewählt: ToDo Edit + Refactoring)**
22. ~~**Implementieren & Testen:** ToDo Edit + Refactoring~~ **(Done)**
23. ~~**Dokumentieren & Committen:**~~ **(Done)**
24. ~~**Nächster Schritt auswählen:**~~ **(Frontend Routing ausgewählt)**
25. ~~**Implementieren & Testen:** Angular Routing~~ **(Done)**
26. ~~**Dokumentieren & Committen:**~~ **(Done)**
27. ~~**Nächster Schritt auswählen:**~~ **(Frontend OTel ausgewählt)**
28. ~~**Implementieren & Testen:** OpenTelemetry im Frontend~~ **(Done)**
29. ~~**Dokumentieren & Committen:**~~ **(Done)**
30. ~~**Nächster Schritt auswählen:**~~ **(OpenShift-Kompatibilität ausgewählt)**
31. ~~**Helm-Charts für Kubernetes/OpenShift erstellen**~~ **(Done)**
32. ~~**OpenShift-Kompatibilität implementieren**~~ **(Done)**
33. ~~**GitHub Actions Workflow erstellen**~~ **(Done)**
34. ~~**GitHub Actions Workflow verbessern (deploy-only Option)**~~ **(Done)**
35. ~~**OpenShift Deployment Troubleshooting (Image Pull, Gateway Timeout, Service Routing)**~~ **(Done)**
36. ~~**Dokumentieren & Committen:** Aktuellen Stand dokumentieren und committen.~~ **(Done)**
37. **Frontend-Fix:** ConfigMap-Mount aus frontend-deployment.yaml entfernen und mit deploy-only bereitstellen.
38. **Grafana Dashboards:** Untersuchen und korrigieren, warum Dashboards keine Daten anzeigen.
39. **Ressourcen-Optimierung:** Limits/Requests für Kubernetes-Deployments überprüfen und anpassen.
40. **Dokumentation vervollständigen:** READMEs für Services und Helm-Chart aktualisieren.

## 4. Open Questions / Decisions

-   Optimale Werte für Ressourcenlimits und -requests in OpenShift.
-   Spezifische Abfragen/Metriken für funktionierende Grafana-Dashboards.

## 5. Blockers

-   Grafana Dashboards zeigen "No Data". (Zu untersuchen)
-   Frontend in OpenShift zeigt statische HTML-Seite statt Angular-App (durch ConfigMap-Mount verursacht).

## Current Work Focus

- Beheben des Frontend-Problems in OpenShift, um die korrekte Angular-Anwendung anstelle der statischen HTML-Seite anzuzeigen.
- Untersuchung der Grafana-Dashboards und Behebung des "No Data"-Problems.
- Optimierung der Ressourcenkonfiguration in OpenShift.

## Recent Changes

- **Dokumentation aktualisiert:** Die READMEs für das Hauptprojekt, Kubernetes und Frontend wurden mit OpenShift-spezifischen Informationen, bekannten Problemen und Fehlerbehebungstipps aktualisiert.

- **Helm Chart Refactoring:** Die `values.yaml` wurde überarbeitet, um globale Einstellungen für Image-Repository, Pull Policy und Pull Secret zu verwenden. Die Deployment-Templates wurden angepasst, um diese globalen Werte sowie service-spezifische Image-Tags korrekt zu referenzieren.

- **Image Pull Secrets:** Konfiguration im Helm-Chart implementiert, um ein definiertes Secret (`ghcr-secret`) zum Pullen von Images aus privaten Registries (GHCR) zu verwenden.

- **.NET Service Fix:** Korrektur der Umgebungsvariablen (`TODO_SERVICE_HOST`, `TODO_SERVICE_PORT`) im Deployment, damit der Statistik-Service den Java-Service finden kann.

- **Nginx Gateway Fixes:** 
    - Korrektur des `proxy_pass`-Pfades für den Java-Service (Entfernen des trailing slash).
    - Korrektur des Frontend-Service-Ports in der Gateway-Konfiguration (von 80 auf 8080).

- **Frontend Service Fix:** Korrektur des Service-Ports in der Frontend-Service-Definition von 80 auf 8080, um mit dem Gateway und dem Pod übereinzustimmen.

- **Troubleshooting (OpenShift):** Mehrere Runden der Fehlersuche und Korrektur von YAML-Syntaxfehlern und Konfigurationsproblemen im Helm-Chart, die zu ImagePullBackOff und Gateway Timeouts führten.

## Next Steps (Priorisiert)

1. **Frontend-Fix:**
   - Entfernen der ConfigMap-Mount aus dem frontend-deployment.yaml
   - Bereitstellen mit dem "deploy-only"-Workflow, um die Angular-Anwendung anzuzeigen

2. **Grafana-Dashboards:**
   - Untersuchen, warum Dashboards "No Data" anzeigen
   - Erstellen/Anpassen von Basis-Dashboards für die Überwachung der Services in OpenShift

3. **Ressourcen-Optimierung:**
   - Feinabstimmung der Ressourcenlimits/-requests für bessere Performance

4. **Dokumentation:**
   - Aktualisieren der READMEs für die restlichen Services

## Offene Fragen / Entscheidungen

- Optimale Werte für Ressourcenlimits und -requests in OpenShift
- Benötigte Grafana-Dashboards für die Überwachung der SRE Todo App in OpenShift
- Mögliche Ursachen für "No Data" in Grafana-Dashboards (Metrics-Namen, Labels oder Exporter-Konfiguration)

## Bekannte Probleme / Herausforderungen

- Frontend in OpenShift zeigt statische HTML-Seite statt Angular-App (Verursacht durch ConfigMap-Mount)
- Grafana Dashboards zeigen "No Data" aufgrund von Metrik-Namen/Label-Inkompatibilitäten
- Gelegentliche Verzögerungen bei der ersten Anfrage an den Python Pomodoro Service (Cold Start)

## Erkenntnisse

- In OpenShift müssen Container als Non-Root-Benutzer ausgeführt werden
- Web-Services sollten Port 8080 statt Port 80 verwenden, um keine Root-Rechte zu benötigen
- GitHub Actions Workflows können effizienter gestaltet werden, indem bedingte Builds und eine "deploy-only"-Option implementiert werden
- Die Kombination von Helm und OpenShift erfordert besondere Beachtung bei SecurityContext-Einstellungen
- Der Einsatz eines API-Gateways (Nginx) vereinfacht die Frontend-Backend-Kommunikation und löst CORS-Probleme