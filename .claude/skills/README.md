# Skills

Las skills de esta carpeta son **ejemplos** que se instalan con la plantilla: se
mantienen agnósticas al stack porque delegan en tus `docs/` (índice en
[`AGENTS.md`](../../AGENTS.md)).
Adáptalas o elimínalas según el proyecto.

## Reglas de estructura (el CI las valida)

`quality.yml` ejecuta [`check-skills.sh`](../../.github/scripts/check-skills.sh) en
cada PR (y `pre-push` en local):

- Cada skill vive en `<nombre-kebab>/SKILL.md`.
- El `name` del frontmatter es igual al nombre de la carpeta, en kebab-case.
- La `description` no está vacía y dice **cuándo invocarla** — el agente enruta por
  ese campo, así que escríbela como disparador ("Úsalo cuando la persona pida…"),
  con ejemplos de frases, no como resumen de marketing.
- El cuerpo cabe en **~150 líneas** (el check lo impone, sin excepciones). Lo
  enciclopédico —tablas, catálogos, el porqué largo de una regla— va en un
  `reference.md` junto a la skill, que el cuerpo manda leer **en el paso que lo
  necesita** (así el contexto solo carga el detalle cuando toca; `instanciar` es el
  ejemplo).
- Lo mismo aplica a los subagentes de [`../agents/`](../agents) (`name` = nombre de
  archivo, `description` no vacía).

## Cómo escribir una skill nueva

Crea `nueva-skill/SKILL.md` a partir de esta plantilla y mantén el cuerpo corto
(menos de ~150 líneas: el cuerpo se carga en el contexto del agente cada vez que la
skill se activa). No dupliques otra skill (enlázala) ni metas reglas del proyecto
(esas viven en `docs/conventions/`).

```markdown
---
name: nueva-skill
description: Qué hace en una frase. Úsalo cuando la persona pida X o Y (p. ej. "frase que diría el usuario", "otra frase"). Qué NO hace, si puede confundirse.
---

Una línea sobre el problema que esta skill evita y a qué documento de `docs/` se remite.

## Pasos

1. Lee la convención correspondiente en `docs/conventions/…` — es la fuente de verdad.
2. [pasos concretos y verificables]
3. [cómo comprobar el resultado antes de terminar]

Ejemplo: `/nueva-skill argumento` → resultado esperado en una línea.

NO [acción prohibida 1], NO [acción prohibida 2] sin confirmación explícita.
```
