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

| Necesitas saber…                        | Lee                                                                        |
| --------------------------------------- | -------------------------------------------------------------------------- |
| Cómo está construido el sistema         | [`docs/architecture/architecture.md`](docs/architecture/architecture.md)   |
| Stack y versiones                       | [`docs/architecture/stack.md`](docs/architecture/stack.md)                 |
| Qué stack elegir por tipo de proyecto   | [`docs/stacks/`](docs/stacks/README.md)                                    |
| Qué es el producto y su alcance (v1)    | [`docs/product/product-definition.md`](docs/product/product-definition.md) |
| Identidad visual y tokens por defecto   | [`design/`](design/README.md)                                              |
| Marco legal base (términos, privacidad) | [`legal/`](legal/README.md)                                                |
| Modelo de datos                         | [`docs/architecture/database.md`](docs/architecture/database.md)           |
| Autenticación y permisos                | [`docs/architecture/auth.md`](docs/architecture/auth.md)                   |
| Contrato de la API                      | [`docs/architecture/api.md`](docs/architecture/api.md)                     |
| Cómo escribimos código                  | [`docs/conventions/`](docs/conventions/README.md)                          |
| Por qué se tomaron las decisiones       | [`docs/decisions/`](docs/decisions/README.md)                              |

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

- **Acompaña activamente.** Pregunta ante ambigüedad de alcance o prioridad en vez de
  asumir; sugiere lo que la persona no pidió pero necesitará. La prioridad la marca
  [`docs/product/product-definition.md`](docs/product/product-definition.md) — lo que
  no está en la v1 no se implementa sin pasar por el subagente `product-coach`.
  El ciclo completo está en [`docs/conventions/workflow.md`](docs/conventions/workflow.md).
- **Sin spec no hay cambio (obligatorio).** Toda funcionalidad o corrección
  (`feat/*`, `fix/*`) nace de una spec en [`specs/`](specs/README.md) con el mismo
  slug que la rama (créala con `/new-spec` o delega en el subagente `architect`).
  El hook `spec-guardrails.sh` lo garantiza: sin spec, no se puede editar código.
- **Sigue Git Flow.** Las ramas de trabajo (`feat/…`, `fix/…`, `docs/…`, `chore/…`)
  nacen SIEMPRE de `develop`, nunca de `main` (solo `hotfix/*` parte de `main`). Si
  `develop` no existe, créala desde `main` y publícala antes de cualquier trabajo.
  Consulta [`CONTRIBUTING.md`](CONTRIBUTING.md). Nunca hagas commit directamente a
  `main` ni a `develop`. El hook `git-guardrails.sh` bloquea las violaciones.
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

- Nunca dejes un cambio sin documentar: todo cambio actualiza `CHANGELOG.md` y los
  `docs/` afectados en el mismo PR; toda decisión notable deja un ADR. Un cambio sin
  documentación no está terminado.
- Nunca hagas commit de secretos ni de valores reales de `.env`. Consulta [`SECURITY.md`](SECURITY.md)
  y [`docs/conventions/secrets.md`](docs/conventions/secrets.md).
- Nunca inventes dependencias, archivos ni APIs — verifica primero que existen.
- Nunca edites código en una rama `feat/*`/`fix/*` sin su spec en `specs/`, ni crees
  ramas de trabajo desde `main` — esas dos reglas las bloquean los hooks.
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
