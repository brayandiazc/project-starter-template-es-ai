# Diseño — Flujo de arranque unificado y guardrails obligatorios

> Diseño técnico de este cambio. Omite las secciones que no apliquen.

## Enfoque

Convertir las reglas de proceso en **hooks deterministas activos por defecto** y dejar
la orquestación del arranque en una sola skill. Los hooks leen el evento PreToolUse
por stdin (python3 para el parseo), devuelven `exit 2` para bloquear y fallan abiertos
ante cualquier duda. La correspondencia rama ↔ spec se resuelve por convención de
nombres (`feat/<slug>` ↔ `specs/NNNN-<slug>/`), que es verificable sin estado extra.

## Alternativas consideradas

| Alternativa                                                              | Por qué no                                                                                                               |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| Fusionar `/instanciar` dentro de `/arrancar-proyecto` en un solo archivo | Se pierde el caso "adoptar docs en proyecto existente" y el archivo crecería demasiado; basta un punto de entrada claro. |
| Exigir la spec vía instrucciones (AGENTS.md) más enfáticas               | Ya estaba escrito y se saltó igual — solo un hook lo garantiza.                                                          |
| Separador TAB en los veredictos del hook de git                          | El TAB es "IFS whitespace" en bash: los campos vacíos colapsan y se corren las columnas. Se usa `\x1f` (unit separator). |
| MCP de SSH para administrar el VPS                                       | Claude Code ya tiene Bash + ssh + Kamal; un MCP añade capa sin valor.                                                    |

## Áreas afectadas

- **Modelo de datos / API**: no aplica (cambio de tooling y proceso).
- **Otros**: hooks (`.claude/hooks/`), settings compartidos, skills de arranque y
  specs, workflows de CI, convenciones y guías.

## Decisiones

- Guardrails **opt-out** (activos por defecto) en vez de opt-in — promovida a ADR.
- `docs/*` y `chore/*` no requieren spec; `feat/*` y `fix/*` sí, siempre.
- Las herramientas de diseño externas se instalan como plugin (no se vendorizan)
  para recibir actualizaciones; los tokens de `design/` mandan sobre ellas.

## Despliegue y reversión

- Se despliega con el merge a `develop`; los proyectos ya instanciados lo reciben
  vía `/actualizar-plantilla` (avisados por `template-update-check.yml`).
- Reversión: quitar los bloques de hooks de `.claude/settings.json` restaura el
  comportamiento anterior sin tocar los scripts.
