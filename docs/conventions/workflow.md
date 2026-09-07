# Flujo de trabajo (SDD + agentes)

> Cómo se trabaja en los proyectos de esta plantilla: desarrollo guiado por
> especificaciones (SDD) con agentes de IA acompañando cada fase. El objetivo es que
> una persona sola avance rápido **sin perder robustez**: siempre hay quien pregunta,
> quien planifica y quien revisa.
> **Última actualización**: 2026-08-01

## El ciclo

```
1. DEFINIR      → /definir-producto                     → docs/product/
2. ELEGIR STACK → /instanciar + docs/marco-tecnico.md   → docs/architecture/stack.md
3. ESPECIFICAR  → architect (+ /new-spec)               → specs/<cambio>/
4. IMPLEMENTAR  → desarrollo con IA, spec en mano       → código + tests (test-author)
5. REVISAR      → /code-review + security-reviewer      → antes de cada PR
6. DOCUMENTAR   → doc-keeper (+ /changelog, /new-adr)   → docs/, CHANGELOG y roadmap
7. MEDIR        → métricas de producto y criterio de "v1 lista"
        └──────────────── vuelve a 1 con lo aprendido ────────────────┘
```

Las fases 1–2 se hacen una vez por proyecto (y se revisitan); 3–6 se repiten por cada
cambio no trivial; 7 marca los cortes de versión.

## Sprint de definición (Design Sprint exprés)

La fase DEFINIR no es solo documentos: es un **Design Sprint adaptado a una persona +
IA**, comprimido a horas en vez de 5 días porque la IA produce los artefactos en el
momento. Se corre al arrancar el proyecto (y en versión mini ante cada feature grande):

| Paso          | Qué se hace (contigo + IA)                                                                                                                           | Artefacto que queda                                                  |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| 1. Entender   | Entrevista de `/definir-producto` con el banco literal de [`../product/interview.md`](../product/interview.md)                                       | `docs/product/` (definición + negocio)                               |
| 2. Mapear     | Flujo del usuario de punta a punta y **lista de vistas** (ver catálogo estándar abajo)                                                               | Mapa en `docs/architecture/pantallas.md`                             |
| 3. Decidir    | Modelo de datos preliminar + **integraciones necesarias** (auth/login con Google, storage, pagos, emails)                                            | Borradores de `database.md` y `auth.md`; stack elegido en `stack.md` |
| 4. Vestir     | **Identidad visual del producto** — `/identidad` propone direcciones, las escribe en `tokens.css` y se deciden viéndolas aplicadas en `preview.html` | Paleta y tipografía propias + ADR con lo descartado                  |
| 5. Prototipar | **Vistas estáticas navegables** con el design system de `design/` (HTML/ERB sin lógica) — agente `designer` + `/prototipo`                           | Prototipo en el repo — sirve de referencia visual y luego se conecta |
| 6. Validar    | Recorrer el prototipo contra el recorrido crítico; enseñarlo a 2–3 personas si se puede                                                              | Ajustes a la definición; luz verde para especificar                  |

### Si el producto no tiene interfaz

Cuatro de los seis pasos hablan de vistas, así que una CLI, un worker o una librería
necesitan su variante — que **no es saltárselos**: es hacer lo mismo con el artefacto que
sí tiene ese producto.

| Paso          | Con interfaz                     | Sin interfaz                                                                                         |
| ------------- | -------------------------------- | ---------------------------------------------------------------------------------------------------- |
| 2. Mapear     | Lista de vistas → `pantallas.md` | **Superficie de la herramienta**: comandos, flags, entradas y salidas → sección de `architecture.md` |
| 4. Vestir     | Identidad visual                 | Se salta                                                                                             |
| 5. Prototipar | Vistas estáticas navegables      | **Salida de ejemplo**: se produce a mano el artefacto que la herramienta va a generar                |
| 6. Validar    | Recorrer el prototipo            | **Abrir el artefacto**: ¿sirve tal cual? ¿lo usarías?                                                |

Reglas del sprint:

- **Estático antes que funcional**: las vistas se construyen primero sin lógica —
  validan el flujo y el diseño baratísimo, y después se les conecta el backend
  (el prototipo no se tira, se convierte).
- **Sin interfaz, la misma regla se llama _la salida antes que el motor_**: se maqueta a
  mano el archivo que la herramienta debería producir —el `.pptx`, el informe, el JSON— y
  se mira si sirve, **antes** de construir lo que lo genera. Es igual de barato de tirar
  y responde la misma pregunta que un prototipo: si el resultado no convence, el motor
  sobra.
