# 06. Atributos de Calidad (ISO/IEC 25010:2023)

Este documento especifica los atributos de calidad (requerimientos no funcionales) para la plataforma **Barrio Conectado**, estructurados según la actualización del estándar **ISO/IEC 25010:2023**.

Las características están priorizadas según el impacto directo en la seguridad de los vecinos y la efectividad en la emisión de alertas comunitarias en tiempo real.

---

## Priorización de Atributos de Calidad

| Prioridad | Atributo (ISO/IEC 25010) | Justificación para Barrio Conectado |
| :---: | :--- | :--- |
| **1** | **Fiabilidad / Confiabilidad (Reliability)** | **Crítico:** La app gestiona emergencias comunitarias. Si el sistema falla o cae en una situación de pánico o delito, la plataforma pierde su valor fundamental. |
| **2** | **Seguridad (Security)** | **Crítico:** Se manejan datos sensibles de geolocalización, identidades de vecinos y alertas de incidentes que no deben filtrarse ni manipularse. |
| **3** | **Capacidad de Interacción / Usabilidad (Interaction Capability)** | **Crítico:** En una emergencia, el usuario necesita emitir una alerta en segundos sin fricción visual o procedimental. |
| **4** | Eficiencia de Desempeño (Performance Efficiency) | Requerido para entregar alertas masivas a vecinos en el sector sin demoras notables. |
| **5** | Adecuación Funcional (Functional Suitability) | Garantiza que las funciones básicas (botón de pánico, mapa de incidentes, contactos de emergencia) cumplan su propósito. |
| **6** | Seguridad Operativa / Protección (Safety) | Evita la emisión de falsas alarmas que puedan poner en riesgo físico o generar pánico innecesario en la comunidad. |
| **7** | Mantenibilidad (Maintainability) | Permite corregir errores rápidamente y mantener el código limpio a medida que la plataforma evoluciona. |
| **8** | Compatibilidad (Compatibility) | Asegura la integración fluida con servicios externos (APIs de mapas, Firebase Cloud Messaging, SMS). |
| **9** | Flexibilidad / Portabilidad (Flexibility) | Garantiza la adaptación de la aplicación a distintas versiones de sistemas operativos móviles (Android/iOS) y tamaños de pantalla. |

---

## Métricas Detalladas para los 3 Atributos Principales

### 1. Fiabilidad (Reliability)

Dada la naturaleza crítica del sistema, **Barrio Conectado** debe permanecer operativo, libre de fallos graves y con capacidad de recuperación ante incidentes de red o servidores.

* **Métrica 1.1 - Disponibilidad del Servicio (Availability):**
  * **Objetivo:** $\ge 99.5\%$ de *uptime* mensual en servicios backend y APIs de alertas.
  * **Medición:** Monitoreo automatizado con herramientas de comprobación de estado (p. ej., Health Check Endpoints) cada 1 minuto.
* **Métrica 1.2 - Tolerancia a Fallos y Redundancia (Fault Tolerance):**
  * **Objetivo:** En caso de caída de la conexión a Internet principal en el dispositivo móvil, la aplicación debe reintentar el envío de la alerta hasta 3 veces automáticamente y ofrecer *fallback* a SMS en un tiempo no mayor a **5 segundos**.
* **Métrica 1.3 - Tiempo Medio de Recuperación (Recoverability - MTTR):**
  * **Objetivo:** Ante un fallo crítico en la base de datos o el servidor, el tiempo promedio de recuperación del servicio debe ser menor a **15 minutos**.

---

### 2. Seguridad (Security)

La protección de los datos de los ciudadanos (ubicación exacta, número telefónico, reportes de delincuencia) es indispensable para prevenir represalias o accesos no autorizados.

* **Métrica 2.1 - Confidencialidad y Cifrado (Confidentiality):**
  * **Objetivo:** $100\%$ del tráfico de datos debe transmitirse cifrado mediante el protocolo **HTTPS (TLS 1.3)**. Las contraseñas y datos sensibles almacenados deben estar protegidos con algoritmos de *hashing* seguros (Argon2 / Bcrypt).
* **Métrica 2.2 - Control de Acceso y Autenticación (Integrity / Authenticity):**
  * **Objetivo:** $0\%$ de solicitudes aceptadas sin un token JWT válido de sesión activa.
  * **Medición:** Pruebas automatizadas de seguridad e intentos de inyección/bypassing en las rutas de la API.
* **Métrica 2.3 - Vulnerabilidades de Código:**
  * **Objetivo:** Cero (0) vulnerabilidades de prioridad Alta o Crítica detectadas en escaneos SAST/DAST (p. ej., OWASP Top 10) antes de cada despliegue en producción.

---

### 3. Capacidad de Interacción / Usabilidad (Interaction Capability)

Durante un evento de delincuencia o emergencia médica, la velocidad y sencillez de uso de la interfaz reducen el estrés del usuario y aceleran el envío de ayuda.

* **Métrica 3.1 - Operabilidad bajo Emergencia (Operability / Simplicity):**
  * **Objetivo:** Un usuario autenticado debe ser capaz de emitir la alerta principal de pánico en **máximo 2 toques** (pantalla principal $\rightarrow$ presionar botón de pánico $\rightarrow$ confirmación).
  * **Tiempo objetivo de interacción:** $\le 3\text{ segundos}$ desde que abre la aplicación.
* **Métrica 3.2 - Facilidad de Aprendizaje (Learnability):**
  * **Objetivo:** El $90\%$ de los usuarios nuevos del sector barrial deben ser capaces de enviar un reporte de prueba o alerta correctamente en su primer intento sin requerir manual de usuario.
* **Métrica 3.3 - Inclusividad y Accesibilidad (Inclusivity / Accessibility):**
  * **Objetivo:** Cumplir con el nivel **AA de las pautas WCAG 2.1** (radio de contraste $\ge 4.5:1$ en texto/iconos principales y tamaños de botón táctil mínimos de $48\times48\text{ dp}$ para adultos mayores).

---

## Definición General de las Características Restantes

* **4. Eficiencia de Desempeño:**
  * Las notificaciones push de alerta deben ser entregadas a los vecinos del sector dentro de un margen máximo de **3 segundos** desde su emisión.
* **5. Adecuación Funcional:**
  * Cobertura del $100\%$ de las funcionalidades declaradas en los requerimientos funcionales (mapa en vivo, catálogo de alertas, contactos de emergencia).
* **6. Seguridad Operativa (Safety):**
  * Mecanismo de re-confirmación táctil (presión sostenida de 1.5 segundos) o cancelación dentro de los primeros 5 segundos para evitar falsas alarmas accidentales.
* **7. Mantenibilidad:**
  * Estructura modular (Clean Architecture / MVC) con una cobertura de pruebas unitarias superior al **70%** en componentes de la lógica de negocio.
* **8. Compatibilidad:**
  * Interoperabilidad fluida mediante API REST / JSON con plataformas externas (Firebase Messaging, servicios de geolocalización de Google Maps).
* **9. Flexibilidad:**
  * Interfaz responsive adaptada a pantallas móviles desde $4.7''$ en adelante y compatible con versiones de Android 8.0+ / iOS 13+.
