# Marco legal base

> Documentos legales base que todo proyecto público hereda y adapta, derivados del
> marco real de Phareto (Iqonno S.A.S.). La estructura y la mayoría de cláusulas se
> mantienen entre proyectos; lo que cambia son los datos de identificación, el modelo
> de cobro y las particularidades de cada producto.

## Contenido

| Documento              | ES                                     | EN                               |
| ---------------------- | -------------------------------------- | -------------------------------- |
| Términos y condiciones | [`es/terminos.md`](es/terminos.md)     | [`en/terms.md`](en/terms.md)     |
| Política de privacidad | [`es/privacidad.md`](es/privacidad.md) | [`en/privacy.md`](en/privacy.md) |
| Política de cookies    | [`es/cookies.md`](es/cookies.md)       | [`en/cookies.md`](en/cookies.md) |

Ambos idiomas son equivalentes (español + inglés neutro) — el default de los proyectos
es multiidioma es/en, así que los legales nacen bilingües. La skill `/i18n-parity`
puede verificar que no divergen.

## Qué se mantiene y qué cambia por proyecto

**Se mantiene (el esqueleto):** la estructura de secciones, las cláusulas de uso
aceptable, contenido del usuario, propiedad intelectual, exención de garantías,
limitación de responsabilidad, indemnización, suspensión/terminación, modificaciones
y disposiciones generales.

**Cambia por proyecto (los datos):** los placeholders `[ASÍ]` — nombre del producto y
la empresa, forma jurídica, domicilio, identificación tributaria, email de contacto,
jurisdicción — más las secciones marcadas con `> ⚠️ ADAPTAR`: descripción del
servicio, planes/pagos/reembolsos (depende del modelo de cobro y de Paddle como
merchant of record), datos recolectados y encargados/subprocesadores (depende del
stack real: Resend, PostHog, Sentry, hosting…).

**Específico de jurisdicción:** los documentos base usan Colombia como referencia
(Ley 1581 de 2012 / Habeas Data, retracto Ley 1480, RNBD) porque es la jurisdicción
de origen. Las secciones marcadas `> ⚠️ JURISDICCIÓN` se ajustan o eliminan si el
proyecto opera bajo otra ley (p. ej. GDPR si hay usuarios en la UE).

## Reglas de mantenimiento

1. **Versionado**: cada documento lleva versión y fecha de publicación. Un cambio
   sustancial sube la versión y dispara **re-aceptación** en productos con cuentas
   (patrón de Phareto: modal "actualizamos nuestros términos" + checkbox + registro
   de aceptación con fecha y versión).
2. **Las specs actualizan los legales**: si una spec toca datos personales, pagos,
   nuevos terceros (un subprocesador más) o edad mínima, la actualización del
   documento legal correspondiente es parte del "hecho" de esa spec
   (ver [`../docs/conventions/workflow.md`](../docs/conventions/workflow.md), regla 5).
3. **Publicación**: en la web los legales viven en rutas estables (`/legal/terminos`,
   `/legal/privacidad`) con sidebar entre documentos y tarjeta de metadatos
   (responsable, versión, fecha) — parte de las vistas estándar de todo proyecto.
4. **Esto no es asesoría legal**: es una base de trabajo sólida; ante dudas reales
   (nueva jurisdicción, datos sensibles, menores) se consulta a un abogado.
