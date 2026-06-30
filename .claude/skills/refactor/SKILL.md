---
name: refactor
description: Mejora la estructura y la legibilidad del código SIN cambiar el comportamiento observable, en pasos pequeños y seguros guiados por las convenciones del proyecto, manteniendo los tests en verde. Úsalo cuando la persona pida refactorizar, limpiar, reestructurar o reducir la duplicación en el código sin añadir funcionalidades ni corregir errores (p. ej. "refactoriza este módulo", "limpia esta función", "extrae esta lógica").
---

<!-- Skill de ejemplo de la plantilla — adáptalo o elimínalo según tu proyecto. -->

Refactoriza el código indicado preservando el comportamiento.

1. Lee la guía relevante en `docs/conventions/` (estilo, arquitectura, nombres) y síguela — las convenciones definen qué significa "mejor estructura" aquí.
2. Establece primero una red de seguridad: identifica los tests que cubren el código objetivo y ejecútalos para confirmar que pasan antes de tocar nada. Si falta cobertura, anota el riesgo y considera añadir un test de caracterización.
3. Refactoriza en pasos pequeños que preserven el comportamiento, por ejemplo:
   - Renombra para mayor claridad; extrae una función/componente/módulo; integra (inline) indirecciones innecesarias.
   - Elimina duplicación; simplifica condicionales; ajusta los tipos.
   - Reduce el acoplamiento según las convenciones de arquitectura.
4. Después de CADA paso significativo, vuelve a ejecutar los tests (y el linter/formateador si están configurados) y mantenlos en verde. Revierte un paso que los rompa en lugar de parchear el comportamiento.
5. Resume qué cambió estructuralmente y confirma que las APIs públicas y el comportamiento observable no han cambiado.

NO cambies el comportamiento, las APIs públicas ni la salida — si parece necesario un cambio de comportamiento, detente y plantéalo por separado. NO mezcles nuevas funcionalidades ni correcciones de errores. NO hagas una reescritura gigante de una sola vez; prefiere incrementos revisables.
