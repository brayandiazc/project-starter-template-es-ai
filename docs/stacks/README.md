# Catálogo de stacks

> Decisiones tecnológicas **pre-tomadas** por tipo de proyecto. Al iniciar un proyecto,
> elige un preset, cópialo a [`../architecture/stack.md`](../architecture/stack.md) y
> desvíate solo con una razón escrita (idealmente un ADR).
> La skill `/arrancar-proyecto` (vía su paso de instanciación) usa este catálogo en su entrevista.

## Filosofía

- **Velocidad primero**: el objetivo es sacar el mejor producto en el menor tiempo
  posible, usando IA para el desarrollo. El stack que ya dominas gana sobre el stack
  "ideal".
- **Rails como columna vertebral**: para productos con backend, el default es Ruby on
  Rails (monolito majestuoso). Las alternativas existen para casos donde Rails no es
  la mejor herramienta, no como opciones equivalentes.
- **IA agnóstica**: todo uso de IA en los productos pasa por una capa adaptadora para
  que cambiar de proveedor no duela (ver Servicios transversales).
- **Empieza en PaaS, migra a VPS**: valida en una plataforma gestionada; cuando el
  costo lo justifique, migra a Hetzner. Containeriza desde el día 1 para que esa
  migración sea barata.
- **La idea manda sobre el catálogo**: si un proyecto concreto avanza más rápido con
  una tecnología que no está aquí (o que no dominas — para eso está la IA como par de
  desarrollo), úsala y registra la desviación como ADR. El catálogo es el default,
  no una jaula.

## Cómo elegir preset

| Vas a construir…                                            | Preset                                             | Default                 |
| ----------------------------------------------------------- | -------------------------------------------------- | ----------------------- |
| Un producto/SaaS con backend, vistas y usuarios             | [`web-fullstack.md`](web-fullstack.md)             | Rails 8 + Hotwire       |
| Un frontend muy interactivo con API separada                | [`spa-api.md`](spa-api.md)                         | Next.js + Rails API     |
| Solo una API o servicio backend                             | [`api-service.md`](api-service.md)                 | Rails API o FastAPI     |
| Una app móvil                                               | [`mobile.md`](mobile.md)                           | Flutter                 |
| Una landing, blog, docs o web de contenido                  | [`web-estatica.md`](web-estatica.md)               | Astro                   |
| Una app instalable sin pasar por stores                     | [`pwa.md`](pwa.md)                                 | Vite + React + PWA      |
| Una extensión de navegador                                  | [`extension-navegador.md`](extension-navegador.md) | WXT + React             |
| Una CLI o herramienta interna (genera archivos, automatiza) | [`cli-herramientas.md`](cli-herramientas.md)       | Python + Typer + uv     |
| Microservicios                                              | [`microservicios.md`](microservicios.md)           | ⚠️ Lee primero el aviso |

> ¿Duda entre dos presets? Elige el más simple. Un monolito Rails cubre el 80% de los
> productos; separar front/API o irse a microservicios se decide después, con evidencia.

## Servicios transversales — decide una vez

Estos servicios son los mismos en todos los presets. Se eligen una sola vez y solo se
cambian con un ADR.

| Categoría               | Default                                     | Por qué                                                                   | Alternativa                                        |
| ----------------------- | ------------------------------------------- | ------------------------------------------------------------------------- | -------------------------------------------------- |
| Base de datos           | PostgreSQL                                  | Sólida, universal, sirve para todo (JSON, full-text, colas)               | SQLite (proyectos pequeños/1 VPS)                  |
| Pagos                   | Paddle                                      | Merchant of record: gestiona impuestos globales por ti                    | Stripe (más control), Lemon Squeezy                |
| Email transaccional     | Resend                                      | DX excelente, plantillas en código, buen free tier                        | Postmark, Amazon SES (volumen)                     |
| Autenticación           | La nativa del framework                     | Rails 8 trae generador de auth; menos dependencias                        | Devise (Rails), Clerk/Auth.js (JS), Supabase Auth  |
| Login social            | Google OAuth (una sola red en v1)           | La que más convierte; omniauth-google-oauth2 (Rails) / Auth.js / Supabase | Apple (obligatorio en iOS si ofreces login social) |
| Almacenamiento archivos | Cloudflare R2 (S3-compatible)               | Sin costo de egreso, compatible con ActiveStorage/SDK S3                  | Backblaze B2, S3                                   |
| Analytics de producto   | PostHog                                     | Analytics + feature flags + session replay, free tier generoso            | Plausible (solo métricas web)                      |
| Errores y monitoreo     | Sentry                                      | Multi-plataforma (Rails, JS, Flutter, Python)                             | Honeybadger (Ruby)                                 |
| Uptime y logs           | Better Stack                                | Uptime + logs + alertas en un solo lugar, free tier                       | UptimeRobot (solo uptime)                          |
| CI/CD                   | GitHub Actions                              | Ya vives en GitHub; workflows de esta plantilla listos                    | —                                                  |
| Dominios                | Namecheap (compra) + Cloudflare (DNS/proxy) | Compra barata; gestión, CDN y seguridad en Cloudflare                     | Cloudflare Registrar (renovación a costo)          |
| Credenciales            | Bitwarden                                   | Ver sección Credenciales                                                  | —                                                  |
| Backups                 | Dump diario de Postgres → R2                | Automatizable con cron/Kamal; prueba el restore cada mes                  | Snapshots del VPS (Hetzner)                        |

