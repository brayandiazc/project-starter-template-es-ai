# Referencia de `/instanciar`

> Material de consulta de la skill: se lee **en el paso que lo cita**, no de corrido.
> El flujo y el orden viven en [`SKILL.md`](SKILL.md); aquí está el detalle que no
> cabe en 150 líneas — tablas de poda, pasadas de relleno y el porqué de cada regla.

## Paso 0 — El reseteo y el push prematuro

**Si falta el reseteo del historial, ofrécelo en vez de solo avisar** (mostrando qué se
pierde: historial, tags y `origin`), pero **no lo hagas sin confirmación explícita**: es
lo único de todo el arranque que no tiene vuelta atrás. Todo lo demás que borra esta
skill se recupera con `git checkout .`; el historial, no.

**No hagas `push` hasta tener remoto propio.** El caso normal es un clon reseteado, y
ese repositorio **no tiene `origin` justamente porque acaba de pasar por
`rm -rf .git`** — es la misma señal con la que se distinguió de la plantilla. Empujar
ahí falla, y si por lo que sea funciona es peor: significa que el remoto es el de la
plantilla. Antes del primer `push`, corre **`/configurar-repo`**: crea el repositorio
(preguntando público o privado), pone descripción, topics y labels, publica las dos
ramas, deja **`develop` como rama por defecto** y aplica la protección de `main`. Lo de
la rama por defecto no es cosmético: es a donde apuntan los PRs nuevos, y con `main`
ahí un PR de feature va directo a producción saltándose la integración.

**Y `main` se crea en local ahora, pero se publica en el Paso 5.** No es lo mismo. En el
Paso 0, `main` apunta al commit inicial, **cuyo CHANGELOG sigue siendo el de la
plantilla**, con su última versión arriba. `release.yml` se dispara con `push` a `main`,
y un workflow disparado por un push corre contra **el contenido de esa rama en ese
momento**, no contra lo que tú tienes delante: ve esa versión, comprueba que no tiene
tag y crea el tag y el release con las notas del repositorio origen.

Pasó, y ninguno de los controles lo atrapó: la poda manda `git tag -d $(git tag -l)`,
pero el tag todavía no existe —lo crea el push, dos pasos después— y `git tag -d` es
local; `check-inheritance.sh` mira archivos e historial, no tags ni releases, y salió verde
todo el rato.

Hoy la guarda existe (`check-inheritance.sh --version-publicable`, que consultan
`release.yml` y `check-release.sh`), así que el fallo ya no puede colarse aunque el
orden se rompa. Aun así, publica `main` en el Paso 5: **publicar una rama base «vacía»
no es una operación neutra si hay automatización escuchándola.**

### Avisa del terreno antes de empezar, no cuando estorbe

Dos condiciones del entorno cambian cómo se vive el arranque, y las dos se descubrían
a mitad de camino (fricción 5 de un arranque real). Compruébalas ahora y **dilo desde el
principio**:

- **Las fusiones pueden ser manuales.** El flujo incluye **tres fusiones de PR**
  (documentación → `develop`, corte → `develop`, `develop` → `main`); si `gh pr merge`
  no está disponible —p. ej. un entorno con clasificador de permisos—, esas tres las
  hace la persona a mano.
- **Actions puede no correr** (minutos agotados, repositorio privado). Entonces
  `release.yml` no publica el tag ni el release de GitHub: se crean a mano con el
  Paso 8 de `/release`, y el release no se da por publicado sin verificarlo.

Ninguna de las dos bloquea el arranque; descubrirlas tarde sí desconcierta.

## Paso 2 — El titular legal, con el porqué

**Esta plantilla no trae textos legales, y es deliberado.** Unos términos y una política
de privacidad heredados son el peor tipo de placeholder: están completos, se leen bien y
son de otra empresa, otro país y otro tratamiento de datos. Publicados en el sitio de un
cliente, le atribuyen a alguien la responsabilidad legal de un servicio que presta otro,
y **nada en el repositorio lo detecta**. Se redactan por producto, con asesoría, cuando
el producto sepa qué datos trata.

Lo que sí hay que resolver en el arranque es **a nombre de quién va el producto**, que
aparece en dos sitios y nadie revisa después:

