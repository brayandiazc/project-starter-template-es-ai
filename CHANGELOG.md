# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

Este es el CHANGELOG del repo-plantilla [brayandiazc/project-starter-template-es-ai](https://github.com/brayandiazc/project-starter-template-es-ai).
Al instanciar se resetea: tu proyecto hereda las herramientas de la
plantilla, no su vida (ver `TEMPLATE-USAGE.md`).

## [Unreleased]

### Added

- **`check-labels.sh` — que las labels de `LABELS.md` existan de verdad en el
  repositorio.** `LABELS.md` es la fuente única y `setup-labels.sh` las crea a partir de
  sus tablas, pero crearlas es un paso **manual**, una vez por repositorio, y nada
  comprobaba que se hubiera dado. Los cinco repos de esta familia tenían solo las labels
  por defecto de GitHub: ninguna de las once declaradas existía.

  No es cosmético. `dependabot.yml` declara `sin-changelog` en sus PRs para que el job
  del changelog los deje pasar — sin la label creada, Dependabot no puede aplicarla, el
  gate los tumba igual, y **el arreglo parece hecho porque el archivo dice lo correcto**.
  La vía de escape manual tampoco servía: no puedes ponerle a un PR una label que no
  existe.

### Fixed

- **`template-update-check.yml` reventaba con un `git clone` críptico** cuando el
  repositorio de origen ya no resolvía. Un repo se renombra y el `repo=` de
  `.template-origin` se queda atrás: GitHub redirige un tiempo, pero si alguien reclama el
  nombre viejo deja de resolver. Ahora avisa de que quizá se renombró y dice qué archivo
  tocar.

## [2.2.0] - 2026-09-07

### Fixed

- **Dependabot no podía pasar el gate del CHANGELOG.** El job `changelog` exige entrada a
  todo PR que toque el proyecto; el bot toca el manifiesto y el lockfile, no escribe
  changelogs y no puede aprenderlo. Sus PRs morían con el build y los escaneos en verde.
  La excepción ya estaba diseñada —la label `sin-changelog`—, solo que nada se la ponía:
  ahora nacen con ella.
- **La vía de escape solo servía puesta antes de abrir el PR.** `PR_LABELS` sale del
  payload del evento, así que poner `sin-changelog` a mano no disparaba nada y un re-run
  replicaba el payload viejo, sin la label — justo al revés de cuando descubres que la
  necesitas. `quality.yml` escucha ahora `labeled` y `unlabeled`. Cuesta un run por cada
  cambio de label; una salida de emergencia inutilizable en la emergencia cuesta más.

### Changed

- **Los PRs de Dependabot van agrupados**, uno con todos los bumps en vez de uno por
  paquete. Fusionar N bumps sueltos en cadena deja un lockfile que nadie compiló: git no
  marca conflicto —cada bump toca un sitio distinto del archivo— y el CI tampoco lo ve,
  porque cada PR se construye sobre su propia rama y nunca sobre el resultado de
  fusionarlos todos. El precio, escrito al lado en `dependabot.yml`: si un bump del grupo
  rompe, se bloquea el grupo entero.

## [2.1.0] - 2026-09-07

### Added

- **`check-git-flow.sh` — que `develop` exista en el remoto.** `CONTRIBUTING.md` manda
  que toda rama de trabajo nazca de `develop` y `AGENTS.md` lo repite; nada lo
  comprobaba. Una `develop` que solo existe en local cumple la regla al ramificar y la
  incumple al abrir el PR: `gh pr create --base develop` falla con «Base ref must be a
  branch», y la salida obvia ante ese error —abrirlo contra `main`— es justo lo que la
  convención prohíbe. El fallo llegaba tarde y su arreglo aparente rompía el flujo.
- **`check-workflow-identity.sh` — que ningún workflow diga ser otro repositorio.** Los
  workflows exclusivos del repo-plantilla se filtran con
  `if: github.repository == 'usuario/repo'`. Al copiar uno entre repositorios esa
  condición viaja tal cual, y entonces el job no falla: **se salta**. En la lista de
  checks de un PR, un «skipping» gris se lee casi igual que un verde, así que una
  comprobación puede llevar meses sin ejecutarse ni una vez. Solo opina en el
  repo-plantilla: en una instancia, la condición nombra a la plantilla a propósito.

  Los dos son el mismo criterio dicho dos veces: **una regla que solo vive en la prosa
  no se cumple**, y un check que no corre es peor que uno que falla, porque el que falla
  avisa. El banco de pruebas pasa de 280 a 292 casos.

## [2.0.0] - 2026-09-07

### Added

- **`design/` — identidad visual con tokens semánticos**, más `DESIGN.md` en la raíz
  (generado desde `design/tokens.css`, nunca a mano) para que cualquier agente de IA lea
  el sistema de diseño. **Agnóstico de framework a propósito**: los tokens son custom
  properties de CSS estándar y el enganche a una librería concreta vive en un solo bloque
  marcado como adaptador, que se reemplaza. El diseño se puede montar como quieras.
  Con ellos llegan `docs/architecture/screens.md` (mapa de vistas), el subagente
  `designer` y las skills `/identidad` y `/prototipo`.
- **`spec-guardrails.sh`**: sin spec en `specs/` —o con un `proposal.md` a medio
  rellenar— no se puede editar código en `feat/*` ni `fix/*`. Con él, `specs/` deja de
  ser una recomendación.
- **Siete checks nuevos**, porque una regla que solo se cumple leyendo no se cumple:
  `check-changelog`, `check-design-tokens`, `check-hooks-enabled`, `check-instructions`,
  `check-project-tests`, `check-release` y `design-md.sh`. El banco de pruebas pasa de
  cero a 281 casos.
- **`.githooks/pre-commit` y `pre-push`**: los mismos checks del CI, antes de subir.
  En local son gratis; en Actions, minutos.
- **`docs/conventions/workflow.md`** — el ciclo de trabajo completo, de la spec al
  release. No dice qué construir ni con qué: eso es del proyecto.

### Changed

- **`docs/architecture/pantallas.md` se llama `screens.md`.** Era el único documento de
  `docs/` con nombre en español, junto a `stack.md`, `auth.md`, `database.md` y
  `api.md`. La regla del repositorio es que el código —archivos incluidos— va en
  inglés; el español queda para el contenido. De paso, las cuatro variantes de la
  familia comparten el nombre y el mapa de renombres de `check-parity.sh` se queda sin
  una entrada que mantener.
- **`architecture/` responde qué construye el proyecto; `conventions/`, cómo se
  trabaja.** Los pares que se rellenaban y podaban siempre juntos se fusionaron.

  **Si actualizas un proyecto que ya usaba una versión anterior, esta tabla es lo que
  hay que aplicar a mano.** Un documento renombrado no se sustituye: **se duplica**.
  Quedan los dos —el tuyo con contenido y el nuevo vacío—, los dos son markdown válido,
  los enlaces resuelven y ningún check lo detecta.

  | Antes                                   | Ahora                          | Qué hacer con tu contenido                                                                                                                             |
  | --------------------------------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
  | `docs/architecture/design.md`           | `docs/architecture/screens.md` | Migrar el mapa de pantallas y borrar el viejo. `design.md` queda reservado para el diseño **técnico** de cada spec (`specs/*/design.md`)               |
  | `docs/conventions/design-system.md`     | `docs/conventions/ui.md`       | Fusionar: `ui.md` reúne design system, marca y layouts                                                                                                 |
  | `docs/conventions/branding.md`          | `docs/conventions/ui.md`       | Ídem                                                                                                                                                   |
  | `docs/conventions/views-and-layouts.md` | `docs/conventions/ui.md`       | Ídem                                                                                                                                                   |
  | `docs/conventions/authentication.md`    | `docs/architecture/auth.md`    | Mover las reglas transversales a la sección «Reglas» de `auth.md` y borrar el viejo. El par se rellenaba y podaba junto — era la misma tabla dos veces |
  | `docs/README.md`                        | `AGENTS.md`                    | Era una segunda copia del mapa de documentación, y las dos divergían                                                                                   |
  | `docs/glossary.md`                      | —                              | Eliminado (huérfano). Si el tuyo tiene contenido, muévelo a `docs/product/business-model.md`                                                           |
  | `.claude/skills/refactor/`              | —                              | Eliminada: duplicaba el builtin `/simplify`. Si tu copia tiene reglas propias, muévelas a `docs/conventions/`                                          |
  | `.claude/agents/explorer.md`            | —                              | Eliminado: duplicaba el agente `Explore` de fábrica                                                                                                    |
  | `.claude/agents/code-reviewer.md`       | —                              | Eliminado: duplicaba la skill `/code-review` de fábrica                                                                                                |
  | `.github/labeler.yml`                   | —                              | Eliminado: configuración huérfana; ningún workflow la leía                                                                                             |

- **`docs/architecture/stack.md` es la única fuente del stack**, con el porqué de cada
  elección en `docs/decisions/`. Las convenciones dejan de apuntar a ningún catálogo:
  esta plantilla **documenta las decisiones de quien la use, no propone stacks**.
- **Los dos principios de trabajo con IA** —verificar > recordar; menos decisiones no
  revisadas = menos riesgo— pasan a `conventions/ai-agents.md`, que es de lo que tratan.
- **`AGENTS.md` es el índice único de la documentación.** `docs/README.md` era una
  segunda copia del mismo mapa, y las dos divergían.
- **Los scripts se nombran en inglés, como el resto del código**: `check-herencia` →
  `check-inheritance`, `check-hooks-activos` → `check-hooks-enabled`,
  `check-instrucciones` → `check-instructions`.
- **Cada subagente declara su modelo**, y la plantilla los deja todos en `inherit`: el
  reparto depende de tu plan, no de esta plantilla. El criterio para subir o bajar
  —«¿el error se detecta solo?»— está en `conventions/ai-agents.md`.
- **Las variables de servicios de `.env.example` van por categoría, no por proveedor**
  (`PAYMENTS_API_KEY`, `STORAGE_*`, `ERROR_TRACKING_DSN`…), y `scripts/backup-db.sh`
  habla S3 genérico en vez de nombrar un proveedor.

### Removed

- Los subagentes `explorer` y `code-reviewer` y la skill `/refactor`: **duplicaban
  funcionalidad que Claude Code trae de fábrica** (`Explore`, `/code-review`,
  `/simplify`), en versiones más pobres.
- `docs/glossary.md` (huérfano: nada lo referenciaba) y `.github/labeler.yml`
  (82 líneas de configuración para un workflow de auto-etiquetado que nunca existió —
  ningún workflow la leía).
- `.github/FUNDING.yml`, `.github/CODEOWNERS.example` y las plantillas de issue
  `support_question` y `documentation_request`. Quedan bug, funcionalidad y tarea.

### Fixed

- **Dos pasos de `quality.yml` no llevaban `!cancelled()`** y ocultaban a los
  siguientes cuando fallaban: el propósito del job de un solo trabajo es ver todos los
  problemas de una vez.
- **`check-design-tokens.sh` solo sabía leer un framework.** Ahora detecta la
  **notación** —utilidad con guiones, variable de preprocesador, custom property— en vez
  de una librería, así que un proyecto que no usa la de la plantilla deja de pasar en
  verde sin que se mire una sola de sus infracciones. Y no se traga los tokens del
  propio sistema: `--neutral` es un rol, no un color.

## v1.4.0 y anteriores

El historial hasta la `v1.4.0` vive en las [notas de release](https://github.com/brayandiazc/project-starter-template-es-ai/releases)
del repositorio. No se reconstruye aquí: inventarlo sería peor que no tenerlo.

<!--
Enlaces de comparación entre versiones:
[Unreleased]: https://github.com/brayandiazc/project-starter-template-es-ai/compare/v2.2.0...HEAD
[2.2.0]: https://github.com/brayandiazc/project-starter-template-es-ai/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/brayandiazc/project-starter-template-es-ai/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/brayandiazc/project-starter-template-es-ai/compare/v1.4.0...v2.0.0
-->
