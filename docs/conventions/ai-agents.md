# Convención de agentes de IA

> Cómo se trabaja con agentes de codificación aquí, dado que **la revisión es de
> resultados, no de código**. Se deriva de los dos principios de
> [`../marco-tecnico.md`](../marco-tecnico.md) §1 — léelos primero.
> **Última actualización**: 2026-09-04

## Fuente de verdad

- [`AGENTS.md`](../../AGENTS.md) es el archivo de instrucciones canónico para cualquier
  agente. [`CLAUDE.md`](../../CLAUDE.md) es un puente de una línea que lo importa
  (Claude Code lee `CLAUDE.md`; otras herramientas leen `AGENTS.md`).
- Los [subagentes](../../.claude/agents) y las [skills](../../.claude/skills) están
  versionados en el repo.
- **Cada subagente declara su modelo**, aunque sea para heredar el de la sesión
  (`model: inherit`). `check-skills.sh` lo exige: sin el campo, un subagente pesado
  acaba corriendo con un modelo caro que nadie decidió. La plantilla los deja todos en
  `inherit` a propósito — el reparto depende de tu plan, no de esta plantilla.

  **El criterio para subir o bajar de modelo no es «cuál es más listo»** (el más listo
  siempre lo es), sino **qué pasa cuando ese subagente falla**:

  | Si su fallo…                                        | Entonces       |
  | --------------------------------------------------- | -------------- |
  | Se ve en la pantalla, o lo caza un check            | Puedes ahorrar |
  | Pasa todos los checks en verde y llega a producción | No ahorres     |
  | Condiciona todo lo que se construya después         | No ahorres     |

  En una línea: **si el error se detecta solo, ahorra; si se detecta tarde o no se
  detecta, no.** Por eso `designer` puede ir en un escalón medio aunque escriba mucho
  código —su error se ve— y `doc-keeper` no, aunque solo escriba Markdown: una
  documentación desincronizada pasa todos los checks.

  Y un caso que ese criterio no cubre, porque invita a gastar de más: cuando el fallo
  de un subagente es **ser permisivo** —decir que sí a algo que debía recortar— un
  modelo más capaz no ayuda. La capacidad extra sirve donde el problema es **duro**, no
  donde el problema es **mantenerse en tus trece**. Eso se arregla con un prompt más
  claro, no con más presupuesto.

- **La documentación prevalece sobre los defaults del modelo.** Ante conflicto entre lo
  que dice `docs/` y lo que el agente "sabe", gana `docs/`.

## Cómo se verifica, si no se revisa código

Tres capas. **Ninguna es opcional** — juntas sustituyen a la revisión línea por línea.

### Capa automática

- **Tests** — aquí no son buena práctica, son **infraestructura**: son la parte de la
  revisión que se ejecuta sola. Ver [`testing.md`](testing.md).
- **El monitor de errores** — lo que avisa de que algo se rompió en producción.
- **Uptime + panel de jobs** — los fallos en background son los que más se esconden.

### Capa de inspección

- **Panel de administración** — permite ver el estado real de la aplicación sin leer
  código. En este esquema vale mucho más de lo que parece; no es un extra.

### Capa humana — el mínimo que sí se revisa a mano

**El esquema de base de datos.** Es poco (una migración, un `schema.rb`), es lo más caro
de cambiar después, y es lo único que **ni los tests ni el monitoreo detectan**: un
modelo de datos mal pensado pasa todos los tests y no genera un solo error en el monitor.
La regla completa está en [`../marco-tecnico.md`](../marco-tecnico.md) §4.5.

> **Una persona es responsable de cada merge.** No implica leer cada línea; implica que
> nadie más carga con el resultado.

## Dónde falla el agente — checklist de riesgo

### Falla en silencio (riesgo alto)

Sale bien a la vista y mal por dentro. Esto es lo que hay que mirar de verdad.

