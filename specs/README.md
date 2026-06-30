# Especificaciones — cambios ligeros guiados por especificaciones

Esta carpeta contiene **especificaciones de cambios**: una forma breve y estructurada de capturar _qué_ hace
un cambio y _por qué_ **antes** de escribir código. Les da tanto a las personas como a los agentes de IA
un objetivo claro y un punto de revisión, sin un proceso pesado.

> Opcional pero recomendado para cambios no triviales. Las correcciones pequeñas no necesitan una especificación.

## Cuándo escribir una especificación

Escribe una cuando un cambio sea no trivial, toque varias partes del sistema o
valga la pena alinearse antes de la implementación. Omítela para erratas y cambios de una línea.

## Cómo funciona

1. Copia [`_template/`](_template) a `specs/<nombre-del-cambio>/`
   (kebab-case, p. ej. `specs/user-invites/`). O ejecuta la skill `/new-spec`.
2. Completa los tres archivos:
   - `proposal.md` — el qué y el por qué (problema, objetivo, alcance).
   - `tasks.md` — la lista de tareas de implementación.
   - `design.md` — decisiones técnicas (enlaza a los ADRs en [`../docs/decisions/`](../docs/decisions/README.md)).
3. Hazla revisar y luego implementa siguiendo `tasks.md`.
4. Cuando termines, la especificación queda como registro (opcionalmente mueve las especificaciones completadas a una
   subcarpeta `archive/`).

## Relación con los ADRs

- Una **especificación** describe una unidad de trabajo (un cambio).
- Un **ADR** ([`../docs/decisions/`](../docs/decisions/README.md)) registra una
  decisión duradera. El `design.md` de una especificación puede producir uno o más ADRs.

## Alternativas más pesadas

Esto es intencionalmente minimalista. Si tu equipo quiere un framework formal y respaldado por
herramientas, considera [OpenSpec](https://github.com/Fission-AI/OpenSpec) o
[GitHub spec-kit](https://github.com/github/spec-kit). Adopta una de esas _en lugar
de_ esta carpeta si necesitas ese rigor.
