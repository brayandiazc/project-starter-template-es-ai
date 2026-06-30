# Convención de agentes de IA

> Cómo trabajamos con agentes de codificación con IA en [NOMBRE_DEL_PROYECTO].
> **Última actualización**: [FECHA]

## Fuente de verdad

- [`AGENTS.md`](../../AGENTS.md) es el archivo de instrucciones canónico para cualquier agente.
- [`CLAUDE.md`](../../CLAUDE.md) es un puente de una línea que importa `AGENTS.md`
  (Claude Code lee `CLAUDE.md`; otras herramientas leen `AGENTS.md`).
- Los [subagentes](../../.claude/agents) y las [skills](../../.claude/skills) reutilizables
  están versionados y se comparten con el equipo.

## Qué delegamos a la IA

- ✅ Redactar código, pruebas y documentación; explorar el código; revisar diffs;
  proponer diseños y ADRs; refactorizaciones rutinarias.
- ⚠️ Cualquier cosa que toque autenticación, criptografía, pagos o migraciones de datos →
  requiere escrutinio humano adicional.
- ❌ Aprobación final. **Una persona es responsable de cada merge.**

## Reglas

- **La revisión humana es obligatoria.** El código generado por IA pasa por el mismo proceso de PR y
  revisión que cualquier otro cambio ([`../../CONTRIBUTING.md`](../../CONTRIBUTING.md)).
- **Nunca le des secretos a un agente** (claves, tokens, `.env` real, datos de clientes).
  Consulta [`secrets.md`](secrets.md) y [`../../SECURITY.md`](../../SECURITY.md).
- **Los agentes se remiten a la documentación.** Las convenciones en `docs/` prevalecen sobre los valores
  por defecto del modelo.
- **Verifica antes de confiar.** Las dependencias, APIs y rutas de archivo que cite un agente
  deben comprobarse — los agentes pueden alucinar.
- **Mantén los cambios acotados.** Un cambio lógico por PR; sin reformateos no relacionados.

## Atribución

Marca los commits asistidos por IA con un trailer para que la autoría sea transparente:

```
Co-Authored-By: [HERRAMIENTA_IA] <[EMAIL_HERRAMIENTA_IA]>
```

## Cambios guiados por especificaciones (opcional)

Para trabajo no trivial, captura la intención antes de escribir código usando el flujo ligero en
[`../../specs/`](../../specs/README.md): una propuesta breve, una lista de tareas y
una nota de diseño. Esto les da a los agentes (y a las personas) un objetivo claro y un punto de revisión.

## Servidores MCP (opcional)

Esta plantilla incluye un [`.mcp.json.example`](../../.mcp.json.example) con un
servidor recomendado y agnóstico al stack:

- **Context7** (Upstash) — obtiene documentación de librerías **actualizada y por
  versión**, para que los agentes no dependan de conocimiento de API obsoleto. No
  requiere API key.

Para activarlo, copia el archivo y reinicia Claude Code:

```bash
cp .mcp.json.example .mcp.json
```

Claude Code pide aprobación antes de usar cualquier servidor MCP del proyecto.

- **No** agregues servidores MCP para archivos, búsqueda o web — las herramientas
  integradas de Claude Code ya lo cubren.
- **Nunca** pongas secretos en `.mcp.json`. Referencia variables de entorno (p. ej.
  `${GITHUB_TOKEN}`) y documéntalas en `.env.example` (ver [`secrets.md`](secrets.md)).
- Agrega servidores específicos de tu proyecto (GitHub, Playwright, un MCP de base
  de datos, etc.) según lo necesite tu stack.
