#!/usr/bin/env bash
# secret-guardrails.sh — hook PreToolUse (Write|Edit|NotebookEdit|Bash) que
# bloquea accesos del agente a archivos de secretos: el `.env` real y llaves
# privadas. Convierte la regla "nunca le des secretos a un agente" de
# docs/conventions/ai-agents.md en una garantía dura. ACTIVO por defecto en
# settings.json; se desactiva quitándolo de ahí. Lo complementa el
# `permissions.deny` de settings.json, que cubre la lectura directa (Read).
#
# Para Bash es best-effort declarado: detecta las formas comunes de leer o
# escribir un secreto (redirecciones, cat/sed/cp/tee/source…), no todas las
# posibles. El objetivo es parar el accidente, no a un adversario.
#
# Contrato del hook: lee el JSON del evento por stdin y devuelve exit 2 para
# BLOQUEAR la herramienta — el motivo (stderr) se le muestra al agente. Exit 0
# permite. Ante cualquier duda, falla ABIERTO (permite) para no trabar el flujo.
set -euo pipefail

payload="$(cat)"

block() { echo "⛔ secret-guardrails: $1" >&2; exit 2; }

# ¿Es un basename de archivo de secretos? (0 = sí)
es_secreto() {
  case "$1" in
    # Las plantillas de configuración sí se tocan: son el contrato, sin valores reales.
    .env.example|.env.sample|.env.template) return 1 ;;
    .env|.env.*) return 0 ;;
    *.pem|*.key|id_rsa|id_rsa.*|id_ed25519|id_ed25519.*|id_ecdsa|id_ecdsa.*) return 0 ;;
  esac
  return 1
}

# ── Write / Edit / NotebookEdit: la ruta viene en el propio evento ───────────
path="$(printf '%s' "$payload" \
  | python3 -c 'import sys,json; ti=json.load(sys.stdin).get("tool_input",{}); print(ti.get("file_path") or ti.get("notebook_path") or "")' \
  2>/dev/null || true)"

if [ -n "$path" ]; then
  base="$(basename "$path")"
  if es_secreto "$base"; then
    case "$base" in
      .env|.env.*) block "No escribas en '$base': los valores reales de entorno no se tocan ni se leen. Edita .env.example en su lugar (docs/conventions/secrets.md)." ;;
      *) block "No escribas en '$base': parece una llave privada o certificado (SECURITY.md)." ;;
    esac
  fi
  exit 0
fi

# ── Bash: buscar tokens del comando que nombren un archivo de secretos ───────
cmd="$(printf '%s' "$payload" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' \
  2>/dev/null || true)"
[ -z "$cmd" ] && exit 0

# Detectar solo los usos que leen o escriben el archivo: una redirección cuyo
# destino es un secreto, o un comando lector/escritor conocido con un secreto
# como ARGUMENTO DE ARCHIVO. Tres matices, todos regresiones reales:
#   - En grep/sed/awk el primer argumento posicional es el PATRÓN o el
#     programa, no un archivo: `grep -n ".env" .gitignore` busca la cadena.
#   - Un heredoc (`<<EOF … EOF`) es CONTENIDO, no argumentos: un documento que
#     menciona .env treinta veces no lo está leyendo. Al ver `<<` se deja de
#     analizar (fail-open; la redirección de salida ya quedó evaluada antes).
#   - `cp .env.example .env` es el setup normal: crea el .env desde la
#     plantilla, sin valores reales de por medio.
# Mencionar el nombre no bloquea — `echo .env >> .gitignore` es legítimo y
# frecuente. shlex respeta comillas; no parseable = falla abierto.
ofensa="$(printf '%s' "$cmd" | python3 -c '
import os, re, shlex, sys

try:
    toks = shlex.split(sys.stdin.read())
except ValueError:
    sys.exit(0)

SEP = {"&&", "||", ";", "|"}
READERS = {"cat", "less", "more", "head", "tail", "grep", "egrep", "fgrep",
           "sed", "awk", "cut", "sort", "uniq", "strings", "xxd", "od",
           "source", "."}
WRITERS = {"tee", "cp", "mv", "ln", "install", "dd", "vi", "vim", "nano",
           "code", "open"}
# Su primer posicional no es un archivo (patrón, programa, script inline).
PRIMER_ARG_NO_ES_ARCHIVO = {"grep", "egrep", "fgrep", "sed", "awk"}
PLANTILLAS = {".env.example", ".env.sample", ".env.template"}

# shlex no separa `;`, `&` ni `|` cuando van PEGADOS al token anterior, así que
# `printf x > .env.example; ls` deja el separador dentro del nombre: el basename
# pasa a ser `.env.example;`, deja de coincidir con la lista de plantillas exentas
# y cae en `.env.*` → bloqueado. Escribir en `.env.example` es legítimo (es el
# contrato, sin valores reales) y esto lo impedía en cuanto el comando seguía en
# la misma línea. Es la misma familia que el parser de git-guardrails: puntuación
# leída como parte de un nombre.
def limpiar(b):
    return b.rstrip(";&|")


def secreto(b):
    b = limpiar(b)
    if b in PLANTILLAS:
        return False
    if b == ".env" or b.startswith(".env."):
        return True
    if b.endswith((".pem", ".key")):
        return True
    return b in ("id_rsa", "id_ed25519", "id_ecdsa") \
        or b.startswith(("id_rsa.", "id_ed25519.", "id_ecdsa."))

cmdword, prev_redir, args_vistos, desde_plantilla = None, False, 0, False
for t in toks:
    if t.startswith("<<"):
        sys.exit(0)  # heredoc: lo que sigue es contenido, no archivos
    if t in SEP:
        cmdword, prev_redir, args_vistos, desde_plantilla = None, False, 0, False
        continue
    if re.fullmatch(r"\d*(>>?|<)", t):
        prev_redir = True
        continue
    pegado = re.fullmatch(r"\d*(?:>>?|<)(.+)", t)
    tgt = pegado.group(1) if pegado else (t if prev_redir else None)
    prev_redir = False
    if tgt is not None:
        if secreto(os.path.basename(tgt)):
            print(os.path.basename(tgt))
            sys.exit(0)
        continue
    if cmdword is None:
        cmdword = os.path.basename(t)
        continue
    if t.startswith("-"):
        continue
    args_vistos += 1
    if cmdword in PRIMER_ARG_NO_ES_ARCHIVO and args_vistos == 1:
        continue
    if os.path.basename(t) in PLANTILLAS:
        desde_plantilla = True
    if cmdword in READERS or cmdword in WRITERS:
        if secreto(os.path.basename(t)):
            if cmdword in ("cp", "mv", "install") and desde_plantilla:
                continue  # cp .env.example .env: setup desde la plantilla
            print(os.path.basename(t))
            sys.exit(0)
' 2>/dev/null || true)"

if [ -n "$ofensa" ]; then
  block "El comando lee o escribe '$ofensa': los valores reales de secretos no se tocan desde el agente (docs/conventions/secrets.md). Si necesitas una variable nueva, declárala en .env.example y pide a la persona ponerle el valor."
fi

exit 0
