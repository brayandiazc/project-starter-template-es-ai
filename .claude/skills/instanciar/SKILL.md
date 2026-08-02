---
name: instanciar
description: Paso interno de /arrancar-proyecto que rellena la plantilla (placeholders, limpieza por tipo, permisos). NO es el comando de arranque — si la persona quiere empezar un proyecto ("instancia la plantilla", "configura este template", "arranquemos"), usa /arrancar-proyecto, que invoca este flujo en su Paso 3. Invócalo directo solo para el caso especial de adoptar la capa de documentación en un proyecto EXISTENTE con código.
---

<!-- Skill de ejemplo de la plantilla — adáptalo o elimínalo según tu proyecto. -->

> **Punto de entrada:** el comando de arranque es `/arrancar-proyecto`; este flujo es su
> Paso 3. Si alguien lo invoca directo sobre un proyecto nuevo, redirígelo a
> `/arrancar-proyecto` (que además prepara las ramas Git Flow antes de tocar nada).

Convierte esta plantilla en la documentación real de un proyecto mediante una entrevista.
Lee `TEMPLATE-USAGE.md` primero: es la fuente de verdad del catálogo de placeholders (§3),
las reglas de borrado por tipo (§7) y el flujo de adopción (§2). Sigue ese documento si
difiere de los pasos de abajo.

## Paso 0 — Guardián de seguridad (antes de nada)

Detente y avisa si estás sobre el REPO-FUENTE del template (no una instancia):

- Revisa `git remote -v`. Si el origin es el repositorio de la plantilla
  (`project-starter-template-es-ai`), NO instancies: estarías destruyendo la plantilla.
- En ese caso, pregunta explícitamente si de verdad se quiere modificar la plantilla
  original antes de continuar.

## Paso 1 — Detectar contexto (nuevo vs. existente)

Sin preguntar aún, inspecciona el repo para deducir el contexto:

- ¿Hay código real? (`package.json`, `Gemfile`, `pyproject.toml`, `go.mod`, `src/`, etc.)
- ¿El historial de git tiene commits propios del proyecto o es un clon recién iniciado?
- ¿Siguen intactos los `[PLACEHOLDERS]`?
  (`grep -rno '\[[A-ZÁÉÍÓÚÑ0-9_/]\+\]' --include='*.md' .`)

Deduce **NUEVO** (repo vacío / placeholders intactos) o **EXISTENTE** (ya hay código).

## Paso 2 — Confirmar y entrevistar (usa AskUserQuestion)

Muestra tu deducción del Paso 1 y deja corregirla. Luego pregunta SOLO lo que no puedas
inferir. En proyectos existentes, pre-rellena las respuestas leyendo el código.

- **Lote A · Contexto y tipo:** nuevo/existente; tipo (Web · Móvil · Escritorio ·
  API/servicio · Librería).
- **Lote B · Identidad:** nombre, autor, usuario/org de GitHub, empresa (opcional),
  email de soporte, email de seguridad, licencia y año. Infiere autor/usuario de
  `git config` y el año de la fecha del sistema.
- **Lote C · Stack:** ofrece primero los **presets de `docs/stacks/`** (web-fullstack,
  spa-api, api-service, mobile, web-estatica, pwa, extension-navegador) según el tipo
  del Lote A; el preset elegido rellena `docs/architecture/stack.md` y solo se pregunta
  por las desviaciones. Si ninguno aplica, pregunta pieza a pieza: runtime, gestor de
  paquetes, base de datos (o "ninguna"), puerto, comandos (instalar / dev / test / lint).
  En existente: LÉELO del código, no preguntes.
- **Lote D · Capacidades:** ¿API? ¿autenticación? ¿i18n? ¿SEO/web pública? ¿emails
  transaccionales? ¿sistema de diseño/UI? (Cada "no" implica borrar su convención.)
- **Lote E · Permisos y guardrails:** ¿dejar el `ask:[Bash]` conservador de
  `.claude/settings.json`, o crear `.claude/settings.local.json` con una allowlist de
  solo-lectura? Los tres **guardrails** (git, secretos y specs) vienen **activos por
  defecto** en `.claude/settings.json` — no preguntes si activarlos; solo si la
  persona pide explícitamente desactivar alguno, quita su bloque de hooks y deja
  constancia en el ADR de instanciación.

## Paso 3 — Rellenar / fusionar según contexto

