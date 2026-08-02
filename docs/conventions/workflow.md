# Flujo de trabajo (SDD + agentes)

> Cómo se trabaja en los proyectos de esta plantilla: desarrollo guiado por
> especificaciones (SDD) con agentes de IA acompañando cada fase. El objetivo es que
> una persona sola avance rápido **sin perder robustez**: siempre hay quien pregunta,
> quien planifica y quien revisa.
> **Última actualización**: 2026-08-01

## El ciclo

```
1. DEFINIR      → product-coach (+ /definir-producto)   → docs/product/
2. ELEGIR STACK → /arrancar-proyecto + docs/stacks/     → docs/architecture/stack.md
3. ESPECIFICAR  → architect (+ /new-spec)               → specs/<cambio>/
4. IMPLEMENTAR  → desarrollo con IA, spec en mano       → código + tests (test-author)
5. REVISAR      → code-reviewer + security-reviewer     → antes de cada PR
6. DOCUMENTAR   → doc-keeper (+ /changelog, /new-adr)   → docs/ y CHANGELOG al día
7. MEDIR        → métricas de producto (PostHog) y criterio de "v1 lista"
        └──────────────── vuelve a 1 con lo aprendido ────────────────┘
```

Las fases 1–2 se hacen una vez por proyecto (y se revisitan); 3–6 se repiten por cada
cambio no trivial; 7 marca los cortes de versión.

## Sprint de definición (Design Sprint exprés)

La fase DEFINIR no es solo documentos: es un **Design Sprint adaptado a una persona +
IA**, comprimido a horas en vez de 5 días porque la IA produce los artefactos en el
momento. Se corre al arrancar el proyecto (y en versión mini ante cada feature grande):

| Paso          | Qué se hace (contigo + IA)                                                                                                 | Artefacto que queda                                                       |
| ------------- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| 1. Entender   | Entrevista de `product-coach`: problema, usuario, valor                                                                    | `docs/product/` (canvas + definición)                                     |
| 2. Mapear     | Flujo del usuario de punta a punta y **lista de vistas** (ver catálogo estándar abajo)                                     | Mapa de pantallas en `docs/architecture/design.md`                        |
| 3. Decidir    | Modelo de datos preliminar + **integraciones necesarias** (auth/login con Google, storage, pagos, emails)                  | Borradores de `database.md` y `auth.md`; preset de `docs/stacks/` elegido |
| 4. Prototipar | **Vistas estáticas navegables** con el design system de `design/` (HTML/ERB sin lógica) — agente `designer` + `/prototipo` | Prototipo en el repo — sirve de referencia visual y luego se conecta      |
| 5. Validar    | Recorrer el prototipo contra el recorrido crítico; enseñarlo a 2–3 personas si se puede                                    | Ajustes a la definición; luz verde para especificar                       |

Reglas del sprint:

- **Estático antes que funcional**: las vistas se construyen primero sin lógica —
  validan el flujo y el diseño baratísimo, y después se les conecta el backend
  (el prototipo no se tira, se convierte).
- **Decidir integraciones aquí**, no a mitad del desarrollo: qué auth (¿login con
  Google?), qué storage, si hay pagos en v1 — cada una tiene su default en el
  catálogo de stacks.
- El sprint termina con algo que se puede **clicar y criticar**, no con un documento
  más.
- **`/arrancar-proyecto` es EL comando de arranque** (único punto de entrada): prepara
  las ramas, encadena el sprint completo (definición → preset → instanciación →
  primera spec) y deja el prototipo para la rama siguiente. `/instanciar` es solo su
  paso interno.

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
  CHANGELOG con `/release` y el workflow `release.yml` crea el tag y el release de
  GitHub automáticamente. El primer merge (la documentación del arranque) publica
  la `v0.1.0` del proyecto — ningún paso a producción queda sin versión.

### Catálogo estándar de vistas (paso 2)

Todo producto web parte de este inventario y añade las vistas propias de su recorrido
crítico — así ninguna se descubre a mitad del desarrollo:

- **Públicas**: landing/home, precios (si hay pago), sobre/about, contacto, 404, 500.
- **Legales**: términos, privacidad, cookies — contenido base en [`legal/`](../../legal/README.md).
- **Auth** (si hay cuentas): login, registro, recuperar contraseña, verificación.
- **App**: dashboard/inicio, la(s) vista(s) de la acción de valor, ajustes/cuenta,
  facturación (si hay pago).

La skill `/prototipo` construye estas vistas en estático con el design system de
`design/` (modo claro/oscuro y es/en desde el inicio).

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
   esas ramas sin su spec.
4. **Sin revisión no hay merge.** `code-reviewer` (correctitud y convenciones) y,
   si toca entrada de usuario/auth/datos/llamadas externas, `security-reviewer`.
   Los hallazgos bloqueantes se resuelven antes del PR.
5. **Nada sin documentar.** Todo cambio → CHANGELOG + docs afectados en el mismo PR
   (`doc-keeper`); decisiones difíciles de revertir → ADR; specs que toquen datos,
   pagos o terceros → actualizan también [`legal/`](../../legal/README.md). Un cambio
   sin documentación **no está terminado** (es regla estricta de `AGENTS.md`).
6. **La IA administra el repositorio.** Descripción, topics, labels, ramas, issues,
   PRs y releases se gestionan con las skills (`/configurar-repo`, `/open-issue`,
   `/open-pr`, `/release`) — la persona decide, la IA opera y deja rastro.

## Quién es quién

| Fase        | Agente / skill                                            | Qué garantiza                                     |
| ----------- | --------------------------------------------------------- | ------------------------------------------------- |
| Definir     | `product-coach`, `/definir-producto`                      | Alcance acotado, prioridades claras               |
| Prototipar  | `designer`, `/prototipo`                                  | Vistas fieles al design system, clicables         |
| Especificar | `architect`, `/new-spec`                                  | Plan fundamentado antes de tocar código           |
| Implementar | sesión principal + `explorer`, `debugger`                 | Código alineado a spec y convenciones             |
| Probar      | `test-author`                                             | Camino feliz + bordes cubiertos                   |
| Revisar     | `code-reviewer`, `security-reviewer`                      | Correctitud, seguridad, sin secretos              |
| Documentar  | `doc-keeper`, `/changelog`, `/new-adr`                    | Docs vivos, decisiones registradas                |
| Medir       | `metrics-analyst`                                         | Eventos del recorrido crítico; datos → decisiones |
| Operar repo | `/configurar-repo`, `/open-issue`, `/open-pr`, `/release` | GitHub gestionado por IA con rastro               |

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
  (`.claude/hooks/`, activos por defecto), no promesas del modelo.

## Anti-patrones

- Implementar directo desde una idea conversada sin spec ("lo tengo fresco").
- Saltarse la revisión porque "es un cambio chico" (los chicos son los que rompen).
- Dejar que el backlog crezca sin pasar por la definición de producto.
- Pedirle al mismo agente que implemente y se apruebe a sí mismo.