### Hosting: la escalera

1. **Validación (día 0)** — PaaS: Render, Railway o Fly.io. Deploy en minutos, base de
   datos gestionada, cero ops. Costo: ~0–20 USD/mes.
2. **Producto con tracción** — VPS en Hetzner + [Kamal](https://kamal-deploy.org)
   (nativo de Rails) o [Coolify](https://coolify.io) (cualquier contenedor).
   Costo: ~5–20 EUR/mes por mucho más máquina.
3. **Estáticos siempre gratis** — Cloudflare Pages para landings, docs y frontends
   estáticos, sin importar dónde viva el backend.

Regla: containeriza (Dockerfile) desde el día 1 aunque despliegues en PaaS — la
migración a Hetzner se vuelve un cambio de destino, no una reescritura.

### Capa de IA (agnóstica al proveedor)

Los productos usan IA a través de una **capa adaptadora**, nunca llamando al SDK del
proveedor directamente desde la lógica de negocio:

| Lenguaje | Librería adaptadora                         | Nota                                            |
| -------- | ------------------------------------------- | ----------------------------------------------- |
| Ruby     | [RubyLLM](https://rubyllm.com)              | Una API para Anthropic, OpenAI, Gemini, etc.    |
| Python   | [LiteLLM](https://litellm.ai) o Pydantic AI | LiteLLM para llamadas; Pydantic AI para agentes |
| JS/TS    | [Vercel AI SDK](https://sdk.vercel.ai)      | Proveedores intercambiables por config          |

Convenciones:

- **Proveedor por defecto**: Anthropic (Claude); el modelo se elige por tarea, no se
  hardcodea el más caro en todo.
- **Config por entorno**: `AI_PROVIDER`, `AI_MODEL` y `AI_API_KEY` en `.env` — cambiar
  de proveedor es cambiar tres variables.
- **Prompts versionados**: los prompts viven en archivos del repo (no strings inline),
  para poder revisarlos y testearlos.
- Registra en un ADR cualquier funcionalidad que dependa de una capacidad exclusiva de
  un proveedor (esa sí duele migrarla).

### Credenciales y secretos (Bitwarden en el centro)

| Contexto                     | Cómo                                                                                                               |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Humanos (logins, API keys)   | Bóveda de **Bitwarden** — una carpeta/colección por proyecto                                                       |
| Desarrollo local             | `.env` **generado** desde Bitwarden (`bw get` / `bws run`), nunca commiteado; `.env.example` documenta el contrato |
| CI (GitHub Actions)          | GitHub Secrets, sincronizados a mano o con **Bitwarden Secrets Manager** (`bws`)                                   |
| Producción (Kamal / PaaS)    | `.kamal/secrets` leyendo de `bws` (Kamal lo soporta nativo) o el panel de secrets del PaaS                         |
| CLIs y herramientas internas | `bw get`/`bws` al vuelo o `.env` local en `~/.config/<tool>/`                                                      |

Reglas: los guardrails de la plantilla ya bloquean commitear `.env` reales; rota
cualquier secreto expuesto; cada secreto vive en UN lugar canónico (Bitwarden) y los
demás son copias regenerables.

### Integraciones, APIs y MCPs

- **APIs de terceros siempre detrás de un adaptador** propio (`app/services/`,
  `lib/clients/`): la lógica de negocio no conoce al proveedor — mismo principio que
  la capa de IA.
- **MCPs en desarrollo**: conecta los servidores MCP de tus servicios (GitHub,
  Sentry, PostHog, Stripe/Paddle cuando existan) en `.mcp.json` para que los agentes
  operen esas herramientas directamente. `.mcp.json.example` documenta los del
  proyecto; las credenciales que necesiten salen de Bitwarden, no del archivo.
- **Webhooks entrantes**: verifica firma siempre, y registra el contrato en
  `docs/architecture/api.md`.

## Checklist de arranque (todo preset)

- [ ] Copiar el preset elegido a `docs/architecture/stack.md` y anotar desviaciones.
- [ ] Dominio + DNS en Cloudflare; SSL activo.
- [ ] `.env.example` actualizado con las variables del preset (incluidas las de IA).
- [ ] Sentry y analytics conectados antes del primer usuario real.
- [ ] Backups configurados y **restore probado** antes de tener datos que duelan.
- [ ] Identidad visual base aplicada desde [`../../design/`](../../design/README.md)
      (modo claro y oscuro desde el inicio).
- [ ] i18n configurado con es + en neutro; sin cadenas hardcodeadas (`/i18n-parity`).
- [ ] Legal si es público: adaptar los documentos base de [`../../legal/`](../../legal/README.md).
- [ ] Repositorio configurado con `/configurar-repo` (descripción, labels, ramas, protección).

## Mantener este catálogo

Este catálogo es un documento vivo: cuando una elección cambie (nuevo proveedor de
pagos, otro hosting), actualiza el preset y registra el porqué como ADR en
[`../decisions/`](../decisions/README.md).