- El copyright del `LICENSE`.
- El pie de `design/preview.html`, que sale en cada captura que se enseña.

Pregúntalo siempre, aunque el titular parezca obvio, y deja constancia en el ADR de
instanciación del Paso 5. Si el producto va a ser público, anota en el roadmap que
faltan sus textos legales — un producto que cobra sin términos publicados es un riesgo
abierto, no un pendiente cosmético.

**Por qué se preguntan la base de datos y la IA en vez de asumirse:** la base de datos
es la capacidad que más arrastra (18 placeholders entre sus dos documentos) y hay
productos sin ella (una CLI, una extensión, un sitio estático). La IA, sin preguntarla,
deja sus cinco variables en el `.env.example` de todo proyecto, sugiriendo un proveedor
que configurar y un respaldo que probar en productos que no llaman a ningún modelo.

**Por qué el stack se confirma pieza por pieza antes de escribir `stack.md`:** es la
decisión más cara del arranque —condiciona CI, deploy, convenciones y todo lo que se
construya encima— y se ha saltado en arranques reales sin que nada chistara. Muestra la
propuesta como tabla (framework, runtime, gestor, estilos, tests, lint, deploy), **di
de dónde sale** —uno de los stacks del marco §3, la regla de dominio para herramientas
internas, o una desviación— y pide confirmación. Si está fuera del marco, dilo con esas
palabras y avisa de que costará un ADR.

## Paso 3 — Las tablas de poda

**Cada «no» del Paso 2 arrastra sus documentos Y sus skills.** La tabla es orientación
de qué suele ir junto; quien tiene la última palabra es `check-placeholders.sh`: lo que
reporte, o se rellena o se borra.

| Capacidad en «no»     | Documentos                                                                            | Skills y agentes                                                                                         |
| --------------------- | ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| **UI**                | `conventions/ui.md`, `architecture/pantallas.md`, `design/` entero, `DESIGN.md`       | `prototipo`, `identidad`, `design-system-audit`, `accessibility-audit`, `copywriting`, agente `designer` |
| **Base de datos**     | `conventions/database.md` — y **solo a veces** `architecture/database.md` (ver abajo) | `migration-guard`                                                                                        |
| **auth**              | `architecture/auth.md` — y **solo a veces** (ver abajo)                               | —                                                                                                        |
| **API**               | `architecture/api.md`                                                                 | —                                                                                                        |
| **i18n**              | `conventions/i18n.md`                                                                 | `i18n-parity`                                                                                            |
| **SEO / web pública** | `conventions/seo.md`                                                                  | `seo-audit`                                                                                              |
| **emails**            | `conventions/transactional-emails.md`                                                 | —                                                                                                        |
| **IA**                | `marco-tecnico-ia.md`, la sección de capa de IA de `architecture/stack.md`            | —                                                                                                        |

### «Base de datos» no es «modelo de datos»

El «no» a base de datos poda el **motor**: sus convenciones, migraciones y seeds
(`conventions/database.md`, `migration-guard`). El **modelo de datos** —las entidades y
el documento estructurado que describe el estado— casi nunca es «no»: una CLI que
escribe un archivo de estado, una extensión que guarda configuración, un producto con
un `manifest.json` junto a cada artefacto tienen todos un modelo que el marco §4.5
manda diseñar en papel antes del código. Y esta poda es de las peligrosas: **no falla
ningún check** — un arranque que siga la tabla al pie de la letra pierde el esquema más
caro de su proyecto sin que nada chiste (pasó en un arranque real).

- **¿El producto guarda CUALQUIER estado estructurado?** Conserva
  `architecture/database.md` y reescríbelo de cero como el modelo de datos del
  producto. El índice de `AGENTS.md` ya lo presenta como «Modelo de datos», que es lo
  que la persona busca; el nombre del archivo se mantiene por estabilidad de enlaces.
- **¿No guarda estado alguno** (un sitio estático puro)? Entonces sí: se borran los dos
  documentos.

### «auth» poda las cuentas, no las credenciales