Reemplaza los placeholders del catálogo (`TEMPLATE-USAGE.md §3`) con las respuestas:
`[NOMBRE_DEL_PROYECTO]`, `[AUTOR]`, `[USUARIO_GITHUB]`, `[NOMBRE_EMPRESA]`,
`[URL_REPOSITORIO]`, `[AÑO]`, `[EMAIL_SOPORTE]`, `[EMAIL_SEGURIDAD]`, `[RUNTIME]`,
`[GESTOR_DE_PAQUETES]`, `[BASE_DE_DATOS]`, `[PUERTO]`, `[COMANDO_*]`, `[URL_*]`, `[FECHA]`.

Archivos que se actualizan: `README.md`, `AGENTS.md` (resumen + comandos),
`docs/architecture/*`, `docs/product/*`, `.env.example`, `LICENSE` (año + autor),
`SECURITY.md` (emails), `CHANGELOG.md` (primera entrada).

- **NUEVO:** escribe directo desde las respuestas. Trabaja en el repo tal cual.
- **EXISTENTE:** lee el código e infiere para no dejar `[…]`. **NO sobrescribas**
  `README.md`, `LICENSE` ni `.gitignore` — propón el merge a mano. Trabaja en una rama
  `chore/adopt-doc-template`. Sugiere correr `/init` para integrar el contexto del código.

Además, escribe `.template-origin` en la raíz para que `/actualizar-plantilla` pueda
traer mejoras futuras de la plantilla:

```
repo=<URL de esta plantilla>
commit=<SHA del HEAD de la plantilla usado como base>
fecha=<YYYY-MM-DD de hoy>
```

## Paso 4 — Aplicar la decisión de permisos (Lote E)

Si se eligió "automático", crea `.claude/settings.local.json` con una allowlist de
comandos de solo-lectura (`ls, cat, head, tail, wc, grep, rg, find, tree, sort, uniq,
echo, pwd, which`, y `git status/log/diff/branch/show/remote`). Verifica que
`.claude/settings.local.json` esté en `.gitignore`. Si se eligió "conservador", no toques
nada de permisos.

Los guardrails ya vienen activos en `.claude/settings.json` (git-guardrails,
secret-guardrails y spec-guardrails; requieren `python3`) — solo toca esos bloques si
la persona pidió desactivar alguno en el Lote E.

## Paso 5 — Limpieza por tipo (regla de TEMPLATE-USAGE.md §7)

Borra los docs/convenciones que no apliquen:

- Móvil / Escritorio → borra `docs/conventions/seo.md`; reenfoca `views-and-layouts`,
  `api`, `deploy`.
- API / Librería → borra docs de UI (`seo`, `views-and-layouts`, `design-system`,
  `branding`).
- Cada capacidad respondida "no" en el Lote D → borra su convención (p. ej. sin i18n →
  `docs/conventions/i18n.md`) **y su skill asociada**: sin i18n → `i18n-parity`; sin
  base de datos → `migration-guard`; sin SEO/web pública → `seo-audit`; sin UI (API o
  librería) → `design-system-audit`, `accessibility-audit` y `copywriting`.
- **Siempre** borra los archivos exclusivos del repo-plantilla: el workflow
  `.github/workflows/template-parity.yml`, el script `.github/scripts/check-parity.sh`
  y la skill `.claude/skills/portar-cambio/` — solo sirven para mantener la familia de
  variantes, no a un proyecto instanciado.
- **Conserva** `.github/workflows/template-update-check.yml`: es el que avisa al
  proyecto instanciado (vía issue) cuando la plantilla de origen publica mejoras.

Pregunta antes de borrar en bloque si hay ambigüedad.

## Paso 6 — Cierre

Registra la instanciación como el ADR `0002` (usa `docs/decisions/0000-template.md`):
contexto del proyecto, stack elegido, tipo, convenciones eliminadas y política de
permisos/guardrails — así el proyecto estrena su propio registro de decisiones.

Muestra un resumen del diff y la lista de placeholders que aún requieren decisión humana.
NO hagas commit — deja que la persona revise. En "existente", recuérdale que todo quedó
en la rama para abrir un PR. Sugiere borrar `TEMPLATE-USAGE.md` cuando termine.

Ejemplo: `/instanciar` → entrevista → repo con documentación real y `docs/` podados.

NO instancies sobre el repo-fuente del template (Paso 0), NO sobrescribas el código de
producción en proyectos existentes, NO hagas commit ni push por tu cuenta, y NO inventes
datos: si no puedes inferir un valor y la persona no lo da, deja el placeholder y márcalo.
