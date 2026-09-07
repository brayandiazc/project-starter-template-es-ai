# Marco técnico

> **Qué es**: las decisiones de tecnología que ya tomaste y **no vuelves a discutir por
> proyecto**. No se rellena por producto — se hereda igual en todos y cambia solo cuando
> cambias de opinión.
>
> **Qué NO es**: el stack de _este_ producto. Eso vive en
> [`architecture/stack.md`](architecture/stack.md), que sí se rellena, y las
> desviaciones se justifican en [`decisions/`](decisions/README.md).
>
> **Este documento viene vacío a propósito.** La plantilla te da la estructura y el
> criterio, no las elecciones: un default heredado de otra persona es un supuesto que
> nadie revisó. Rellénalo una vez, al empezar a trabajar así, y reutilízalo en todos tus
> productos.
>
> **Última actualización**: [FECHA]

## 1. Los dos principios

Todo lo demás de este documento se deriva de aquí. Si una decisión no se deriva de
estos dos principios, sobra.

**Verificar > recordar.** Un agente rinde bien cuando puede verificar (leer código
existente, consultar un esquema, revisar un tipo) y falla cuando tiene que recordar
(reconstruir de memoria una API, una versión, un flag). El modo de falla es
**plausible pero incorrecto**: compila, suena razonable, no funciona o funciona mal.
No falla ruidosamente.

**Menos decisiones no revisadas = menos riesgo.** Si nadie revisa el código, cada
decisión que el agente toma libremente es riesgo acumulado. Un framework con
convención fuerte **le quita libertad**, y esa pérdida de libertad es lo que protege
el proyecto.

> **Corolario**: preferir lo que tenga convención fuerte, API estable y mucho código
> público. Es un sesgo deliberado hacia lo maduro y aburrido. Correcto para lanzar
> producto; incorrecto para estar a la vanguardia.

Los dos principios son de la plantilla y no se rellenan. Si tu criterio es otro,
cámbialos aquí antes que en ningún otro sitio: **el resto del documento cuelga de
ellos**.

Las consecuencias sobre el método de trabajo (dónde revisar, dónde falla el agente)
están en [`conventions/ai-agents.md`](conventions/ai-agents.md).

## 2. Servicios transversales

Se eligen **una vez** y son los mismos en todos los stacks. Cambiarlos requiere un ADR.

Elegir aquí es lo que evita volver a comparar proveedores en cada arranque. La columna
que de verdad importa es la tercera: **una elección sin un porqué escrito se vuelve a
discutir dentro de seis meses.**

| Categoría               | Elección              | Por qué                    |
| ----------------------- | --------------------- | -------------------------- |
| Base de datos           | [BASE_DE_DATOS]       | [RAZON]                    |
| Pagos                   | [PROVEEDOR_PAGOS]     | [RAZON]                    |
| Email transaccional     | [PROVEEDOR_EMAIL]     | [RAZON]                    |
| Almacenamiento archivos | [PROVEEDOR_ARCHIVOS]  | [RAZON]                    |
| Errores                 | [MONITOREO]           | [RAZON]                    |
| Uptime y logs           | [PROVEEDOR_UPTIME]    | [RAZON]                    |
| Analytics de producto   | [PROVEEDOR_ANALYTICS] | [RAZON]                    |
| CI/CD                   | [CI_CD]               | [RAZON]                    |
| Hosting                 | [PROVEEDOR_HOSTING]   | [RAZON]                    |
| Estáticos               | [PROVEEDOR_ESTATICOS] | [RAZON]                    |
| Dominios                | [PROVEEDOR_DOMINIOS]  | [RAZON]                    |
| Credenciales            | [PROVEEDOR_SECRETOS]  | [RAZON]                    |
| Backups                 | [ESTRATEGIA_BACKUP]   | Ver `scripts/backup-db.sh` |

> Añade o quita filas según lo que tu producto necesite de verdad. Una fila vacía que
> nadie usa cuesta menos que una elección inventada para llenarla.

### Cómo se opera todo esto

La tabla dice **qué** se usa. [`marco-tecnico-infraestructura.md`](marco-tecnico-infraestructura.md)
dice **cómo se toca cada servicio desde una conversación con el agente** —MCP, CLI, SSH
o API—, con qué credencial, qué agente o skill es su dueño, y **el reparto entre lo que
hace el agente solo, lo que pide permiso y lo que hace siempre la persona**. Incluye lo
que el agente NO puede hacer y lo que todavía no está automatizado, porque un hueco
callado se lee como resuelto.

