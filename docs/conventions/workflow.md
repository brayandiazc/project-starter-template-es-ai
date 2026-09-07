# Flujo de trabajo (SDD + agentes)

> Cómo se trabaja en los proyectos de esta plantilla: desarrollo guiado por
> especificaciones (SDD) con agentes de IA acompañando cada fase. El objetivo es que
> una persona sola avance rápido **sin perder robustez**: siempre hay quien planifica y
> quien revisa.
>
> **Qué NO fija este documento**: qué construir ni con qué. El alcance del producto es
> tuyo y se documenta en [`../product/`](../product/roadmap.md); el stack es tuyo y se
> registra en [`../architecture/stack.md`](../architecture/stack.md). Aquí solo está el
> ciclo de trabajo, que es el mismo sea cual sea la respuesta a esas dos.
>
> **Última actualización**: [FECHA]

## El ciclo

```
1. ESPECIFICAR  → architect (+ /new-spec)         → specs/<cambio>/
2. IMPLEMENTAR  → desarrollo con IA, spec en mano → código + tests (test-author)
3. REVISAR      → /code-review + security-reviewer→ antes de cada PR
4. DOCUMENTAR   → doc-keeper (+ /changelog…)      → docs/, CHANGELOG y roadmap
5. PUBLICAR     → /release                        → versión cortada, tag y release
      └────────────── vuelve a 1 con lo aprendido ──────────────┘
```

Los pasos 1–4 se repiten en cada cambio no trivial; el 5 marca los cortes de versión.

## Antes de construir la interfaz

Si el producto tiene vistas, tres pasos se pagan solos **antes** de escribir lógica.
No es un método de producto: es el orden en que salen más baratos los errores de UI.

| Paso          | Qué se hace                                                   | Artefacto que queda                                            |
| ------------- | ------------------------------------------------------------- | -------------------------------------------------------------- |
| 1. Mapear     | Inventario de vistas (catálogo estándar abajo + las propias)  | [`../architecture/pantallas.md`](../architecture/pantallas.md) |
| 2. Vestir     | Identidad visual del producto — skill `/identidad`            | Paleta y tipografía en `design/tokens.css`                     |
| 3. Prototipar | Vistas estáticas navegables — agente `designer`, `/prototipo` | Prototipo en el repo, clicable                                 |

**Estático antes que funcional**: las vistas se construyen primero sin lógica —validan
el flujo y el diseño baratísimo— y después se les conecta el backend. El prototipo no se
tira, se convierte.

**Sin interfaz, la misma regla se llama _la salida antes que el motor_**: se maqueta a
mano el artefacto que la herramienta debería producir —el informe, el JSON, el archivo—
y se mira si sirve, **antes** de construir lo que lo genera. Es igual de barato de tirar
y responde la misma pregunta: si el resultado no convence, el motor sobra.

### Catálogo estándar de vistas

Todo producto web parte de este inventario y añade las vistas propias de su recorrido
crítico — así ninguna se descubre a mitad del desarrollo:

- **Públicas**: landing/home, precios (si hay pago), sobre/about, contacto, 404, 500.
- **Legales**: términos, privacidad, cookies. La plantilla no trae estos textos — se
  redactan por producto.
- **Auth** (si hay cuentas): login, registro, recuperar contraseña, verificación.
- **App**: dashboard/inicio, la(s) vista(s) de la acción de valor, ajustes/cuenta,
  facturación (si hay pago).

La skill `/prototipo` las construye en estático con el design system de `design/` (modo
claro/oscuro y es/en desde el inicio). La misma regla aplica a cada spec posterior que
toque UI: su `design.md` enlaza un prototipo HTML de referencia (en móvil la maqueta
sirve de spec de **contenido y jerarquía**, no de layout ni navegación: tabs en vez de
sidebar, área táctil de 48 dp, safe areas, y pantallas propias como onboarding, permisos
y sin conexión).

## Ramas del arranque

