# Preset: Microservicios

> ⚠️ **Lee esto primero.** Para un equipo de una persona (aunque trabaje con IA),
> los microservicios casi siempre son la decisión equivocada: multiplican deploys,
> observabilidad, contratos y modos de fallo, y no aceleran nada hasta que hay varios
> equipos pisándose. **El default de esta plantilla es el monolito majestuoso**
> ([`web-fullstack.md`](web-fullstack.md)) con módulos bien separados por dominio.

## Cuándo sí se justifica extraer un servicio

Extrae (no empieces con) un servicio cuando un componente concreto:

- Tiene un **perfil de escala distinto** al resto (p. ej. procesamiento de IA/media
  que necesita GPU o colas enormes).
- Necesita **otro runtime** con ventaja real (Python para ML dentro de un producto Rails).
- Debe **fallar aislado** (un scraper inestable que no puede tumbar el producto).

Una regla honesta: si no puedes nombrar el problema medido que el servicio resuelve,
todavía no lo necesitas.

## Stack (cuando llegue el momento)

| Capa            | Elección                                            | Por qué                                             |
| --------------- | --------------------------------------------------- | --------------------------------------------------- |
| Servicios       | FastAPI (Python) o Go                               | Ligeros; Rails se queda como núcleo de negocio      |
| Contratos       | OpenAPI por servicio, versionados en el repo        | El contrato es la frontera; se revisa en PR         |
| Comunicación    | HTTP síncrono + NATS (o Redis Streams) para eventos | Empieza simple; NATS cuando haya eventos reales     |
| Orquestación    | Docker Compose → un solo nodo con Coolify/Kamal     | Kubernetes solo con equipo/escala que lo pague      |
| Gateway / borde | Cloudflare + un reverse proxy (Traefik/Caddy)       | TLS y ruteo sin drama                               |
| Observabilidad  | OpenTelemetry + Sentry + Better Stack               | Sin trazas distribuidas, depurar es adivinar        |
| Datos           | **Una base por servicio** (Postgres)                | Compartir DB entre servicios = monolito distribuido |

## Reglas del preset

- Máximo **un servicio nuevo a la vez**, extraído del monolito con su contrato escrito
  antes que su código (usa [`../../specs/`](../../specs/README.md)).
- Cada extracción se registra como ADR: qué problema medido resuelve y qué señal la
  revertiría.
- CI y deploy por servicio desde el día 1 de ese servicio.

## Costo estimado

- Mínimo realista: 2–3 nodos Hetzner + observabilidad ≈ 30–60 EUR/mes, más tu tiempo
  de operación — el costo real está ahí.
