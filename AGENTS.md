<!--
  Instrucciones canónicas para agentes de [NOMBRE_DEL_PROYECTO].
  Esta es la única fuente de verdad para los agentes de codificación con IA (Claude Code, Copilot,
  Cursor, etc.). CLAUDE.md importa este archivo. Manténlo conciso (<150 líneas) e
  incluye solo guía no evidente y específica del proyecto — las personas leen el README.
-->

# AGENTS.md — [NOMBRE_DEL_PROYECTO]

Instrucciones para los agentes de codificación con IA que trabajan en este repositorio.

## Resumen del proyecto

[Una o dos líneas sobre qué es y qué hace este proyecto.] La documentación completa vive
en [`docs/`](docs/README.md) — léela antes de un trabajo no trivial.

## Mapa del repositorio (lee esto primero)

| Necesitas saber…                  | Lee                                                                      |
| --------------------------------- | ------------------------------------------------------------------------ |
| Cómo está construido el sistema   | [`docs/architecture/architecture.md`](docs/architecture/architecture.md) |
| Stack y versiones                 | [`docs/architecture/stack.md`](docs/architecture/stack.md)               |
| Modelo de datos                   | [`docs/architecture/database.md`](docs/architecture/database.md)         |
| Autenticación y permisos          | [`docs/architecture/auth.md`](docs/architecture/auth.md)                 |
| Contrato de la API                | [`docs/architecture/api.md`](docs/architecture/api.md)                   |
| Cómo escribimos código            | [`docs/conventions/`](docs/conventions/README.md)                        |
| Por qué se tomaron las decisiones | [`docs/decisions/`](docs/decisions/README.md)                            |

> Remítete siempre a `docs/conventions/` para el estilo y las reglas — son la fuente
> de verdad, no tus suposiciones previas.

## Configuración y comandos

```bash
[COMANDO_INSTALAR_DEPENDENCIAS]   # instalar dependencias
[COMANDO_INICIAR_DESARROLLO]              # ejecutar localmente
[COMANDO_TEST]                   # ejecutar la suite de pruebas
[COMANDO_LINT]                   # lint / formato
```

## Acuerdo de trabajo

- **Planifica antes de cambios grandes.** Para trabajo no trivial, redacta una especificación
  ligera en [`specs/`](specs/README.md) (o delega en el subagente `architect`).
- **Sigue Git Flow.** Crea ramas desde `develop` como `feat/…`, `fix/…`, etc. Consulta
  [`CONTRIBUTING.md`](CONTRIBUTING.md). Nunca hagas commit directamente a `main`.
- **Conventional Commits.** `type(scope): summary`. Añade la línea de coautoría de IA
  para los commits asistidos por IA (consulta [`docs/conventions/ai-agents.md`](docs/conventions/ai-agents.md)).
- **Issues y PRs con plantilla.** Al crear un issue o un pull request, usa SIEMPRE las
  plantillas de [`.github/`](.github) (`ISSUE_TEMPLATE/` y `PULL_REQUEST_TEMPLATE.md`) y
  respeta el branching de [`CONTRIBUTING.md`](CONTRIBUTING.md). Las skills `/open-issue` y
  `/open-pr` lo hacen por ti.
- **Pruebas con cada cambio.** Sigue [`docs/conventions/testing.md`](docs/conventions/testing.md).
- **"Terminado" tiene definición.** Antes de dar un cambio por hecho, repasa
  [`docs/conventions/definition-of-done.md`](docs/conventions/definition-of-done.md).
- **Mantén la documentación sincronizada.** Actualiza los `docs/` correspondientes y `CHANGELOG.md`; registra
  las decisiones notables como un ADR en `docs/decisions/`.

## Reglas estrictas — nunca hagas esto

- Nunca hagas commit de secretos ni de valores reales de `.env`. Consulta [`SECURITY.md`](SECURITY.md)
  y [`docs/conventions/secrets.md`](docs/conventions/secrets.md).
- Nunca inventes dependencias, archivos ni APIs — verifica primero que existen.
- Nunca eludas las comprobaciones de autorización ni debilites la seguridad para que algo funcione.
- Nunca hagas push a `main` ni force-push a ramas compartidas.
- No reformatees código no relacionado ni hagas cambios masivos fuera de la tarea.

## Asistentes de IA y herramientas

- Este archivo es el contexto canónico. Los archivos específicos de cada herramienta (`CLAUDE.md`, etc.)
  apuntan aquí.
- Los subagentes reutilizables viven en [`.claude/agents/`](.claude/agents) y las skills en
  [`.claude/skills/`](.claude/skills) — son **ejemplos**; adáptalos o elimínalos
  según el proyecto.
- Reglas para trabajar con IA: [`docs/conventions/ai-agents.md`](docs/conventions/ai-agents.md).