Es el mismo error de arriba, en el otro documento: allí se distingue el **motor** del
**modelo de datos**; aquí hay que distinguir las
**cuentas** de las **credenciales**. **«No hay cuentas» no es «no hay credenciales».**

Un producto sin sesiones ni contraseñas puede manejar perfectamente una clave de API
que aporta la persona usuaria (BYOK), el token de un enlace compartido o el secreto de
un webhook. Esas reglas —nunca se versiona, nunca sale del navegador, solo se envía al
proveedor elegido, se puede borrar desde Ajustes— **no viven en ningún otro sitio**, y
son justo las que fallan en silencio. Y esta poda, como la de base de datos, **no falla
ningún check**.

- **¿El producto maneja CUALQUIER credencial?** Conserva `architecture/auth.md` y
  reescríbelo: que declare que no hay autenticación y por qué, recoja las reglas de esa
  credencial, y liste **los disparadores** que obligarán a rehacerlo (que lo use un
  tercero, que los datos salgan del navegador, que se custodie la clave de otra
  persona).
- **¿Ninguna credencial de ningún tipo?** Entonces sí: fuera.

### Las capacidades también viven DENTRO de archivos que se quedan

Borrar el archivo entero no basta, y **la lista de dónde mirar siempre se queda
corta** — ya nació corta dos veces. Usa la regla, no una lista:

> **Cada capacidad en «no» se busca por su nombre en todo el repositorio**, no solo en
> los archivos que alguien recordó anotar.

```bash
grep -rn -i "migracion\|esquema\|DATABASE\|AUTH_\|healthcheck\|multiidioma\|pantalla\|prototipo\|AI_PROVIDER\|inquilino\|ACTOR_\|sin conexión\|store\|rollback" \
  --include="*.md" --include=".env.example" . | grep -v "^./.git"
```

Revisa cada acierto y decide: rellenar, borrar la sección, o dejarla. Lo que aparece
siempre —y por eso vale nombrarlo, como ejemplo de la regla y no como sustituto de
ella—:

| Archivo                                  | Qué suele sobrar sin esa capacidad                                                          |
| ---------------------------------------- | ------------------------------------------------------------------------------------------- |
| `README.md`                              | Requisito de base de datos, paso de migraciones, puerto, fila de deployment                 |
| `.env.example`                           | **Bloques enteros**: base de datos, autenticación, IA, servicios transversales, otras APIs  |
| `docs/conventions/definition-of-done.md` | La sección «Interfaces y datos»: API, migraciones reversibles, revisión de esquema          |
| `docs/conventions/deploy.md`             | Healthcheck, si no hay servicio que consultar                                               |
| `docs/conventions/workflow.md`           | **Sin interfaz, usa su variante** (pasos 2, 4, 5 y 6) — está escrita en el propio documento |
| `docs/architecture/stack.md`             | Las filas de la tabla que no apliquen; son categorías, no obligaciones                      |
| `docs/architecture/database.md`          | La sección «Aislamiento entre inquilinos», si el producto no es multi-tenant                |
| `docs/architecture/auth.md`              | Las filas de actores sin cuenta, si todos los actores se autentican                         |
| `docs/marco-tecnico-infraestructura.md`  | **Las CIFRAS, no el documento** — ver abajo                                                 |

**Cuidado con estas: no fallan ningún check.** El placeholder se rellena con «ninguna»,
la sección queda absurda y todo pasa en verde. Un `README.md` mandando instalar
PostgreSQL en un producto sin base de datos es exactamente así de silencioso.

#### La infraestructura se hereda; los precios, no

`marco-tecnico-infraestructura.md` **se queda siempre**: es cómo se opera el proyecto
—por dónde se toca cada servicio, con qué credencial, quién hace qué— y eso vale desde
el primer día.

Lo que **no** se hereda son sus cifras. Un proyecto que arrastra los precios de la
plantilla presenta como suyo un presupuesto de otra fecha: plausible y falso, la familia
de errores más cara de este repositorio.

Al instanciar: **deja las cifras como pendientes** y pon la cabecera en
`**Fecha de verificación**: [FECHA] <!-- pendiente: sin verificar para este proyecto -->`.
Después corre **`/actualizar-costos`**, que las rellena con los precios del día. Así el
proyecto nace sabiendo qué infraestructura tiene y cuánto le cuesta **hoy**, no lo que
le costaba a otro.

