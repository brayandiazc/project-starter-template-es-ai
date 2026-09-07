# Stack de [NOMBRE_DEL_PROYECTO]

> **Qué es**: lo que se eligió en **este** producto y en qué se desvió del marco.
> Las alternativas, los porqués y los defaults viven en
> [`../marco-tecnico.md`](../marco-tecnico.md) — aquí no se repiten.
> **Última actualización**: [FECHA]

## Stack elegido

**[ELEGIDA]**, y de dónde sale: [uno de los stacks del marco §3 · la regla de dominio
para CLI y herramientas internas · desviación con ADR].

> No des por hecho que es uno de los del marco: en dos de cada tres arranques reales no
> lo era. Escribe de dónde viene la decisión — es lo que hace auditable si hubo
> desviación o no.

> Las filas son **categorías**, no elecciones: rellena cada una con lo que use este
> producto y **borra las que no apliquen** (una CLI no tiene base de datos, un sitio
> estático no tiene framework de servidor).

| Pieza                  | Versión   | Nota |
| ---------------------- | --------- | ---- |
| Framework principal    | [VERSION] |      |
| Runtime / lenguaje     | [VERSION] |      |
| Base de datos          | [VERSION] |      |
| Gestor de dependencias | [VERSION] |      |

Todo lo demás es lo que dicta el marco. **Si no aparece abajo como desviación, es el
default.**

## Desviaciones del marco

Cada fila necesita su ADR en [`../decisions/`](../decisions/README.md). Si la tabla está
vacía, mejor: el producto va por el camino trillado.

| Se desvió en | Se usa en su lugar | Por qué | ADR |
| ------------ | ------------------ | ------- | --- |
| [DESCARTADA] | [ELEGIDA]          |         |     |

## Servicios activos

Solo los que este producto tiene **contratados y conectados**. El catálogo completo está
en el marco ([§2](../marco-tecnico.md#2-servicios-transversales)); un servicio del marco
que aquí no esté listado, no está funcionando todavía.

| Servicio       | Para qué   | Variable de entorno |
| -------------- | ---------- | ------------------- |
| [SERVICIO/API] | [PARA_QUE] | `[NOMBRES]`         |
|                |            |                     |

## APIs de terceros que consumimos

> **Bórrala si el producto no llama a ninguna.** Una fila por API, con su adaptador: la
> lógica de negocio no conoce al proveedor ([marco §2](../marco-tecnico.md)).

| API         | Para qué       | Adaptador        | ¿Clave? | Respaldo si falla                    |
| ----------- | -------------- | ---------------- | ------- | ------------------------------------ |
| [Proveedor] | [Qué resuelve] | [Clase o módulo] | [Sí/No] | [Otro proveedor · degradar · fallar] |

Y por cada una, decidido **antes** de implementar — si no está escrito, cada llamada lo
decide por su cuenta:

- **Qué forma tiene el objeto en NUESTRO dominio**, frente a lo que devuelve el proveedor.
  Es lo que el adaptador traduce; sin esto acaba siendo el JSON del proveedor con otro
  nombre, y entonces no hay adaptador.
- **Qué pasa cuando no encuentra nada.** Si la respuesta obliga a un flujo alternativo,
  dilo aquí: una limitación de la API que define una pantalla no es un detalle técnico.
- **Caché**: qué se guarda, cuánto vive y por qué. Cuando muchos usuarios piden lo mismo
  suele ser casi gratis y cambiar el coste entero.
- **Límites de uso** y qué ocurre al alcanzarlos.
- **Licencia de los datos** y atribución exigida al mostrarlos.

## Proveedor de IA

El marco **no fija uno** ([`marco-tecnico-ia.md`](../marco-tecnico-ia.md)):
se elige aquí, por producto.

|                                                                               |                         |
| ----------------------------------------------------------------------------- | ----------------------- |
| Proveedor principal                                                           | `AI_PROVIDER=`          |
| Modelo por tarea                                                              |                         |
| **Segundo proveedor** (configurado desde el día 1, tests corriendo contra él) |                         |
| ¿Usa alguna capacidad exclusiva (caso B)?                                     | No / Sí → **exige ADR** |

Si la respuesta a la última fila es "Sí", las cuatro mitigaciones de
[`marco-tecnico-ia.md`](../marco-tecnico-ia.md) (caso B) son
obligatorias — sobre todo **guardar el insumo, no solo el resultado**.

## Decisiones del arranque

Respondidas antes de escribir código (marco [§4](../marco-tecnico.md#4-reglas-duras)):

- **Entidad central del producto**: — _(se diseña en papel antes que nada)_
- **¿Qué crece sin límite?**: — _ese es el costo recurrente_
- **¿Hay costo de infraestructura por usuario?**: — _si sí, va al precio desde el día uno_
- **¿Hay pantalla con interactividad continua?**: — _si sí, React solo ahí (§4.1)_
- **¿Necesita algo que la web no da?**: — _si sí, Expo; si no, PWA (§4.2)_