- **Decidir integraciones aquí**, no a mitad del desarrollo: qué auth (¿login con
  Google?), qué storage, si hay pagos en v1 — cada una tiene su default en
  [`../marco-tecnico.md`](../marco-tecnico.md) §2.
- El sprint termina con algo que se puede **clicar y criticar**, no con un documento
  más.
- **`/instanciar` es EL comando de arranque** (único punto de entrada): prepara las
  ramas, encadena el sprint completo (definición → preset → placeholders → primera
  spec) y deja el prototipo para la rama siguiente.

### Ramas del arranque

El arranque produce dos ramas en secuencia, ambas nacidas de `develop` (que se crea
desde `main` si no existe — `main` queda solo para producción):

```
main ──► develop ──► docs/arranque ──(PR → develop)──► feat/<primera-spec>
                     rama 1: toda la                   rama 2: scaffolding del stack
                     documentación del sprint          + prototipo, guiados por la spec
```

Primero se fusiona la documentación en `develop`; **después** nace la rama que genera
el proyecto de software (dependencias, esqueleto, vistas). El hook
`git-guardrails.sh` impide crear ramas de trabajo desde `main`.

Dos reglas de repositorio acompañan el flujo:

- **`develop` es la rama por defecto en GitHub** (PRs nuevos y Dependabot apuntan
  ahí) — `/configurar-repo` la establece.
- **Cada merge `develop` → `main` publica un release**: se corta la versión en el
  CHANGELOG con `/release` (que además sincroniza la versión del manifiesto del stack,
  si lo hay) y el workflow `release.yml` crea el tag y el release de GitHub
  automáticamente. El primer merge (la documentación del arranque) publica la `v0.1.0`
  del proyecto — ningún paso a producción queda sin versión, y el job `release` de
  `quality.yml` lo verifica: bloquea el PR a `main` si la versión de arriba del
  CHANGELOG ya está publicada o si quedan entradas sueltas en `## [Unreleased]`.
  Los `hotfix/*` cortan su propio `patch` antes del PR a `main` (ver
  [`../../CONTRIBUTING.md`](../../CONTRIBUTING.md)).

### Catálogo estándar de vistas (paso 2)

Todo producto web parte de este inventario y añade las vistas propias de su recorrido
crítico — así ninguna se descubre a mitad del desarrollo:

- **Públicas**: landing/home, precios (si hay pago), sobre/about, contacto, 404, 500.
- **Legales**: términos, privacidad, cookies. La plantilla no trae estos textos — se
  redactan por producto.
- **Auth** (si hay cuentas): login, registro, recuperar contraseña, verificación.
- **App**: dashboard/inicio, la(s) vista(s) de la acción de valor, ajustes/cuenta,
  facturación (si hay pago).

La skill `/prototipo` construye estas vistas en estático con el design system de
`design/` (modo claro/oscuro y es/en desde el inicio). La misma regla aplica a cada
spec posterior que toque UI: su `design.md` enlaza un prototipo HTML de referencia
(en móvil la maqueta sirve de spec de **contenido y jerarquía**, no de layout ni
navegación: tabs en vez de sidebar, área táctil de 48 dp, safe areas, y pantallas
propias como onboarding, permisos y sin conexión).

## Antes de la spec: ¿esto merece existir?

Una spec fija **cómo** se construye algo. La pregunta de si merece construirse es
anterior, y se responde con [`product-coach`](../../.claude/agents/product-coach.md) —
que puede delegar en `product-researcher` para traer evidencia de fuera.

Lo que salga de ahí se guarda: lo reutilizable en
[`docs/product/discovery.md`](../product/discovery.md), lo propio de esa decisión en el
`proposal.md` de la spec. **Saltarse este paso no ahorra tiempo, lo mueve**: aparece
después, como una funcionalidad terminada que nadie usa.

## Reglas críticas (el "qué manda sobre qué")

1. **La definición de producto manda sobre el backlog.** Nada se implementa si no
   está dentro de la v1 definida en
   [`../product/product-definition.md`](../product/product-definition.md) — y si algo
   nuevo parece urgente, primero pasa por `product-coach` (¿entra?, ¿qué sale a cambio?).
2. **Pregunta antes de asumir.** En cualquier fase, ante ambigüedad real (alcance,
   prioridad, trade-off de negocio) se pregunta a la persona — decisiones reversibles
   de implementación no; decisiones de producto sí.
3. **Sin spec no hay cambio — obligatorio.** Toda funcionalidad o corrección
   (`feat/*`, `fix/*`) nace en [`../../specs/`](../../specs/README.md)
   (proposal → design → tasks), con rama y spec compartiendo slug. La spec es el
   contrato entre la idea y el código, y lo que permite delegar en agentes sin
   deriva. No es opcional: el hook `spec-guardrails.sh` bloquea editar código en
   esas ramas mientras no exista su spec **y** `proposal.md` conserve líneas de
   plantilla sin rellenar — una carpeta vacía no es una spec.