| Área                      | Qué revisar                                                                                                                                                                     |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Componentes UI custom** | Donde el stack no tenga una capa headless que lo resuelva: focus trap, tecla Escape, ARIA, navegación por teclado. Son pocos en toda la app y se reutilizan — merecen revisión. |
| **Autorización**          | Políticas que parecen correctas con huecos. Probar con roles distintos, no solo con el propio.                                                                                  |
| **Concurrencia**          | Aislamiento, deadlocks, locks. Camino feliz correcto, borde mal.                                                                                                                |
| **Idempotencia**          | Sobre todo con colas y con móvil (ver marco §4.2, regla 4).                                                                                                                     |
| **Sincronía temporal**    | Si hay media: errores de un frame, deriva de timestamps. Pasan los tests y se ven mal en el resultado.                                                                          |

### Se desactualiza (riesgo medio)

**Verificar contra la documentación oficial, no contra el agente**: toda pieza de tu
stack que haya sacado una versión mayor en los últimos dos años, las herramientas de
despliegue, y los SDK de proveedores de IA (los que más rápido rompen su API).

No es que el agente las maneje mal — es que su conocimiento tiene más probabilidad de
estar viejo **sin que lo note**. Para esto está el MCP de Context7 (más abajo).

> Anota aquí las tuyas al elegir el stack. Una lista genérica no protege de nada: lo
> que protege es el nombre concreto de la librería que ya te generó sintaxis vieja.

#### Deriva de sintaxis — reglas de vigilancia

El caso más traicionero del riesgo anterior: piezas donde el corpus de entrenamiento
está dominado por una **versión vieja de la misma librería**, así que el agente genera
sintaxis obsoleta con total confianza y todo parece funcionar. Una regla escrita aquí
previene la mayoría; el resto lo detecta la revisión con esta tabla como checklist.

**La tabla que sigue son EJEMPLOS reales**, de stacks concretos, para que se vea la
forma que tiene una regla de vigilancia útil. **Bórralos y escribe los de tu stack** —
una fila sobre una librería que no usas es ruido, y la que te falta es el fallo.

| Pieza                                   | Deriva típica del agente                                                         | Regla                                                                                                                                                                           |
| --------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Tailwind v4**                         | Genera sintaxis v3: `tailwind.config.js`, `@tailwind base/components/utilities`  | Tokens vía `@theme` en CSS (ver [`design/`](../../design/README.md)). **No debe existir config en JS**: si el agente propone crear `tailwind.config.js`, es la deriva en acción |
| **SQLAlchemy 2.x** (stack FastAPI)      | Mezcla el estilo legacy 1.x: `session.query(...)`, modelos sin tipos             | Solo estilo declarativo 2.x: `select()`, `Mapped[]` + `mapped_column()`                                                                                                         |
| **Pydantic v2** (stack FastAPI)         | Usa la API de v1: `class Config`, `.dict()`, `@validator`                        | `model_config = ConfigDict(...)`, `.model_dump()`, `@field_validator`                                                                                                           |
| **Hono / Drizzle / Biome** (stack Node) | Corpus público pequeño y APIs jóvenes: inventa métodos plausibles que no existen | Verificar la firma contra Context7 antes de usar cualquier API no trivial; versiones **exactas** en `package.json` (sin `^`)                                                    |
| **Rails 8** (Solid Queue/Cache, auth)   | Propone las piezas de siempre por costumbre: Redis, Sidekiq, Devise              | Mandan los defaults de la versión vigente del framework. Traer la alternativa clásica no es un atajo: es una desviación y exige su ADR                                          |
| **better-auth** (stack Node)            | Librería post-2023: poco corpus, el agente cae a patrones de NextAuth/Auth.js    | Verificar toda firma con Context7. Vale para cualquier librería joven: la auth se revisa a mano igual (checklist de arriba)                                                     |
| **Vercel AI SDK** (stack Node)          | Rompe API entre versiones mayores (v4→v5 reescribió firmas); genera la vieja     | Versión exacta en `package.json`; verificar firmas con Context7 al subir de versión mayor                                                                                       |
| **Expo + NativeWind** (móvil)           | El SDK de Expo saca ~3 versiones/año; NativeWind es joven; mezcla APIs de épocas | Fijar la versión del SDK; verificar contra la doc de esa versión, no contra la memoria del agente                                                                               |

