---
name: instanciar
description: EL comando de arranque — convierte esta plantilla en un proyecto real de punta a punta con una sola orden. Prepara las ramas Git Flow (develop + rama de documentación), corre el Sprint de definición (producto, mapa de vistas, stack), rellena los placeholders, poda los docs por tipo de proyecto y deja lista la primera spec. Úsalo siempre que la persona llegue con una idea nueva o quiera empezar (p. ej. "instancia la plantilla", "arranquemos el proyecto", "tengo una idea", "empecemos con X").
---

Convierte esta plantilla en un proyecto real. Dos fuentes se leen **en el paso que las
cita**, no de corrido: [`reference.md`](reference.md) (tablas de poda, pasadas de
relleno, el porqué de cada regla) y `TEMPLATE-USAGE.md` (catálogo de placeholders, §3).
El arranque produce **dos ramas en secuencia**, ambas nacidas de `develop`:

```
main ──► develop ──► docs/arranque ──(PR → develop ──► release v0.1.0 a main)──► feat/<primera-spec>
         (se crea       rama 1:                                                    rama 2:
         si falta)      toda la documentación                                      scaffolding + prototipo
```

## Paso 0 — Guardián y ramas (antes de cualquier contenido)

1. **¿Estás a punto de destruir la plantilla?** El nombre del repositorio no sirve
   para detectarlo; la señal es la combinación de dos cosas:

   ```bash
   sin_instanciar=$([ -f TEMPLATE-USAGE.md ] && [ ! -f .template-origin ] && echo sí)
   remoto=$(git remote get-url origin 2>/dev/null)
   ```

   | `sin_instanciar` | `remoto`    | Qué es                                                | Qué haces               |
   | ---------------- | ----------- | ----------------------------------------------------- | ----------------------- |
   | sí               | **ninguno** | Clon reseteado, listo para instanciar                 | **Sigue**               |
   | sí               | **hay uno** | La plantilla, o un clon al que le faltó `rm -rf .git` | **PREGUNTA**            |
   | no               | cualquiera  | Ya instanciado                                        | Modo EXISTENTE (paso 2) |

   Cuando haya remoto, no adivines: muestra la URL y pregunta. Si falta el reseteo,
   ofrécelo **solo con confirmación explícita** — es lo único sin vuelta atrás
   (`reference.md` §Paso 0).

2. Detecta el contexto sin preguntar (¿código real?, ¿placeholders intactos?), deduce
   **NUEVO** o **EXISTENTE** y confírmalo. En EXISTENTE: rama
   `chore/adopt-doc-template`, **no sobrescribas nada** — solo se trae lo que no existe
   (`TEMPLATE-USAGE.md` §2). Si ya tiene estructura de plantilla (`docs/conventions/`
   con contenido), no es adopción: deriva a `/actualizar-plantilla`.
3. Activa los git hooks: `bash .github/scripts/check-hooks-enabled.sh --arreglar`.
4. **Asegura que existan las DOS ramas base** — sin `main`, `release.yml` no se dispara
   nunca y el proyecto no puede publicar:

   ```bash
   git show-ref --verify -q refs/heads/develop || git branch develop main
   git show-ref --verify -q refs/heads/main    || git branch main develop
   ```

   **Las dos se crean en local; ninguna se publica todavía** (`main`, hasta el Paso 5:
   `reference.md` §Paso 0). Crea la **rama 1**: `git checkout -b docs/arranque develop`
   — TODO lo que sigue va ahí.

## Paso 1 — Sprint de definición

Corre `/definir-producto` (la entrevista, con el banco literal de
`docs/product/interview.md`). No avances sin la tabla Dentro/Fuera de v1. Con el tipo de
proyecto definido, propone un stack de `docs/marco-tecnico.md` §3 y confirma desviaciones.

## Paso 2 — Entrevistar lo que falte del repo (usa AskUserQuestion)

Preguntas de **tooling**, no de producto (esas ya las cubrió el Paso 1). Pregunta SOLO
lo que no puedas inferir (en EXISTENTE, lee el código primero):

- **Identidad:** usuario/org de GitHub, email de soporte y de seguridad — infiere lo
  que puedas de `git config`.
- **Titular legal — pregúntalo siempre, aunque parezca obvio:** ¿a nombre de quién
  va el producto? Escribe ese titular en el `LICENSE` y en el pie de
  `design/preview.html` — el porqué está en `reference.md` §Paso 2.
- **Capacidades:** ¿UI? ¿base de datos? ¿auth? ¿API? ¿i18n? ¿SEO? ¿emails? **¿IA?**
  Cada «no» poda documentos y skills en el Paso 3. Ni la base de datos ni la IA se dan
  por supuestas (`reference.md` §Paso 2).
- **Stack: confírmalo pieza por pieza ANTES de escribir `stack.md`** — es la decisión
  más cara del arranque y se ha saltado en arranques reales. Tabla, origen (marco §3 o
  desviación con ADR) y confirmación (`reference.md` §Paso 2).
- **Permisos:** ¿allowlist de solo-lectura en `.claude/settings.local.json`? Los tres
  guardrails vienen **activos**; solo se tocan si la persona lo pide, y queda en el ADR.