Poda además las filas de servicios que este producto no usa: sin móvil no hay Apple
Developer ni servicio de builds; sin pagos no hay pasarela.

#### El caso «CERO variables de entorno»

La fila de `.env.example` dice «poda bloques». Falta decir qué hacer cuando **se podan
todos**: un producto sin servidor, sin build y con la clave viviendo en el navegador de
quien lo usa (BYOK) no tiene ni una variable. Pasa, y no es raro.

- **Conserva el archivo, vacío pero con su explicación**: por qué no hay ninguna y
  cuándo las habrá (la fase con servidor llega). Un archivo vacío a secas se lee como
  un olvido, y alguien lo rellenará a ojo.
- **Y quita del `README.md` estas dos líneas**, que **no son placeholders** y por tanto
  ningún check las reclama:

  ```bash
  cp .env.example .env                  # completa los valores; nunca lo commitees
  [COMANDO_MIGRACIONES]
  ```

  Sin variables y sin migraciones, mandan ejecutar cosas que no existen. Es la misma
  familia que la fila del `README.md` de arriba: instrucciones plausibles y falsas.

### El resto de la poda

- **Móvil (Expo)** → conserva `design/` y `docs/marco-tecnico-movil.md`, y en
  `conventions/deploy.md` **quédate con la sección «Si el producto es una app móvil» y
  borra las de servidor** (ambientes, procedimiento, rollback, health check): no se
  «reenfocan», se sustituyen, porque en móvil el rollback no existe. Conserva también
  la sección de sincronización sin conexión de `architecture/database.md` si la app
  escribe sin señal. **Sin móvil, borra `docs/marco-tecnico-movil.md`.**
- **Si hay UI, conserva SIEMPRE `design/`** — es la referencia visual que evita que las
  vistas salgan genéricas.
- `specs/` arranca **vacío** (solo `_template/`); borra cualquier spec heredada.
- **Los tags heredados se borran.** Si el repositorio conserva el historial de la
  plantilla, arrastra también sus tags (`git tag -l`). Un proyecto nuevo con un
  `v0.1.0` ajeno confunde a `check-release.sh`, que lo daría por publicado, y a
  `release.yml`, que no volvería a cortar esa versión: `git tag -d $(git tag -l)`.
- **El CHANGELOG pierde las VERSIONES de la plantilla, no su `## [Unreleased]`.** Borra
  las secciones `## [X.Y.Z]` heredadas —son la historia de la plantilla, no la del
  proyecto— y deja bajo `Unreleased` **una viñeta con el arranque**. No es un detalle:
  sin ella, `check-changelog.sh` bloquea el PR del Paso 5 por no traer ninguna, y
  `/release` se detiene porque no hay nada que cortar. Esa entrada se convierte en la
  `v0.1.0`. **Y borra las referencias del pie** —`[Unreleased]: …/compare/…`— que
  apuntan a los releases de la plantilla: no las ve `check-links.sh` porque son URLs
  absolutas, y si se quedan, el CHANGELOG del proyecto enlaza al historial de otro
  repositorio. `/release` las reescribe con la URL correcta la primera vez que corte.
  **Reescribe también el párrafo de atribución de la cabecera**: debe decir que el
  proyecto parte de la plantilla `brayandiazc/project-starter-template-es-ai` (con enlace) y que el
  historial anterior vive allí — tal cual está, habla de la plantilla en primera
  persona.
- **Los ADRs de la plantilla se retiran.** Conserva `0000-template.md` y
  `0001-record-architecture-decisions.md` (el ADR canónico sobre por qué se registran
  las decisiones, que aplica a cualquier proyecto) y borra el resto: son decisiones que
  tomó la plantilla, no este proyecto. Actualiza el índice de
  `docs/decisions/README.md`. Lo heredado queda documentado en el ADR de instanciación
  del Paso 5, que enlaza al repositorio origen para el detalle.
