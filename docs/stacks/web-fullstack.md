# Preset: Web fullstack (monolito)

> **El default para productos.** SaaS, marketplaces, herramientas internas, cualquier
> producto con usuarios, datos y vistas. Un solo repo, un solo deploy, máxima velocidad.

## Stack

| Capa               | Elección                                      | Por qué                                                           |
| ------------------ | --------------------------------------------- | ----------------------------------------------------------------- |
| Framework          | Ruby on Rails 8                               | Lo que más dominas; convención sobre configuración; todo incluido |
| Frontend           | Hotwire (Turbo + Stimulus)                    | Interactividad sin SPA; un solo lenguaje mental                   |
| CSS                | Tailwind CSS v4 + DaisyUI v5                  | El sistema de `design/`: tema propio, tokens semánticos           |
| Componentes UI     | DaisyUI + ViewComponent                       | Primitives de Daisy; ViewComponent para componentes propios       |
| Base de datos      | PostgreSQL                                    | Transversal (ver catálogo)                                        |
| Jobs / colas       | Solid Queue                                   | Nativo de Rails 8, sin Redis                                      |
| Cache / websockets | Solid Cache + Solid Cable                     | Nativo de Rails 8, sin Redis                                      |
| Autenticación      | Generador de auth de Rails 8                  | Nativa; Devise solo si necesitas algo que no trae                 |
| Autorización       | Pundit                                        | Policies simples y testeables                                     |
| Panel de admin     | Avo (o Administrate)                          | Admin moderno con poco código                                     |
| Archivos           | ActiveStorage + Cloudflare R2                 | Transversal                                                       |
| Emails             | ActionMailer + Resend                         | Transversal                                                       |
| Pagos              | Paddle (gema `paddle`)                        | Transversal                                                       |
| IA                 | RubyLLM                                       | Capa agnóstica (ver catálogo)                                     |
| Tests              | Minitest (o RSpec si lo prefieres) + Capybara | Lo que trae Rails, sin fricción                                   |
| Lint / formato     | RuboCop (rails-omakase)                       | El estándar de Rails 8                                            |
| Deploy             | Kamal → Hetzner (o Render para validar)       | Escalera de hosting (ver catálogo)                                |
| Monitoreo          | Sentry + Better Stack                         | Transversal                                                       |
| Analytics          | PostHog                                       | Transversal                                                       |

## Cuándo elegirlo

- Casi siempre que haya backend + vistas + usuarios.
- Cuando quieres iterar rápido con una sola persona (+ IA) en el equipo.

## Cuándo NO

- El frontend necesita interactividad extrema (editores, canvas, tiempo real pesado)
  → [`spa-api.md`](spa-api.md).
- No hay vistas, solo endpoints → [`api-service.md`](api-service.md).

## Alternativa principal

- **Next.js fullstack** (App Router + Postgres + Drizzle/Prisma): si el proyecto es
  inherentemente JS (equipo, librerías de UI que necesitas) o quieres desplegar todo
  en Vercel. Pierdes las baterías de Rails (jobs, mailers, admin) y las recompones
  con servicios.

## Costo estimado

- Validación: Render free/starter + Postgres gestionado ≈ 0–15 USD/mes.
- Producción: Hetzner CX22 + R2 + dominios ≈ 8–15 EUR/mes.

## Arranque

```bash
rails new mi-app --css tailwind --database postgresql
bin/rails generate authentication
bundle add avo pundit ruby_llm sentry-ruby sentry-rails
```
