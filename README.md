# Barrio Conectado — Sistema de Alerta y Coordinación Vecinal

**Barrio Conectado** es una plataforma de gestión comunitaria orientada a fortalecer la seguridad de los vecindarios mediante la emisión, recepción y seguimiento de problema de infraestructura y alertas en tiempo real. El proyecto busca canalizar y procesar la solicitud directa a la municipalidad de reparaciones, además de notificar incidentes (robos, emergencias médicas, etc.) y coordinar la respuesta rápida entre vecinos, administradores de cuadrante y entidades de apoyo.

---

## Descripción del Proyecto

El sistema combina el uso de servicios de geolocalización, notificaciones *push* de alta prioridad y mapas interactivos para ofrecer un canal directo de comunicación comunitaria. Su diseño prioriza la **simplicidad táctil**, la **fiabilidad del canal de notificaciones** y el **resguardo de los datos sensibles** de los ciudadanos.

### Características Principales
* **Emisión de reportes comunitarios y reclamos** en menos de 2 toques.
* **Geolocalización en tiempo real** para la delimitación espacial de incidentes por cuadrante o barrio.
* **Gestión de roles:** Vecinos, Moderadores de Barrio y Administradores.
* **Seguridad y privacidad:** Cifrado de extremo a extremo en tráfico de información de los usuarios y reportes.

---

## Índice de Documentación del Proyecto

A continuación se presenta la documentación técnica estructurada del proyecto, ordenada según las fases de ingeniería de software y arquitectura:

| # | Documento | 
| :-: | :--- |
| **01** | [01-proceso-as-is.md](./01-proceso-as-is.md) |
| **02** | [02-rediseno-to-be.md](./02-rediseno-to-be.md) | 
| **03** | [03-requisitos.md](./03-requisitos.md) | 
| **04** | [04-historias-usuario.md](./04-historias-usuario.md) |
| **05** | [05-elicitacion.md](./05-elicitacion.md) | 
| **06** | [06-atributos-calidad.md](./06-atributos-calidad.md) | 

---

## Atributos de Calidad Destacados (ISO/IEC 25010)

El proyecto se rige por tres pilares de calidad fundamentales especificados detalladamente en el archivo [06-atributos-calidad.md](./06-atributos-calidad.md):

1. **Fiabilidad (Reliability):** Disponibilidad mínima del **99.5%** en servicios críticos de alerta.
2. **Seguridad (Security):** Transmisión $100\%$ cifrada en **TLS 1.3** y autenticación por tokens JWT.
3. **Capacidad de Interacción (Usability):** Emisión de alerta principal en **$\le 2$ toques** y cumplimiento del estándar **WCAG 2.1 AA**.

---

## Stack Tecnológico Sugerido

* **Frontend / Mobile:** Flutter / React Native / Android Native.
* **Backend:** Node.js (Express / NestJS) o Python (FastAPI).
* **Base de Datos:** PostgreSQL con extensión PostGIS para datos geográficos.
* **Servicios en la Nube:** Firebase Cloud Messaging (FCM) para notificaciones en tiempo real, Docker para contenedorización.

---

## Instalación y Configuración Local

1. **Clonar el repositorio:**
   ```bash
   git clone [https://github.com/bruhmzk/Barrio-Conectado.git](https://github.com/bruhmzk/Barrio-Conectado.git)
   cd Barrio-Conectado