- Borra los archivos exclusivos del repo-plantilla: `TEMPLATE-USAGE.md`,
  `RENOMBRADOS.md` (es la bitácora de renombrados DE LA PLANTILLA;
  `/actualizar-plantilla` la lee por URL del repositorio origen, así que la copia local
  no hace falta) y esta misma skill (`.claude/skills/instanciar/`, incluido este
  archivo). El job `herencia` de `quality.yml` lo verifica: mientras
  `TEMPLATE-USAGE.md` exista, `check-placeholders.sh` cree que el repo sigue siendo la
  plantilla.
- Pregunta antes de borrar en bloque si hay ambigüedad.

### Cierra la poda limpiando enlaces

```bash
bash .github/scripts/check-links.sh
```

**Podar rompe enlaces, siempre.** En un arranque real fueron 12 en cuatro archivos. Y
**`AGENTS.md` se rompe garantizado**: es el índice único, apunta a todos los documentos,
así que cualquier poda lo toca. Los otros habituales son
`docs/architecture/architecture.md`, `docs/conventions/README.md` y
`definition-of-done.md`. En las tablas de índice se borra la fila; en el texto corrido,
el enlace pasa a texto plano. No termines el paso hasta que el check salga limpio.

## Paso 4 — Las dos pasadas de relleno

En modo instancia (tras borrar `TEMPLATE-USAGE.md` en el Paso 3),
`check-placeholders.sh` lista **archivo y línea** de cada pendiente, y son **dos listas
distintas**:

- **Placeholders** `[MAYÚSCULAS]` — valores por sustituir. Unos 140 en un arranque real.
- **Huecos de documentación** en prosa (`[Un párrafo describiendo…]`, `[Qué
representa]`) — párrafos por escribir. Otros ~160, y durante mucho tiempo no los veía
  nadie: un roadmap íntegramente en blanco pasaba en verde. Aparecen sobre todo en
  `product-definition.md`, `database.md` y `auth.md`.

**El arranque real son unos 330 elementos**, no 170. Dilo desde el principio en vez de
descubrirlo a mitad.

### El alcance de la pasada NO es «todo el repositorio»

**Antes de sustituir nada, pide la lista de archivos:**

```bash
bash .github/scripts/check-placeholders.sh --rutas-sustituibles
```

Esas son las rutas donde un placeholder es un valor por sustituir, y **solo esas**. Fuera
quedan `.github/scripts/`, `.github/workflows/`, `.claude/`, `CHANGELOG.md` y las tres
plantillas internas (`specs/_template/`, `docs/decisions/0000-template.md`,
`docs/conventions/_template.md`). En un script un placeholder es **dato de prueba o texto
explicativo**; en una plantilla interna es lo único que la hace útil. Sustituirlo lo
destruye.

No lo deduzcas ni lo negocies: la lista sale de la misma constante `SKIP` que usan los
dos modos del check, así que no se puede desincronizar. Canalízala:

```bash
bash .github/scripts/check-placeholders.sh --rutas-sustituibles \
  | xargs perl -pi -e 's/\[NOMBRE_DEL_PROYECTO\]/Registro de Turnos/g'
```

Y ojo con la tentación de excluir `.github/` entero: `.github/ISSUE_TEMPLATE/config.yml`
**sí** lleva `[URL_REPOSITORIO]` y **sí** debe sustituirse. Por eso está en la lista y los
scripts no.

**Qué pasa si te lo saltas** (pasó, y no se vio hasta mucho después):

| Daño                                                    | Cuándo se cobra                                                                                                                                                                                                   |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Los `printf` que fabrican los repos de prueba del banco | En el `pre-push` siguiente: 3 tests en rojo, uno con una URL real en su propio nombre                                                                                                                             |
| `specs/_template/proposal.md`                           | **Semanas después**, y en otro sitio: `spec-guardrails` compara cada spec contra su plantilla. Con la plantilla ya sustituida, acusa de «sin rellenar» la línea que sí lo está — y bloquea toda edición de código |

**Cierra la pasada corriendo el banco**, no lo dejes para el `pre-push`:

```bash
bash .github/scripts/tests/run-tests.sh
```

Ahí el daño se ve en el momento, no quince pasos después.

### Primera pasada, por valor

