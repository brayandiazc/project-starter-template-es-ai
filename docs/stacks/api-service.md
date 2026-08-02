# Preset: API / servicio backend

> Solo endpoints: la API de un producto, un backend para móvil, un servicio que
> consumen terceros. Sin vistas.

## La decisión clave: Rails API vs FastAPI

| Usa…              | Cuando…                                                                                                                       |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Rails `--api`** | La API es lógica de negocio/CRUD, ya tienes (o tendrás) un monolito Rails, o simplemente quieres velocidad con lo que dominas |
| **FastAPI**       | El servicio es intensivo en IA/ML o datos (el ecosistema Python manda), o necesitas async/streaming de forma natural          |

En caso de duda: Rails. Cambiar después es posible; perder semanas en un stack que
dominas menos, no se recupera.

## Stack (Rails API)

| Capa          | Elección                                      | Por qué                                    |
| ------------- | --------------------------------------------- | ------------------------------------------ |
| Framework     | Rails 8 `--api`                               | Sin capa de vistas, todo lo demás igual    |
| Serialización | Jbuilder o `oj` + POROs                       | Simple; evita capas de serializers pesadas |
| Auth          | Tokens (generador Rails 8 + API keys propias) | Según consumidor                           |
| Docs API      | rswag (OpenAPI desde los tests)               | El contrato vive con las pruebas           |
| Jobs          | Solid Queue                                   | Nativo                                     |
| IA            | RubyLLM                                       | Capa agnóstica                             |

## Stack (FastAPI)

| Capa        | Elección                   | Por qué                                  |
| ----------- | -------------------------- | ---------------------------------------- |
| Framework   | FastAPI + Pydantic v2      | Tipado, validación y docs OpenAPI gratis |
| ORM         | SQLModel o SQLAlchemy 2    | SQLModel si el modelo es simple          |
| Migraciones | Alembic                    | Estándar                                 |
| Auth        | fastapi-users o JWT propio | Según consumidor                         |
| Jobs        | Dramatiq o arq             | Ligeros; Celery solo si ya lo conoces    |
| IA          | LiteLLM / Pydantic AI      | Capa agnóstica                           |
| Gestor      | uv                         | Rápido, lockfile, reemplaza pip/poetry   |
| Lint        | Ruff                       | Lint + formato en una herramienta        |

## Común a ambos

- Postgres, Sentry, Better Stack, GitHub Actions: ver [`README.md`](README.md).
- **Versiona la API desde el día 1** (`/v1/...`) y documenta el contrato en
  [`../architecture/api.md`](../architecture/api.md).
- Dockerfile desde el inicio; deploy Render → Hetzner (Kamal o Coolify).
- Rate limiting en el borde (Cloudflare) antes que en la app.

## Costo estimado

- Render starter ≈ 7–15 USD/mes; Hetzner ≈ 5–10 EUR/mes.

## Arranque

```bash
# Rails
rails new mi-api --api --database postgresql

# FastAPI
uv init mi-api && cd mi-api && uv add "fastapi[standard]" sqlmodel alembic
```
