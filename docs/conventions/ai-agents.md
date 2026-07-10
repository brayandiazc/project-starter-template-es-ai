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

## Memoria del agente vs. documentación

Algunas herramientas mantienen una **memoria persistente** por proyecto (p. ej. la
auto-memoria de Claude Code). Úsala solo para lo personal y efímero (preferencias,
correcciones recurrentes) y pódala con frecuencia. Todo conocimiento **duradero o de
equipo** — decisiones, convenciones, contexto del dominio — pertenece al repositorio:
`docs/`, los ADRs de [`../decisions/`](../decisions/README.md) y el `CHANGELOG.md`.
Si un agente "recuerda" algo que el equipo necesita saber, ese recuerdo está en el
lugar equivocado: conviértelo en documentación versionada.

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

## Guardrails deterministas (opcional)

Las reglas de [`AGENTS.md`](../../AGENTS.md) le dicen al agente qué **debería** hacer, pero
no lo obligan. Para una garantía dura, esta plantilla incluye dos hooks opt-in que
**bloquean de forma determinista** — el agente no puede saltárselos:

- [`.claude/hooks/git-guardrails.sh`](../../.claude/hooks/git-guardrails.sh) — bloquea
  las acciones que rompen el branching de [`../../CONTRIBUTING.md`](../../CONTRIBUTING.md):
  commits o push directos a `main`/`develop` y force-push a ramas compartidas. Cubre
  también `git -C <ruta>` y comandos encadenados con `&&`.
- [`.claude/hooks/secret-guardrails.sh`](../../.claude/hooks/secret-guardrails.sh) —
  bloquea escrituras del agente sobre archivos de secretos: el `.env` real (y variantes
  como `.env.local`) y llaves privadas (`*.pem`, `id_rsa`…). `.env.example` sí se puede
  editar: es el contrato, sin valores reales.

No están activos por defecto. Para habilitarlos, añade los hooks a
`.claude/settings.local.json` (personal) o a `.claude/settings.json` (compartido):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/git-guardrails.sh"
          }
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/secret-guardrails.sh"
          }
        ]
      }
    ]
  }
}
```

Requieren `python3` (para leer el evento). Ambos scripts fallan _abiertos_: ante la duda
permiten, para no trabar el flujo. Sus casos cubiertos están probados en
`.github/scripts/tests/run-tests.sh` (corre en CI). La skill `/instanciar` ofrece
activarlos en su paso de permisos.