4. **Sin revisión no hay merge.** `/code-review` sobre el diff y, si toca entrada de
   usuario, auth, datos o llamadas externas, el subagente `security-reviewer`, que
   conoce las cuatro áreas que fallan en silencio (`SECURITY.md`). Los hallazgos
   bloqueantes se resuelven antes del PR.
5. **Nada sin documentar.** Todo cambio → CHANGELOG + docs afectados **en el mismo
   PR** que el código (`doc-keeper`); decisiones difíciles de revertir → ADR; specs
   que toquen datos, pagos o terceros → revisan también si cambian los textos
   legales del producto. Un cambio sin documentación **no está
   terminado** (es regla estricta de `AGENTS.md`), y el job `changelog` de
   `quality.yml` lo verifica en cada PR: sin entrada bajo `## [Unreleased]`, el CI
   falla. La excepción se pide explícitamente con la label `sin-changelog`.
6. **El roadmap se mueve con las specs, no con las buenas intenciones.** La spec
   declara qué ítem de [`../product/roadmap.md`](../product/roadmap.md) completa
   (campo _Ítem de roadmap_ en `proposal.md`) y el PR que la implementa lo marca
   como hecho. Roadmap, CHANGELOG y código viajan en el mismo commit-set: el estado
   del producto es lo que está fusionado, no lo que se prometió.
7. **La IA administra el repositorio.** Descripción, topics, labels, ramas, issues,
   PRs y releases se gestionan con las skills (`/configurar-repo`, `/open-issue`,
   `/open-pr`, `/release`) — la persona decide, la IA opera y deja rastro.

## Quién es quién

| Fase        | Agente / skill                                            | Qué garantiza                                      |
| ----------- | --------------------------------------------------------- | -------------------------------------------------- |
| Definir     | `/definir-producto`, `product-coach` (guarda el alcance)  | Alcance acotado, prioridades claras                |
| Vestir      | `/identidad`                                              | Paleta y tipografía del producto, decididas viendo |
| Prototipar  | `designer`, `/prototipo`                                  | Vistas fieles al design system, clicables          |
| Especificar | `architect`, `/new-spec`                                  | Plan fundamentado antes de tocar código            |
| Implementar | sesión principal + `debugger`                             | Código alineado a spec y convenciones              |
| Probar      | `test-author`                                             | Camino feliz + bordes cubiertos                    |
| Revisar     | `/code-review`, `security-reviewer`                       | Correctitud, seguridad, sin secretos               |
| Documentar  | `doc-keeper`, `/changelog`, `/new-adr`                    | Docs, CHANGELOG y roadmap al día                   |
| Medir       | `metrics-analyst`                                         | Eventos del recorrido crítico; datos → decisiones  |
| Operar repo | `/configurar-repo`, `/open-issue`, `/open-pr`, `/release` | GitHub gestionado por IA con rastro                |

## Trabajo con IA: patrones que usamos

- **Especificación como ancla (SDD)**: los agentes trabajan contra la spec, no contra
  la memoria de la conversación — eso permite paralelizar y retomar sin contexto perdido.
- **Loops con verificación**: implementar → correr tests/lint → corregir → repetir;
  el agente no declara "listo" sin evidencia verde (ver
  [`definition-of-done.md`](definition-of-done.md)).
- **Paralelización por independencia**: trabajos independientes (explorar + testear,
  varios módulos de una migración) se lanzan como subagentes en paralelo; trabajos
  dependientes, en secuencia. Nunca dos agentes editando lo mismo.
- **Revisión adversarial**: el que revisa no es el que escribió — el reviewer entra
  con contexto limpio y órdenes de encontrar problemas, no de validar.
- **Guardrails deterministas**: lo que no debe pasar nunca (push a main, ramas
  nacidas de main, commitear secretos, código sin spec) lo bloquean hooks
  (`.claude/hooks/`, activos por defecto), no promesas del modelo. Lo que el hook no
  puede ver hasta el final del trabajo (¿quedó entrada en el CHANGELOG?) lo verifica
  el CI en el PR — dos capas, ninguna basada en la memoria del agente.

## Anti-patrones

- Implementar directo desde una idea conversada sin spec ("lo tengo fresco").
- Saltarse la revisión porque "es un cambio chico" (los chicos son los que rompen).
- Dejar que el backlog crezca sin pasar por la definición de producto.
- Pedirle al mismo agente que implemente y se apruebe a sí mismo.
