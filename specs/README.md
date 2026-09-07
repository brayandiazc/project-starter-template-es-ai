# Especificaciones — cambios ligeros guiados por especificaciones

Esta carpeta contiene **especificaciones de cambios**: una forma breve y estructurada de capturar _qué_ hace
un cambio y _por qué_ **antes** de escribir código. Les da tanto a las personas como a los agentes de IA
un objetivo claro y un punto de revisión, sin un proceso pesado.

> **Obligatorio para toda funcionalidad y corrección** (`feat/*`, `fix/*`): el hook
> `spec-guardrails.sh` bloquea la edición de código en esas ramas si no existe la
> spec correspondiente. Ver [`../docs/conventions/workflow.md`](../docs/conventions/workflow.md).

## Cuándo escribir una especificación

Siempre que el cambio sea una funcionalidad o una corrección: la rama `feat/<slug>` o
`fix/<slug>` debe tener su `specs/NNNN-<slug>/` **antes** de tocar código (créala con
`/new-spec`). Solo quedan fuera los cambios de documentación pura (ramas `docs/*`) y
el mantenimiento de tooling (ramas `chore/*`).

## Cómo funciona

1. Copia [`_template/`](_template) a `specs/NNNN-<nombre-del-cambio>/`, donde `NNNN`
   es el siguiente correlativo de 4 dígitos (kebab-case, p. ej. `specs/0012-user-invites/`).
   O ejecuta la skill `/new-spec`, que calcula el número por ti.
2. Completa los tres archivos:
   - `proposal.md` — el qué y el por qué (problema, objetivo, alcance) y el
     **ítem de roadmap** que la spec viene a completar.
   - `tasks.md` — la lista de tareas de implementación.
   - `design.md` — decisiones técnicas (enlaza a los ADRs en [`../docs/decisions/`](../docs/decisions/README.md)).

   `proposal.md` debe quedar **sin líneas de plantilla sin rellenar**: el hook
   `spec-guardrails.sh` las detecta y bloquea la edición de código hasta que se
   completen o se borren. Una spec a medio escribir no es un contrato.

3. Hazla revisar y luego implementa siguiendo `tasks.md`.
4. Cuando termines, la especificación queda como registro (opcionalmente mueve las especificaciones completadas a una
   subcarpeta `archive/`, **conservando su número**).

### Por qué van numeradas

El prefijo `NNNN-` hace que `ls specs/` muestre las especificaciones **en el orden en
que se crearon** — igual que los ADRs de [`../docs/decisions/`](../docs/decisions/README.md).
Sin él, el orden alfabético agrupa por nombre de feature y la cronología solo se
recupera espulgando `git log`, lo que se vuelve inmanejable a partir de unas cuantas
especificaciones. El número además da una referencia estable y corta ("la spec 0012")
en PRs, ADRs y conversaciones, y sobrevive al archivado.

## Relación con el roadmap

Las specs son la unidad que hace avanzar el roadmap, así que ambos se mantienen
atados en los dos extremos:

- **Al abrir**: `proposal.md` declara el campo _Ítem de roadmap_ — qué ítem de
  [`../docs/product/roadmap.md`](../docs/product/roadmap.md) completa esta spec. Si el
  ítem no existe, se crea allí primero; si el cambio no cabe en ninguna versión, es
  señal de que hay que pasar por la definición de producto antes de especificar.
- **Al cerrar**: la última tarea de `tasks.md` marca ese ítem como hecho en el
  roadmap, en el **mismo PR** que implementa el cambio — junto con el `CHANGELOG.md`.

Así el roadmap refleja lo que de verdad está fusionado, sin ningún ritual de
actualización aparte.

## Relación con los ADRs

- Una **especificación** describe una unidad de trabajo (un cambio).
- Un **ADR** ([`../docs/decisions/`](../docs/decisions/README.md)) registra una
  decisión duradera. El `design.md` de una especificación puede producir uno o más ADRs.

## Alternativas más pesadas

Esto es intencionalmente minimalista. Si tu equipo quiere un framework formal y respaldado por
herramientas, considera [OpenSpec](https://github.com/Fission-AI/OpenSpec) o
[GitHub spec-kit](https://github.com/github/spec-kit). Adopta una de esas _en lugar
de_ esta carpeta si necesitas ese rigor.