El arranque produce dos ramas en secuencia, ambas nacidas de `develop` (que se crea
desde `main` si no existe — `main` queda solo para producción):

```
main ──► develop ──► docs/arranque ──(PR → develop)──► feat/<primera-spec>
                     rama 1: la documentación         rama 2: scaffolding del stack
                     rellenada del arranque           + prototipo, guiados por la spec
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

## Reglas críticas (el "qué manda sobre qué")

1. **Pregunta antes de asumir.** En cualquier fase, ante ambigüedad real (alcance,
   prioridad, trade-off de negocio) se pregunta a la persona — decisiones reversibles
   de implementación no; decisiones de producto sí.
2. **Sin spec no hay cambio — obligatorio.** Toda funcionalidad o corrección
   (`feat/*`, `fix/*`) nace en [`../../specs/`](../../specs/README.md)
   (proposal → design → tasks), con rama y spec compartiendo slug. La spec es el
   contrato entre la idea y el código, y lo que permite delegar en agentes sin
   deriva. No es opcional: el hook `spec-guardrails.sh` bloquea editar código en
   esas ramas mientras no exista su spec **y** `proposal.md` conserve líneas de
   plantilla sin rellenar — una carpeta vacía no es una spec.
3. **Sin revisión no hay merge.** `/code-review` sobre el diff y, si toca entrada de
   usuario, auth, datos o llamadas externas, el subagente `security-reviewer`, que
   conoce las cuatro áreas que fallan en silencio (`SECURITY.md`). Los hallazgos
   bloqueantes se resuelven antes del PR.
4. **Nada sin documentar.** Todo cambio → CHANGELOG + docs afectados **en el mismo
   PR** que el código (`doc-keeper`); decisiones difíciles de revertir → ADR; specs
   que toquen datos, pagos o terceros → revisan también si cambian los textos
   legales del producto. Un cambio sin documentación **no está
   terminado** (es regla estricta de `AGENTS.md`), y el job `changelog` de
   `quality.yml` lo verifica en cada PR: sin entrada bajo `## [Unreleased]`, el CI
   falla. La excepción se pide explícitamente con la label `sin-changelog`.
5. **El roadmap se mueve con las specs, no con las buenas intenciones.** La spec
   declara qué ítem de [`../product/roadmap.md`](../product/roadmap.md) completa
   (campo _Ítem de roadmap_ en `proposal.md`) y el PR que la implementa lo marca
   como hecho. Roadmap, CHANGELOG y código viajan en el mismo commit-set: el estado
   del producto es lo que está fusionado, no lo que se prometió.
6. **La IA administra el repositorio.** Descripción, topics, labels, ramas, issues,
   PRs y releases se gestionan con las skills (`/configurar-repo`, `/open-issue`,
   `/open-pr`, `/release`) — la persona decide, la IA opera y deja rastro.

## Quién es quién

| Fase        | Agente / skill                                            | Qué garantiza                                      |
| ----------- | --------------------------------------------------------- | -------------------------------------------------- |
| Mapear      | `pantallas.md` (a mano)                                   | Inventario de vistas antes de construir ninguna    |
| Vestir      | `/identidad`                                              | Paleta y tipografía del producto, decididas viendo |
| Prototipar  | `designer`, `/prototipo`                                  | Vistas fieles al design system, clicables          |
| Especificar | `architect`, `/new-spec`                                  | Plan fundamentado antes de tocar código            |
| Implementar | sesión principal + `debugger`                             | Código alineado a spec y convenciones              |
| Probar      | `test-author`                                             | Camino feliz + bordes cubiertos                    |
| Revisar     | `/code-review`, `security-reviewer`                       | Correctitud, seguridad, sin secretos               |
| Documentar  | `doc-keeper`, `/changelog`, `/new-adr`                    | Docs, CHANGELOG y roadmap al día                   |
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
- Dejar que el backlog crezca sin contrastarlo contra el roadmap.
- Pedirle al mismo agente que implemente y se apruebe a sí mismo.
