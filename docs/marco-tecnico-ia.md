# Marco técnico — IA y APIs de terceros

> Extensión de [`marco-tecnico.md`](marco-tecnico.md) para **una pregunta**: ¿cómo se
> integran proveedores de IA y APIs de terceros? Se consulta solo cuando el producto
> los usa; las decisiones de aquí pesan igual que las del marco y se rompen igual — con
> un ADR (marco §6).
>
> **Última actualización**: [FECHA]

## Capa de IA — sin proveedor por defecto

**No hay proveedor por defecto en este marco.** Se elige por producto y se registra en
[`architecture/stack.md`](architecture/stack.md). Un default aquí se convertiría en
supuesto en el código, y el supuesto es lo que hace cara la migración.

Y hay que separar dos casos, porque **solo uno es realmente portable**:

### Caso A — capacidad genérica (texto, tools, structured output, embeddings)

Portable de verdad. Se resuelve con un adaptador y el cambio de proveedor es
configuración:

| Lenguaje  | Adaptador     |
| --------- | ------------- |
| [RUNTIME] | [HERRAMIENTA] |

- Nunca se llama al SDK del proveedor desde la lógica de negocio.
- **Config por entorno**: `AI_PROVIDER`, `AI_MODEL`, `AI_API_KEY`.
- **Prompts versionados** en archivos del repo, nunca strings inline — para poder
  revisarlos, testearlos y **re-ejecutarlos contra otro proveedor**.
- **Un segundo proveedor configurado desde el día 1**, con los tests corriendo contra
  los dos. Si nunca has ejecutado el segundo, no eres portable: solo lo crees.

### Caso B — capacidad exclusiva (vídeo, voz en tiempo real, modelos propietarios)

**Aquí no existe agnosticismo y ningún adaptador lo arregla.** Generación de vídeo, voz
realtime o cualquier modelo sin equivalente tienen formas de API, parámetros y salidas
que no se mapean entre proveedores. Cuando el proveedor cierra el producto —y pasa— la
migración es reescritura, no configuración.

Lo que sí protege, y hay que hacerlo desde el día 1:

1. **Un puerto propio en el dominio** (`VideoGenerator`, `VoiceSession`) con la
   interfaz que necesita _tu_ producto, no la que expone el proveedor. El adaptador
   traduce.
2. **Dos implementaciones desde el principio**, aunque la segunda solo se use en tests.
   Es lo único que demuestra que la interfaz no está calcada del proveedor actual.
3. **Guardar el insumo, no solo el resultado.** Prompt, parámetros, semillas, assets de
   entrada y versión del modelo, versionados junto al output. _Si solo guardas el
   resultado, migrar es imposible: no puedes regenerar lo que ya vendiste._
4. **ADR obligatorio** al adoptar la capacidad, nombrando el riesgo de cierre y qué
   costaría migrar. Que la apuesta sea consciente.

## Cuánto cuesta cada casa

Los precios no eligen por ti —eso lo hacen los dos casos de arriba— pero sí descartan.

**Esta tabla viene vacía a propósito**: los precios de los modelos cambian cada pocos
meses, y una tabla heredada y desactualizada es peor que ninguna. La rellena
`/actualizar-costos` contra la fuente, y `check-costs.sh` falla cuando la fecha de
verificación pasa del trimestre.

Dos descuentos transversales suelen existir en todos los proveedores, y son la primera
palanca de costo antes de cambiar de modelo:

- **Caché de entrada**: una fracción del precio normal para el prompt que se repite. Lo
  primero que se mira en cualquier cosa con prompt de sistema largo.
- **Batch / asíncrono**: descuento fuerte a cambio de esperar horas. Para procesos de
  fondo, nunca para algo que la persona mira en pantalla.

### Texto

Uno **fuerte** para razonar sobre algo difícil y uno **barato** para clasificar,
extraer, resumir y enrutar. Se elige una casa por producto, no todas.

La última columna es el costo del recorrido típico de tu producto (por ejemplo: 1.000
conversaciones al mes con ~4.000 tokens de entrada y ~1.000 de salida cada una).
**Comparar precios por millón de tokens no decide nada; comparar el costo del recorrido
real, sí.**

| Proveedor   | Rol        | Modelo   | Entrada $/1M | Salida $/1M | Contexto | [RECORRIDO] |
| ----------- | ---------- | -------- | ------------ | ----------- | -------- | ----------- |
| [PROVEEDOR] | **Fuerte** | [MODELO] | [PRECIO]     | [PRECIO]    | [TAMAÑO] | [COSTO_MES] |
| [PROVEEDOR] | **Barato** | [MODELO] | [PRECIO]     | [PRECIO]    | [TAMAÑO] | [COSTO_MES] |

| Si el producto… | Casa        |
| --------------- | ----------- |
| [CASO_DE_USO]   | [PROVEEDOR] |

### Imagen y video

Solo si el producto los usa. Se miden distinto que el texto —por imagen, por segundo
generado, por resolución— y ahí es donde aparecen las trampas que
[`marco-tecnico-infraestructura.md`](marco-tecnico-infraestructura.md) §5 recoge: el
«4K» de cada casa no es el mismo número de megapíxeles, y la relación de aspecto puede
cambiar el precio.

| Casa        | Modelo   | Unidad   | Precio   | Fuerte en     |
| ----------- | -------- | -------- | -------- | ------------- |
| [PROVEEDOR] | [MODELO] | [UNIDAD] | [PRECIO] | [CASO_DE_USO] |

## Toda API de terceros va detrás de un adaptador propio

No solo las de modelos: también las de datos —catálogos, geocodificación, tipos de
cambio—. **La lógica de negocio no conoce al proveedor.**

El adaptador expone la forma que necesita _tu_ producto y traduce; si expone lo que
devuelve el proveedor, no es un adaptador, es un alias. Cada una se registra en
[`architecture/stack.md`](architecture/stack.md) → «APIs de terceros que consumimos»,
con lo que hay que decidir antes de escribir la primera llamada: fuente principal y
respaldo, qué pasa cuando no encuentra nada, caché, límites y licencia de los datos.
