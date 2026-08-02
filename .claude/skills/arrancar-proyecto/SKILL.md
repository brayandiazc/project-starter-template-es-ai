---
name: arrancar-proyecto
description: EL comando de arranque — único punto de entrada para convertir esta plantilla en un proyecto real. Prepara las ramas Git Flow (develop + rama de documentación), corre el Sprint de definición, instancia la plantilla, y deja la primera spec lista para el scaffolding. Úsalo siempre que la persona llegue con una idea nueva o quiera empezar (p. ej. "arranquemos el proyecto", "tengo una idea", "empecemos con X", "instancia la plantilla").
---

<!-- Skill de ejemplo de la plantilla — adáptalo o elimínalo según tu proyecto. -->

Este es el **único comando de arranque**: encadena el ciclo completo de
`docs/conventions/workflow.md`. No le pidas a la persona que corra `/instanciar` ni
otros pasos por separado — tú orquestas y cada paso usa la herramienta que ya existe.

El arranque produce **dos ramas en secuencia**, ambas nacidas de `develop`:

```
main ──► develop ──► docs/arranque ──(PR → develop)──► feat/<primera-spec>
         (se crea       rama 1:                            rama 2:
         si falta)      documentación                      scaffolding + prototipo
```

## Paso 0 — Preparar las ramas (antes de cualquier contenido)

1. Verifica el remoto (`git remote -v`). Si el origin es el repo-fuente de la
   plantilla (`project-starter-template`), DETENTE: estarías destruyendo la plantilla.
2. Si no existe la rama `develop`, créala desde `main` (`git checkout -b develop main`)
   y publícala (`git push -u origin develop`). `develop` es la rama de integración;
   `main` queda solo para producción.
3. Crea la **rama 1** desde `develop`: `git checkout -b docs/arranque develop`.
   TODO lo que producen los pasos 1–4 (definición, stack, instanciación, primera spec)
   se commitea aquí — nunca en `main` ni en `develop` directo.

## Paso 1 — Sprint de definición

Delega en el subagente `product-coach` (o corre `/definir-producto`): entrevista de
idea → nombre → tipo de proyecto → usuario → v1, más el mapa de vistas, entidades
preliminares e integraciones necesarias. No avances sin la tabla Dentro/Fuera de v1.

## Paso 2 — Stack

Con el tipo de proyecto definido, propone el preset de `docs/stacks/` que corresponda
y confirma desviaciones. Registra la elección.

## Paso 3 — Instanciar la plantilla

Ejecuta aquí el flujo de la skill `/instanciar` (es un paso interno de este comando,
no algo que la persona deba invocar): placeholders, limpieza por tipo, permisos y
guardrails, `.template-origin`. El preset del Paso 2 rellena
`docs/architecture/stack.md`.

## Paso 4 — Primera spec (obligatoria antes de tocar código)

Crea con `/new-spec` la spec del primer cambio funcional — normalmente
`scaffold-y-prototipo`: generar el esqueleto del proyecto (dependencias, estructura
del stack elegido) y las vistas estáticas del mapa. La rama que la implemente se
llamará `feat/<slug-de-la-spec>` (el guardrail de specs lo exige). Si el producto es
público, recuerda adaptar `legal/` (placeholders + secciones ADAPTAR).

## Paso 5 — Cerrar la rama de documentación

Commitea la rama `docs/arranque` (con `/commit`, en commits lógicos) y abre el PR
hacia `develop` con `/open-pr`. **El código del proyecto aún no existe y está bien**:
primero se fusiona la documentación.

Fusionada la documentación en `develop`, corta la **primera release**: `/release`
para mover Unreleased → `0.1.0` en el CHANGELOG, PR `develop` → `main`, y el workflow
`release.yml` publica el tag y el release de GitHub automáticamente. Así el proyecto
estrena versión desde su documentación.

## Paso 6 — Rama 2: scaffolding + prototipo

Cuando el PR de documentación esté fusionado en `develop` (confírmalo con la persona
o con `gh pr view`), crea la **rama 2** desde `develop` actualizado:
`git checkout develop && git pull && git checkout -b feat/<slug-de-la-primera-spec>`.
Ahí sí: genera el proyecto (instala dependencias, esqueleto del stack) y corre
`/prototipo` para las vistas estáticas, siguiendo la spec del Paso 4.

## Cierre

Resume: definición (una frase + dentro/fuera de v1), stack elegido, ramas creadas y
su estado (docs fusionada / feat en curso), spec activa y los pendientes humanos.
Sugiere el ADR de instanciación si el Paso 3 no lo creó. Si el proyecto tiene UI,
sugiere instalar el plugin **Impeccable** (ver `design/README.md` → Herramientas de
diseño con IA) antes de prototipar.

NO hagas push sin confirmar el remoto con la persona, NO te saltes el orden de ramas
del Paso 0, y NO implementes nada del Paso 6 sin la spec del Paso 4. Si la persona ya
hizo alguno de los pasos, detéctalo y sáltalo en vez de repetirlo.