### Cuánto cuesta todo esto

También en [`marco-tecnico-infraestructura.md`](marco-tecnico-infraestructura.md): el
precio de cada servicio y el total mensual en los dos escenarios (arranque y producción
con tracción).

Sus cifras caducan: llevan `Fecha de verificación` y `check-costs.sh` falla cuando pasan
del trimestre. Se renuevan con `/actualizar-costos`, que las busca contra la fuente.

### Capa de IA y APIs de terceros

Una pregunta con documento propio — se consulta solo cuando el producto integra modelos
o APIs externas: [`marco-tecnico-ia.md`](marco-tecnico-ia.md). Lo no negociable, en dos
líneas: **el proveedor de IA se elige por producto** (queda en `architecture/stack.md`,
no aquí) y **toda API de terceros va detrás de un adaptador propio** — la lógica de
negocio no conoce al proveedor.

## 3. Los stacks

Se elige **uno** por producto, al arrancar, y queda registrado en el ADR de arranque.
Si ninguno encaja, es una desviación con ADR (§6), no un stack nuevo.

**Dos o tres stacks bastan.** La tentación es listar uno por tipo de proyecto; el
resultado es un catálogo que se hojea en vez de leerse, con los servicios transversales
duplicados en cada preset y contradiciéndose entre sí. Escribe el default, el que cubre
lo que el default no puede, y para. Un tipo de proyecto que no aparece no es un stack
nuevo: entra en uno de los que tienes, o es una desviación con ADR.

### 3.0 Sin stack todavía — cuando elegir es prematuro

El resto de esta sección asume que al arrancar **ya sabes qué construir**. Cuando el
riesgo del proyecto no es técnico sino de método —«¿aguanta este flujo de trabajo?»,
«¿alguien lo usa dos semanas seguidas?»— lo correcto no es elegir bien: es **no elegir
todavía**. Sin esta salida, un caso legítimo se ve obligado a desviarse.

**Cuándo entra.** Las dos, no una:

- El riesgo principal es de producto o de método, **no técnico**.
- Existe un experimento barato que lo resuelve **antes** de construir: un prototipo
  estático, una hoja de cálculo, el proceso a mano durante dos semanas.

**Qué exige.** Aplazar no es olvidar, así que se paga por adelantado:

1. **Un ADR con las señales que dispararán la decisión** — observables, no
   intenciones: «un segundo usuario», «los datos salen del navegador», «hay que
   custodiar una credencial ajena». Sin ellas, el aplazamiento se vuelve permanente.
2. **Tres reglas que mantengan barata la migración**, porque lo que se escribe hoy
   sobrevive al cambio de stack:
   - La lógica vive **fuera del DOM** (módulos que se pueden mover tal cual).
   - Las integraciones van **tras un adaptador propio**, nunca llamadas sueltas.
   - El dominio es **datos versionados** (JSON, Markdown), no código.

**Cuándo caduca.** Al cumplirse **cualquiera** de las señales del ADR. Ese día se elige
stack con su propio ADR, y este deja de aplicar.

**Lo que 3.0 no es**: una excusa para no decidir en un producto que ya sabe lo que es.
Si puedes nombrar las entidades y las pantallas, elige. 3.0 es para cuando ni eso.

### 3.1 [STACK_DEFAULT] — el default

Cuándo entra: [CUANDO_ENTRA]. Ante la duda, este.

| Capa          | Elección          |
| ------------- | ----------------- |
| Framework     | [FRAMEWORK_WEB]   |
| Frontend      | [FRAMEWORK_FRONT] |
| Estilos       | [HERRAMIENTA]     |
| Primitivas UI | [HERRAMIENTA]     |
| ORM           | [ORM]             |
| Jobs / cache  | [COLA] / [CACHE]  |
| Auth          | [HERRAMIENTA]     |
| Pagos         | [HERRAMIENTA]     |
| Tests         | [HERRAMIENTA]     |
| Deploy        | [HERRAMIENTA]     |

**Por qué es el default**: [RAZON]. El argumento que buscas no es «me gusta más», es
cuál de los dos principios de §1 satisface mejor — normalmente **densidad de
convención**: una sola forma correcta de estructurar, que el agente sabe de memoria, y
desviaciones que saltan a la vista.

### 3.2 [STACK_ALTERNO] — cuando el default no basta

Cuándo entra: [CUANDO_ENTRA]. Un segundo stack se justifica por lo que el default **no
puede hacer**, nunca por preferencia.

