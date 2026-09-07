# Marco técnico — Móvil

> Extensión de [`marco-tecnico.md`](marco-tecnico.md) para **una pregunta**: ¿con qué
> se construye la app móvil, una vez decidido que la web instalable no basta? Se
> consulta solo si hay móvil; sus decisiones se rompen igual que las del marco — con un
> ADR (marco §6).
>
> **Última actualización**: [FECHA]

## Cuándo se llega aquí

**La PWA es el default**: sin publicación en stores, iteración inmediata, un solo
código. Se pasa a nativo solo si el producto necesita algo que la web no da: **offline
real, cámara o sensores, push nativo, o presencia obligatoria en store**.

El backend no cambia: sigue siendo el stack elegido en el marco §3, expuesto como API.

Escribe aquí también **lo que descartaste y por qué**. Un descarte sin argumento se
vuelve a proponer cada seis meses:

- _[TECNOLOGIA] descartada_: [RAZON].
- _Backend gestionado (BaaS) descartado como sustituto del backend_: un BaaS no
  complementa el stack elegido, lo **sustituye** — auth, base de datos y lógica pasan a
  un servicio con costo por usuario y migración cara. Si un producto lo quiere por
  velocidad, es una desviación con ADR (marco §6).

## El stack móvil

| Capa              | Elección          | Nota                                                     |
| ----------------- | ----------------- | -------------------------------------------------------- |
| Framework         | [FRAMEWORK_MOVIL] | [NOTA]                                                   |
| Lenguaje          | [RUNTIME]         | [NOTA]                                                   |
| Navegación        | [HERRAMIENTA]     | [NOTA]                                                   |
| Estilos           | [HERRAMIENTA]     | Sobre los mismos tokens de `design/`                     |
| Sesión            | [HERRAMIENTA]     | **Almacén cifrado del sistema — regla 1, no se negocia** |
| Almacén local     | [HERRAMIENTA]     | Solo si hay **escritura** sin conexión                   |
| Archivos y cámara | [HERRAMIENTA]     | El binario no pasa por el backend                        |
| Push              | [HERRAMIENTA]     | Requiere backend con tokens de dispositivo — regla 2     |
| Build             | [HERRAMIENTA]     | [NOTA]                                                   |
| Actualizaciones   | [HERRAMIENTA]     | Las OTA revierten el código, **no el binario**           |
| Tests             | [HERRAMIENTA]     | [NOTA]                                                   |
| Lint / formato    | [LINTER]          | El mismo que el stack web                                |

## Cuatro reglas obligatorias desde el día uno

Estas cuatro no dependen del framework, así que vienen escritas: son de la plataforma
móvil, no de tu elección.

1. Auth con tokens y refresh en el **almacén cifrado del sistema**. Nunca en el almacén
   de clave-valor sin cifrar.
2. Push requiere backend: tokens de dispositivo y un servicio de entrega por plataforma.
3. **La API no se puede romper.** Solo agregar campos, nunca borrar ni renombrar: hay
   usuarios con versiones viejas consumiéndola.
4. Las operaciones de creación son idempotentes. La red móvil falla y los requests se
   reintentan.

> La regla 3 es la que más duele descubrir tarde y es puramente arquitectónica.

## Lo que hay que aceptar antes de empezar

Publicar deja de ser reversible. La API no puede romperse nunca (regla 3) porque habrá
usuarios en versiones viejas de forma permanente, y cada entrega pasa por una revisión
que dura horas o días. El procedimiento está en
[`conventions/deploy.md`](conventions/deploy.md).
