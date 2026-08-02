# Preset: App móvil

> App para iOS y Android desde un solo código. La decisión grande no es el framework:
> es **qué backend** la alimenta.

## Framework: Flutter (default)

| Capa         | Elección                                | Por qué                                           |
| ------------ | --------------------------------------- | ------------------------------------------------- |
| Framework    | Flutter                                 | Un solo código, UI consistente, tooling excelente |
| Estado       | Riverpod                                | Estándar actual, testeable                        |
| Navegación   | go_router                               | Deep links y rutas declarativas                   |
| HTTP         | dio                                     | Interceptores, retry, cancelación                 |
| DB local     | Drift (SQLite)                          | Offline-first cuando haga falta                   |
| Animación    | flutter_animate (+ Lottie/Rive runtime) | Ver `design/` → Motion en móvil                   |
| Iconos       | lucide_icons                            | Mismo set que la web (ver `design/`)              |
| Errores      | Sentry (sentry_flutter)                 | Transversal                                       |
| Push         | Firebase Cloud Messaging                | El único uso obligado de Firebase                 |
| CI / release | GitHub Actions + Fastlane               | Builds y subida a stores automatizadas            |

**Alternativa — React Native + Expo**: elígela si el producto ya tiene un frontend
React del que reusar lógica/componentes, o si el desarrollo con IA en TS te resulta
más fluido que en Dart. Con Expo (EAS) el ciclo build/release es muy comparable.

## Backend: la decisión importante

| Opción                                  | Cuándo                                                                                                          |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Supabase** (default para apps nuevas) | Auth + Postgres + realtime + storage listos en un día; es Postgres, así que hay salida sin reescribir el modelo |
| **Tu Rails API**                        | Ya existe un monolito/web del producto — la app es un cliente más de [`api-service.md`](api-service.md)         |
| **Firebase**                            | Solo si necesitas su realtime/offline sync específico; mayor lock-in (Firestore no es SQL)                      |

Regla anti-lock-in: aunque uses Supabase, encapsula el acceso a datos en un repositorio
propio dentro de la app — migrar a tu API después será mecánico.

## Publicación

- Cuentas: Apple Developer (99 USD/año) + Google Play (25 USD una vez). Créalas al
  inicio: la revisión de Apple tarda.
- Tracks: TestFlight / Play internal testing desde la primera semana.
- Sigue `TEMPLATE-USAGE.md §7` (móvil): borra `conventions/seo.md`, reenfoca deploy a
  stores, añade convenciones de permisos/push/offline.

## Costo estimado

- Supabase free + cuentas de stores ≈ 99 USD/año + 25 USD.
- Con Rails API: se suma el hosting del preset API.

## Arranque

```bash
flutter create mi_app --org com.tumarca
flutter pub add riverpod flutter_riverpod go_router dio drift sentry_flutter lucide_icons
```