**Solo con los GLOBALES.** Agrupa los pendientes por placeholder, pregunta (o infiere)
una sola vez cada uno y sustituye en las rutas de arriba, de golpe. Dos arranques reales
dieron casi el mismo reparto —135 apariciones / 49 valores el primero, 141 / 52 el
segundo— y en los dos, **tres
placeholders fueron la mitad**: `NOMBRE_DEL_PROYECTO` (34–36 veces), `FECHA` (17–19) y
`EMAIL_SOPORTE` (16). Medido: **20 valores resolvieron entre el 70% y el 77%** de las
apariciones sin abrir un documento a decidir. Los que más rinden: identidad (nombre,
autor, GitHub, emails, URL del repositorio), stack (runtime, gestor, puerto) y los
`COMANDO_*`.

**Un placeholder es global cuando tiene UNA respuesta para todo el repositorio.** Los
que no la tienen son **posicionales**: significan algo distinto en cada aparición, y
sustituirlos en bloque produce documentos plausibles y falsos. Nunca entran en la
primera pasada:

| Posicionales                                       | Por qué                                      |
| -------------------------------------------------- | -------------------------------------------- |
| `VERSION`                                          | Es la versión de una pieza distinta cada vez |
| `ELEGIDA`, `DESCARTADA`, `ALTERNATIVA`             | Los lados de una comparación, uno por tabla  |
| `COMPONENTE_*`, `ENTIDAD_*`, `SERVICIO_*`, `ROL_*` | Son cosas distintas por definición           |
| `PLAN_*`, `PRECIO`, `PORCENTAJE`                   | Una fila por plan                            |
| `LOCALE_*`, `LAYOUT_*`, `RUTA_*`                   | Uno por idioma, por layout, por carpeta      |

Esto no es teórico: en el segundo arranque `VERSION` se sustituyó en bloque y
`docs/architecture/stack.md` quedó con cuatro filas diciendo `22` —incluida
«PostgreSQL 22» en un producto sin base de datos— y una desviación inventada
«Next.js → Astro» con el porqué vacío. Lo de PostgreSQL canta; **lo de la desviación
no, y eso es lo peligroso**: queda ordenado, plausible y falso.

Regla rápida cuando dudes: **si el mismo placeholder aparece dos veces en el mismo
archivo, es posicional**. Un valor global no necesita repetirse dentro de un documento
más que por copia literal.

### El nombre del producto no es el slug del repositorio

`NOMBRE_DEL_PROYECTO` es el nombre que se lee («Registro de Turnos»). `SLUG_REPOSITORIO` es
el del repositorio (`turnos-app`). Los dos son globales —la regla de arriba no los
separa— y coinciden solo cuando el repositorio se llama igual que el producto. La
entrevista ofrece un nombre-clave en su primera pregunta, así que divergir es lo normal.

> **Un nombre de producto nunca va en una URL, una ruta ni un comando.** Ahí va el slug.

**Comprueba la primera pasada** buscando el valor recién sustituido dentro de URLs, rutas
y comandos:

