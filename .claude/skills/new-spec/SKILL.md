---
name: new-spec
description: Genera una nueva especificación de cambio ligera copiando el directorio de plantilla de especificación en una carpeta de especificación con nombre. Úsalo cuando la persona quiera iniciar una especificación, planificar un cambio/funcionalidad o crear un documento de diseño antes de implementar (p. ej. "especifica el rediseño del checkout", "crea una especificación para el nuevo flujo de autenticación").
argument-hint: "[nombre del cambio]"
---

<!-- Skill de ejemplo de la plantilla — adáptalo o elimínalo según tu proyecto. -->

Crea una nueva especificación de cambio cuyo nombre está en `$ARGUMENTS`.

1. Lee `specs/README.md` para conocer el flujo de trabajo de las especificaciones, la convención de nombres de carpeta y qué espera cada sección de la plantilla. Sigue ese documento si difiere de los pasos siguientes.
2. Convierte `$ARGUMENTS` en `<change-name>` con formato slug (minúsculas, separado por guiones).
3. Copia todo el directorio `specs/_template/` a `specs/<change-name>/` (conserva cada archivo de la plantilla).
4. En los archivos copiados, completa los metadatos obvios:
   - El título del cambio (la forma legible de `$ARGUMENTS`)
   - Estado: `Draft`
   - Fecha: la fecha de hoy (`YYYY-MM-DD`)
   - Deja problem, goals, non-goals y approach como indicaciones para la persona autora.
5. Si `specs/README.md` mantiene un índice de especificaciones, añade una entrada para la nueva especificación.
6. Informa la ruta del directorio creado y enumera los archivos que la persona autora aún debe completar.

Ejemplo: `/new-spec rediseño del checkout` → `specs/checkout-redesign/`.

NO empieces a implementar el cambio, y NO elimines ni sobrescribas una carpeta de especificación existente — si `specs/<change-name>/` ya existe, detente y pregunta.