Al instanciar, borra las filas de los stacks que el producto no use y añade las tuyas
— igual que en [`../architecture/stack.md`](../architecture/stack.md).

### Debilidad estructural

- **Diseño visual sin dirección** → converge a plantilla de SaaS genérica. Por eso los
  tokens se definen fuera del agente, en [`design/`](../../design/README.md).
- **Optimización de queries** → escribe SQL correcto, no necesariamente rápido. Sin
  `EXPLAIN ANALYZE` es conjetura.
- **CSS a mano en volumen** → tiene estado global y el agente solo ve el fragmento que
  toca. Degradación acumulativa.

### Y nunca

- **Nunca le des secretos a un agente** (claves, tokens, `.env` real, datos de
  clientes). Ver [`secrets.md`](secrets.md) y [`../../SECURITY.md`](../../SECURITY.md).
- **Nunca dejes un cambio sin acotar.** Un cambio lógico por PR, sin reformateos ajenos
  a la tarea.

## El riesgo a mediano plazo

Con el agente escribiendo la mayoría del código y sin revisión de código, a los ~18
meses **nadie tiene el modelo mental del sistema**: ni tú (no lo escribiste) ni el
agente (no tiene memoria entre sesiones).

No duele en el mes 3. Duele cuando hay que cambiar algo estructural.

**Mitigación mínima** — las tres cosas que sí compensan el hueco:

1. Revisar el esquema de datos (arriba).
2. Mantener `AGENTS.md` al día con las decisiones y convenciones vivas del proyecto.
3. Documentar el **porqué** de las decisiones estructurales, no el qué. El qué está en
   el código; el porqué se pierde. Para eso son los [ADRs](../decisions/README.md).

## Atribución

Los commits asistidos por IA llevan trailer, para que la autoría sea transparente:

```
Co-Authored-By: Claude <noreply@anthropic.com>
```

## Memoria del agente vs. documentación

Algunas herramientas mantienen una **memoria persistente** por proyecto (p. ej. la
auto-memoria de Claude Code). Úsala solo para lo personal y efímero (preferencias,
correcciones recurrentes) y pódala con frecuencia. Todo conocimiento **duradero** —
decisiones, convenciones, contexto del dominio — pertenece al repositorio: `docs/`, los
ADRs de [`../decisions/`](../decisions/README.md) y el `CHANGELOG.md`.

Si un agente "recuerda" algo que el proyecto necesita saber, ese recuerdo está en el
lugar equivocado: conviértelo en documentación versionada.

## Cambios guiados por especificaciones (obligatorio)

**Sin spec no hay cambio** — la regla completa vive en
[`workflow.md`](workflow.md) (única copia; la garantiza el hook `spec-guardrails.sh`,
ver abajo). Para el agente, lo que importa es el porqué: la spec le da un objetivo
cerrado y un punto de revisión **antes** de que haya código que revisar.

## Servidores MCP (opcional)

Este repositorio incluye un [`.mcp.json.example`](../../.mcp.json.example) con tres
servidores recomendados y agnósticos al stack:

- **Context7** (Upstash) — obtiene documentación de librerías **actualizada y por
  versión**. Es la respuesta directa al riesgo "se desactualiza" de arriba. No requiere
  API key.
  Y dos **ejemplos** de la otra clase de MCP que sí se justifica —herramientas con un
  modelo de datos que consultar—, tal como vienen en `.mcp.json.example`. Sustitúyelos por
  los de tus proveedores o bórralos:

- **El monitor de errores**, para que los agentes consulten errores y stack traces del
  producto directamente. El servidor del ejemplo autentica por OAuth la primera vez que
  se conecta; sin token en archivos.
- **La herramienta de analytics**, para consultar métricas, feature flags y hacer
  consultas desde la conversación. El del ejemplo lee `ANALYTICS_PERSONAL_API_KEY` del
  entorno (una API key **personal**, no la del proyecto — documentada en
  `.env.example`).

Para activarlo, copia el archivo y reinicia Claude Code:

