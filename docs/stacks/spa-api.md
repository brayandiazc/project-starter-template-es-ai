# Preset: SPA + API

> Frontend muy interactivo servido aparte, hablando con una API propia. Dos piezas,
> dos deploys — elígelo solo cuando la interactividad lo justifique.

## Stack

### Frontend

| Capa            | Elección                                          | Por qué                                                       |
| --------------- | ------------------------------------------------- | ------------------------------------------------------------- |
| Framework       | Next.js (App Router) o Vite + React               | Next si hay SEO/SSR; Vite si es app 100% privada              |
| CSS             | Tailwind CSS v4 + DaisyUI v5                      | El sistema de `design/`: mismo tema en todo                   |
| Componentes UI  | DaisyUI; shadcn/ui solo para primitives complejos | Combobox/date-picker que Daisy no trae, con los mismos tokens |
| Estado servidor | TanStack Query                                    | Cache y sincronización con la API sin boilerplate             |
| Formularios     | React Hook Form + Zod                             | Validación tipada compartible con la API                      |
| Deploy          | Vercel (Next) o Cloudflare Pages (Vite)           | Cero ops en el frontend                                       |

### Backend (API)

| Capa      | Elección                                   | Por qué                                    |
| --------- | ------------------------------------------ | ------------------------------------------ |
| Framework | Rails `--api` (default) o FastAPI          | Ver [`api-service.md`](api-service.md)     |
| Auth      | Sesión con cookie (mismo dominio) o tokens | Cookies si puedes; tokens si multi-cliente |
| Deploy    | Render → Hetzner                           | Escalera de hosting                        |

Servicios transversales (Postgres, Paddle, Resend, Sentry, PostHog, IA…): ver
[`README.md`](README.md).

## Cuándo elegirlo

- Editores, dashboards densos, drag & drop, colaboración en tiempo real.
- La API además sirve a otros clientes (app móvil, terceros).
- Equipos/agentes separados trabajando front y back en paralelo.

## Cuándo NO

- Es un CRUD con formularios y listados → [`web-fullstack.md`](web-fullstack.md)
  con Hotwire lo resuelve con la mitad de piezas.

## Trampas conocidas

- **CORS y auth**: sirve front y API bajo el mismo dominio raíz
  (`app.midominio.com` + `api.midominio.com`) y usa cookies `SameSite` — te ahorras
  media categoría de bugs.
- **Dos deploys = dos pipelines**: duplica CI, variables de entorno y monitoreo desde
  el día 1, no cuando se rompa.

## Costo estimado

- Vercel/Pages free + API en Render ≈ 0–15 USD/mes; luego Hetzner ≈ 8–15 EUR/mes.

## Arranque

```bash
npx create-next-app@latest mi-front --tailwind --ts --app
npx shadcn@latest init
rails new mi-api --api --database postgresql
```