```bash
grep -rnE '(https?://[^ )]*|`?cd |repos/|git clone )[^ )]*Registro de Turnos' --include='*.md' .
```

Debe salir vacío. Un nombre con espacios o mayúsculas canta ahí; sin esta comprobación
quedan un badge roto (se ve) y un `cd Registro de Turnos` con un
`gh api repos/…/Registro de Turnos/…` (no se ven, hasta que alguien los ejecuta).

**Segunda pasada, por archivo.** Los posicionales y lo que quede —casi todo de una sola
aparición— necesita leer su contexto: componentes de la arquitectura, entornos de
despliegue, layouts, rutas. Aquí se abre cada documento y se decide.

### Lo que no se puede rellenar todavía

NO inventes datos. Si no puedes inferir un valor, **deja el placeholder y márcalo en su
misma línea**:

```markdown
- **Email de seguridad**: [EMAIL_SEGURIDAD] <!-- pendiente: aún sin buzón -->
```

Cuando la sección es **prosa y no tiene placeholder que dejar** —«cómo llegan los
primeros diez», «la métrica diaria»—, escribe una frase corta y la marca. **No inventes
un placeholder nuevo**: uno que no esté en el catálogo hace fallar el modo plantilla.

```markdown
- Sin definir todavía <!-- pendiente: no hay canal identificado -->
```

**Si el mismo dato falta en TODO el repositorio** —el buzón del cliente, el dominio sin
contratar—, no lo marques línea por línea: decláralo una vez en `.pendientes`, en la
raíz. Un dato como `EMAIL_SOPORTE` aparece muchas veces, y algunas caen en archivos que
se publican como páginas del producto: ahí no van comentarios HTML.

```
EMAIL_SOPORTE=el cliente aún no da el buzón
```

El check los acepta en cualquier archivo y los lista aparte, en un solo sitio para
reclamárselos a quien los debe.

La marca no es cosmética: en modo instancia el check exige que no quede ninguno sin
marcar. Sin marca, el primer PR sale en rojo; marcados, pasan y **quedan listados en
cada ejecución** para que no se vuelvan permanentes por inercia. Es **por línea**, no
por archivo.

> Es normal que la mitad de «salida al mercado» quede pendiente: canal, precio mínimo,
> costos y métrica diaria salen de los bloques 5, 7 y 8 de la entrevista, y esas
> respuestas **no existen todavía** al arrancar. Se cierran después de ver el prototipo.

### `.template-origin`, campo por campo

```
repo=<URL de esta plantilla>
commit=<SHA del HEAD de la plantilla usado como base>
fecha=<YYYY-MM-DD de hoy>
versiones=<versiones del CHANGELOG de la plantilla, separadas por coma — p. ej. 0.3.0,0.2.1,0.2.0,0.1.0>
```

`versiones` le da a `check-inheritance.sh` un criterio exacto para detectar el CHANGELOG
heredado: sin ella, el check cae al criterio por fecha, que no distingue una versión de
la plantilla de un release propio cortado el mismo día de instanciar. Sácalas con:

```bash
grep -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md | tr -d '#[] ' | paste -sd, -
```

## Paso 5 — Antes de cortar la primera versión

**Verifica contra el remoto, no contra tu clon.** `git tag -l` sale vacío hasta que
haces `fetch`, así que da un falso negativo justo en la comprobación que importa:

```bash
git fetch --tags --prune-tags origin
git ls-remote --tags origin     # debe estar vacío
gh release list                 # debe estar vacío (incluye borradores)
```

Si aparece algo, es de la plantilla. Bórralo antes de seguir, y en este orden:

```bash
gh release delete vX.Y.Z --yes
git push origin :refs/tags/vX.Y.Z
git tag -d vX.Y.Z
```

Dos detalles que cuestan un rato si no los sabes: al borrar el tag primero, GitHub
**convierte el release en borrador** en vez de eliminarlo, y un borrador no sale en
`gh release list` por defecto — queda invisible. Y el tag local puede estar duplicado
(suelto y en `packed-refs`), así que `git tag -d` puede hacer falta dos veces.

## Paso 6 — Activar el CI del código

1. Renombra `.github/workflows/ci.yml.example` → `ci.yml` (mientras la extensión sea
   `.example` GitHub no lo parsea, así que hasta ahora no corría nada del código).
2. Reemplaza los `[COMANDO_*]` por los comandos reales del preset elegido, que ya están
   en `docs/architecture/stack.md` y en `AGENTS.md` (setup, lint, test, build).
   Descomenta los `services` (base de datos) y el paso de entorno si el stack los
   necesita; borra el job `build` si no aplica (p. ej. una app sin paso de build).
3. **Borra la cabecera de activación** (el bloque marcado `⚠️ BORRA ESTE BLOQUE`). Son
   instrucciones para llegar aquí; si se quedan, el `ci.yml` del proyecto abre mandando
   renombrar un archivo que ya se renombró. El bloque de «por qué un solo job» sí se
   queda: explica una decisión vigente.
4. Verifica que pase antes de abrir el PR. Un CI en rojo desde el primer día se
   normaliza y deja de mirarse.

Sin este paso el proyecto llega a la v1 con un CI que solo valida Markdown, mientras
`docs/conventions/definition-of-done.md` exige pruebas — la disciplina del proceso
existiría y la del código no.