```bash
cp .mcp.json.example .mcp.json
```

Claude Code pide aprobación antes de usar cualquier servidor MCP del proyecto.

- **No** agregues servidores MCP para archivos, búsqueda o web — las herramientas
  integradas ya lo cubren.
- **Nunca** pongas secretos en `.mcp.json`. Referencia variables de entorno (p. ej.
  `${GITHUB_TOKEN}`) y documéntalas en `.env.example` (ver [`secrets.md`](secrets.md)).

> El mapa completo —cada servicio con su vía de acceso, su credencial, su dueño y el
> reparto entre agente y persona— vive en
> [`marco-tecnico-infraestructura.md`](../marco-tecnico-infraestructura.md). Aquí queda solo lo
> propio de la capa de infraestructura.

### MCP de infraestructura (DNS, CDN, servidor)

Aquí no hay recomendación de proveedor, pero sí un criterio que se repite en todos:

- **Si el proveedor publica un plugin o MCP oficial** (típico en DNS y CDN), úsalo: es
  donde más aporta, porque son paneles web que no dejan rastro en el repositorio.
- **Si solo tiene CLI**, úsala por Bash. Provisionar (crear servidor, firewall, redes)
  es un evento raro y acompañado: el token de escritura solo se usa entonces, y el resto
  del tiempo va **read-only**.
- **La administración del servidor día a día** (deploy, logs, contenedores) va **sin
  MCP**: `ssh` directo por Bash. Los MCP de SSH solo tienen sentido en clientes sin
  shell; aquí hay shell.

Cada uno de estos, con su credencial y su dueño, se anota en
[`marco-tecnico-infraestructura.md`](../marco-tecnico-infraestructura.md) §2.

## Guardrails deterministas (activos por defecto)

Las reglas de [`AGENTS.md`](../../AGENTS.md) le dicen al agente qué **debería** hacer,
pero no lo obligan. Para una garantía dura hay tres hooks que **bloquean de forma
determinista** — el agente no puede saltárselos — y vienen **activados en
`.claude/settings.json`**:

- [`.claude/hooks/git-guardrails.sh`](../../.claude/hooks/git-guardrails.sh) — bloquea
  lo que rompe el branching de [`../../CONTRIBUTING.md`](../../CONTRIBUTING.md):
  commits, merges locales o push directos a `main`/`develop`, force-push a ramas
  compartidas, y **crear ramas de trabajo desde `main`** (deben nacer de `develop`;
  únicas excepciones: crear la propia `develop` y las `hotfix/*`). Cubre también
  `git -C <ruta>`, los comandos encadenados con `&&` y los **scripts de varias
  líneas** — cada comando se juzga con SUS argumentos, no con los del siguiente. El
  **cuerpo de un heredoc no se analiza**: un mensaje de commit que mencione un
  `git push --force` no está haciendo ninguno.
- [`.claude/hooks/secret-guardrails.sh`](../../.claude/hooks/secret-guardrails.sh) —
  bloquea escrituras sobre archivos de secretos: el `.env` real (y variantes como
  `.env.local`) y llaves privadas (`*.pem`, `id_rsa`…). `.env.example` sí se puede
  editar: es el contrato, sin valores reales.
- [`.claude/hooks/spec-guardrails.sh`](../../.claude/hooks/spec-guardrails.sh) — hace
  cumplir "sin spec no hay cambio": en ramas `feat/*`/`fix/*` bloquea la edición de
  código mientras no exista `specs/NNNN-<slug-de-la-rama>/` **o su `proposal.md` siga
  siendo la plantilla**. Quedan exentos la documentación (`docs/`), las specs mismas, el
  tooling (`.claude/`, `.github/`) y el Markdown de la raíz.

Para desactivar alguno (no recomendado), elimina su bloque de `hooks.PreToolUse` en
`.claude/settings.json`. Requieren `python3`. Los tres fallan _abiertos_: ante la duda
permiten, para no trabar el flujo. Sus casos están probados en
`.github/scripts/tests/run-tests.sh` (corre en CI).