## Paso 3 — Poda por tipo (antes de rellenar, no después)

**Podar va primero.** Rellenar antes obliga a inventarse contenido para documentos que
vas a borrar: medido, 43 placeholders de trabajo tirado.

**Lee AHORA `reference.md` §Paso 3 y síguelo entero**: las tablas de qué arrastra cada
«no», las secciones que sobran dentro de archivos que se quedan («cuidado: no fallan
ningún check»), los tags heredados, el reseteo del CHANGELOG, y los ADRs y archivos de
la plantilla que se van.

Cierra la poda con `bash .github/scripts/check-links.sh` — **podar rompe enlaces
siempre** (`AGENTS.md` garantizado). No termines el paso hasta que salga limpio.

## Paso 4 — Rellenar

**La lista se pregunta, y la pasada NO recorre el repositorio entero:**

```bash
bash .github/scripts/check-placeholders.sh                       # qué falta
bash .github/scripts/check-placeholders.sh --rutas-sustituibles  # dónde se toca
```

**El arranque real son unos 330 elementos** (placeholders + huecos en prosa); dilo desde
el principio. **Lee AHORA `reference.md` §Paso 4 y síguelo entero.** Orden que rinde:

1. **Primera pasada, por valor, SOLO con los globales y SOLO en esas rutas.** Scripts,
   workflows, `.claude/` y las tres plantillas internas quedan fuera: sustituir ahí
   rompe el banco de pruebas y, semanas después, `spec-guardrails`. Los **posicionales**
   (`VERSION`, `ENTIDAD_*`, `PLAN_*`…) nunca entran: en bloque dejan documentos
   plausibles y falsos. Si el mismo placeholder se repite en un archivo, es posicional.
2. **Los documentos que dan contexto al resto**: definición de producto, stack,
   arquitectura — hacen que los demás casi se rellenen solos.
3. **Lo que no se pueda escribir hoy se marca en el momento** (`<!-- pendiente: … -->`
   en su línea; lo global, una vez en `.pendientes`). NO inventes datos ni placeholders.

Cierra con `bash .github/scripts/tests/run-tests.sh` —el daño al banco se ve ahí, no
quince pasos después— y no termines hasta que el check salga limpio.

**Y escribe `.template-origin`** en la raíz (repo, commit, fecha y `versiones=` — el
formato exacto y cómo extraer las versiones: `reference.md` §Paso 4).

## Paso 5 — Primera spec y cierre de la rama de documentación

1. Registra la instanciación como ADR (contexto, stack, tipo, podas, permisos, titular
   legal). Será el `0002` del proyecto, con enlace al repositorio origen.
2. Crea con `/new-spec` la spec del primer cambio (normalmente `scaffold-y-prototipo`);
   la rama que la implemente será `feat/<slug-de-la-spec>`, que es lo que el guardrail
   exige. Si el producto es público, anota en el roadmap que faltan sus textos legales
   (`reference.md` §Paso 2).
3. Commitea `docs/arranque` (`/commit`) y abre el PR hacia `develop` (`/open-pr`). **El
   código aún no existe y está bien.** Sin remoto: ahora sí `/configurar-repo` y el PR,
   o fusiona en local con `--no-ff` y **anota que el PR queda pendiente**.
4. **`main` se publica AQUÍ, no antes**: un `push` a `main` con el CHANGELOG sin
   resetear dispara `release.yml` y publica la release DE LA PLANTILLA. Y comprueba
   contra el REMOTO que no hay tags ni releases heredados — `git tag -l` da falso
   negativo sin `fetch` (`reference.md` §Paso 5).
5. Corta la **primera release** con `/release`, completo: `chore/corte-v0.1.0` → PR a
   `develop` → PR `develop` → `main` (dos PRs, no uno). Sin Actions, el tag y el
   release se crean a mano (Paso 8 de `/release`).

## Paso 6 — Rama 2: scaffolding + prototipo

Con la release hecha: `git checkout develop && git pull && git checkout -b
feat/<slug-de-la-primera-spec>`. Genera el proyecto, corre **`/identidad`** (la paleta
se decide ANTES de prototipar) y después `/prototipo`, siguiendo la spec — si hay UI,
sugiere antes el plugin **Impeccable** (`design/README.md` → Herramientas de diseño).

**Activa el CI del código en esta misma rama**: renombra `ci.yml.example` → `ci.yml`,
rellena los `[COMANDO_*]`, borra la cabecera y verifica que pase (`reference.md` §Paso 6).
Sin esto, el proyecto llega a la v1 con un CI que solo valida Markdown.

## Cierre

Resume: definición (una frase + dentro/fuera de v1), stack, ramas y su estado, spec
activa, podas hechas y **pendientes humanos** — incluidos los placeholders marcados.

NO instancies sobre el repo-fuente (Paso 0), NO te saltes el orden de ramas, NO
implementes el Paso 6 sin la spec del Paso 5, NO dejes el proyecto sin `ci.yml` activo
ni con el CHANGELOG/ADRs de la plantilla (el job `herencia` lo verifica), NO hagas push
sin confirmar el remoto, y NO sobrescribas código en proyectos existentes. Si la
persona ya hizo un paso, detéctalo y sáltalo.