| Capa      | Elección        | Nota   |
| --------- | --------------- | ------ |
| Framework | [FRAMEWORK_WEB] | [NOTA] |
| Lenguaje  | [RUNTIME]       | [NOTA] |
| ORM       | [ORM]           | [NOTA] |
| Tests     | [HERRAMIENTA]   | [NOTA] |
| Deploy    | [HERRAMIENTA]   | [NOTA] |

> Duplica esta sección por cada stack que de verdad mantengas. Si llevas más de tres,
> vuelve a leer la advertencia del principio de §3.

## 4. Reglas duras

Decisiones cerradas. Romperlas es legítimo y cuesta un ADR (§6).

Las cuatro primeras vienen de la plantilla porque no dependen de ningún stack. Las
siguientes las escribes tú, y son las que más valor tienen: **una regla dura es una
discusión que ya no vuelves a tener.**

### 4.1 El esquema de datos se diseña en papel, antes del código

Antes de escribir nada, responder: **¿cuál es la entidad central del producto?** Si hay
un documento estructurado que describe el estado (manifest, schema, EDL), se diseña
primero, en papel.

Es lo más caro de cambiar después y lo único que **ni los tests ni el monitoreo
detectan**: un modelo de datos mal pensado pasa todos los tests y no genera un solo
error en el monitor.

### 4.2 Un solo lenguaje principal por producto

El stack elegido en §3 es **el** lenguaje del producto. Un segundo lenguaje entra solo
cuando su ecosistema resuelve algo que el principal no tiene — nunca por preferencia —
y entra **acotado**: un worker detrás de una cola o un servicio que hace una sola cosa.

**Qué cuesta cada lenguaje extra**: otro deploy, otro CI, otras dependencias, otro
contexto que nadie revisa.

### 4.3 El contenedor es el contrato

Containerizar desde el día 1, aunque despliegues en un PaaS. Con el contenedor como
contrato, migrar de proveedor es un cambio de destino y no una reescritura. **Eso vale
más que acertar la elección inicial.**

Lo que ningún deploy cubre y queda a tu cargo: actualizaciones de SO y espacio en
disco. Las dos rompen la máquina, y **el dump de la base no las cubre**: ese recupera
datos, no un servidor. Hace falta además un **snapshot** —imagen del disco entero—
antes de cada actualización de SO y de cualquier cambio en el runtime o el firewall.
Son dos respaldos para dos fallos distintos; el procedimiento y la retención están en
[`conventions/deploy.md`](conventions/deploy.md).

### 4.4 Sin boilerplate comprado

El esqueleto es **este repositorio**. No se compran boilerplates: agregan convenciones
ajenas que el agente no conoce y tiene que inferir, justo lo contrario de §1.

### 4.5 [REGLA_DURA]

[Qué se decidió, en una frase imperativa. Después: cuándo se rompe, qué cuesta romperla
y qué NO justifica romperla — esa última línea es la que hace que la regla se sostenga.]

> Ejemplos del tipo de regla que va aquí: qué tecnología de frontend entra y en qué
> pantallas exactas; si la app móvil es web instalable o nativa, y qué la hace cruzar
> esa puerta; qué proveedor de pagos y a través de qué abstracción. Todas comparten la
> forma: **una decisión cerrada, un precio fijo para romperla.**

## 5. Preguntas abiertas

No lo que falta por elegir, sino **dónde el default elegido es más débil**. Vive aquí,
visible, en vez de disimulado entre las tablas de §3.

| Hueco   | Por qué importa |
| ------- | --------------- |
| [HUECO] | [RIESGO]        |

Cuando alguno se cierre de verdad (una librería se vuelve el estándar, aparece la pieza
que faltaba), se actualiza §3 y este hueco desaparece de la tabla.

**Escribir esta tabla vacía es peor que no tenerla.** Si crees que tu marco no tiene
puntos débiles, todavía no lo has usado lo suficiente.

## 6. Cómo desviarse

Este documento guarda **el default vigente**, no una verdad absoluta. Un default blando
no frena nada, así que el default es duro y romperlo tiene un precio fijo y barato:

**Desviarse es legítimo y cuesta escribir un ADR** en [`decisions/`](decisions/README.md)
que diga qué se rompió y por qué. El _qué_ queda en el código; el _porqué_ se pierde si
no se escribe.

Cuando una desviación se repite en tres productos, deja de ser desviación: se actualiza
este documento.
