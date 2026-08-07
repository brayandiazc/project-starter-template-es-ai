#!/usr/bin/env bash
# run-tests.sh — pruebas de los scripts y hooks de la plantilla.
# Se ejecutan en CI (workflow quality.yml) y localmente con:
#   bash .github/scripts/tests/run-tests.sh
#
# Requiere: git, perl, python3. Sale con 1 si alguna prueba falla.
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
GIT_HOOK="$REPO_ROOT/.claude/hooks/git-guardrails.sh"
SECRET_HOOK="$REPO_ROOT/.claude/hooks/secret-guardrails.sh"
CHECK_PLACEHOLDERS="$REPO_ROOT/.github/scripts/check-placeholders.sh"
CHECK_LINKS="$REPO_ROOT/.github/scripts/check-links.sh"
CHECK_SKILLS="$REPO_ROOT/.github/scripts/check-skills.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

# check <descripción> <exit-esperado> <exit-obtenido>
check() {
  if [ "$2" -eq "$3" ]; then
    echo "  ✅ $1"
    pass=$((pass + 1))
  else
    echo "  ❌ $1 (esperado exit=$2, obtenido exit=$3)"
    fail=$((fail + 1))
  fi
}

# Simula el payload JSON de un evento PreToolUse de Bash.
bash_payload() { printf '{"tool_input":{"command":"%s"}}' "$1"; }
# Simula el payload de un evento PreToolUse de Write/Edit.
write_payload() { printf '{"tool_input":{"file_path":"%s"}}' "$1"; }

# Repos git de utilería: uno en main, otro en una rama de feature.
git -C "$TMP" init -q -b main repo-main
git -C "$TMP" init -q -b feat/x repo-feat

# ── git-guardrails.sh ─────────────────────────────────────────────────────────
if [ -f "$GIT_HOOK" ]; then
  echo "git-guardrails.sh:"
  run_git_hook() { (cd "$1" && bash "$GIT_HOOK" <<<"$(bash_payload "$2")" 2>/dev/null); }

  run_git_hook "$TMP/repo-main" "ls -la"; check "comando no-git → permite" 0 $?
  run_git_hook "$TMP/repo-main" "git commit -m x"; check "commit en main → bloquea" 2 $?
  run_git_hook "$TMP/repo-feat" "git commit -m x"; check "commit en rama feat → permite" 0 $?
  run_git_hook "$TMP/repo-main" "git push origin main"; check "push desde main → bloquea" 2 $?
  run_git_hook "$TMP/repo-feat" "git push origin feat/x"; check "push desde feat → permite" 0 $?
  run_git_hook "$TMP/repo-feat" "git push --force origin feat/x"; check "force-push → bloquea" 2 $?
  run_git_hook "$TMP" "git -C $TMP/repo-main commit -m x"; check "git -C <repo en main> commit → bloquea" 2 $?
  run_git_hook "$TMP" "git -C $TMP/repo-feat commit -m x"; check "git -C <repo en feat> commit → permite" 0 $?
  run_git_hook "$TMP/repo-main" "git merge feat/x"; check "merge local en main → bloquea" 2 $?
  run_git_hook "$TMP/repo-main" "git checkout -b feat/y"; check "crear feat/* desde main → bloquea" 2 $?
  run_git_hook "$TMP/repo-main" "git switch -c fix/z"; check "switch -c fix/* desde main → bloquea" 2 $?
  run_git_hook "$TMP/repo-main" "git branch feat/y"; check "git branch feat/* en main → bloquea" 2 $?
  run_git_hook "$TMP/repo-main" "git checkout -b develop"; check "crear develop desde main → permite" 0 $?
  run_git_hook "$TMP/repo-main" "git checkout -b hotfix/urgente"; check "crear hotfix/* desde main → permite" 0 $?
  run_git_hook "$TMP/repo-feat" "git checkout -b feat/z"; check "crear rama desde feat → permite" 0 $?
  run_git_hook "$TMP/repo-feat" "git checkout -b feat/z main"; check "crear rama con base main explícita → bloquea" 2 $?
  run_git_hook "$TMP/repo-main" "git branch --list"; check "git branch --list en main → permite" 0 $?
  run_git_hook "$TMP/repo-main" "git checkout feat/x"; check "checkout sin crear rama → permite" 0 $?
fi

# ── secret-guardrails.sh ──────────────────────────────────────────────────────
if [ -f "$SECRET_HOOK" ]; then
  echo "secret-guardrails.sh:"
  run_secret_hook() { bash "$SECRET_HOOK" <<<"$(write_payload "$1")" 2>/dev/null; }

  run_secret_hook "/proyecto/.env"; check "escribir .env → bloquea" 2 $?
  run_secret_hook "/proyecto/.env.local"; check "escribir .env.local → bloquea" 2 $?
  run_secret_hook "/proyecto/.env.example"; check "escribir .env.example → permite" 0 $?
  run_secret_hook "/proyecto/certs/server.pem"; check "escribir *.pem → bloquea" 2 $?
  run_secret_hook "/proyecto/README.md"; check "escribir README.md → permite" 0 $?
fi

# ── check-placeholders.sh ─────────────────────────────────────────────────────
echo "check-placeholders.sh:"
make_repo() { # $1 = nombre; crea un repo git en $TMP/$1
  mkdir -p "$TMP/$1" && git -C "$TMP/$1" init -q -b main
}
commit_all() { git -C "$1" add -A && git -C "$1" -c user.email=t@t -c user.name=t commit -qm t; }

# Modo plantilla: placeholder catalogado → pasa.
make_repo tpl-ok
printf '| `[NOMBRE_DEL_PROYECTO]` | nombre |\n' >"$TMP/tpl-ok/TEMPLATE-USAGE.md"
printf '# [NOMBRE_DEL_PROYECTO]\n' >"$TMP/tpl-ok/README.md"
commit_all "$TMP/tpl-ok"
(bash "$CHECK_PLACEHOLDERS" "$TMP/tpl-ok" >/dev/null); check "plantilla: catalogado → pasa" 0 $?

# Modo plantilla: placeholder sin catalogar → falla.
make_repo tpl-bad
printf '| `[NOMBRE_DEL_PROYECTO]` | nombre |\n' >"$TMP/tpl-bad/TEMPLATE-USAGE.md"
printf '# [SIN_CATALOGAR]\n' >"$TMP/tpl-bad/README.md"
commit_all "$TMP/tpl-bad"
(bash "$CHECK_PLACEHOLDERS" "$TMP/tpl-bad" >/dev/null); check "plantilla: sin catalogar → falla" 1 $?

# Modo plantilla: comodín `[COMANDO_*]` cubre COMANDO_TEST → pasa.
make_repo tpl-wild
printf '| `[COMANDO_*]` | comandos |\n' >"$TMP/tpl-wild/TEMPLATE-USAGE.md"
printf 'Corre [COMANDO_TEST]\n' >"$TMP/tpl-wild/README.md"
commit_all "$TMP/tpl-wild"
(bash "$CHECK_PLACEHOLDERS" "$TMP/tpl-wild" >/dev/null); check "plantilla: comodín cubre → pasa" 0 $?

# Modo instancia: queda un placeholder → falla.
make_repo inst-bad
printf '# Mi proyecto\nFalta [COMANDO_TEST]\n' >"$TMP/inst-bad/README.md"
commit_all "$TMP/inst-bad"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-bad" >/dev/null); check "instancia: placeholder pendiente → falla" 1 $?

# Modo instancia: limpio (los enlaces markdown [X](y) no cuentan) → pasa.
make_repo inst-ok
printf '# Mi proyecto\nVer [MIT](LICENSE).\n' >"$TMP/inst-ok/README.md"
commit_all "$TMP/inst-ok"
(bash "$CHECK_PLACEHOLDERS" "$TMP/inst-ok" >/dev/null); check "instancia: limpio → pasa" 0 $?

# ── check-links.sh ────────────────────────────────────────────────────────────
echo "check-links.sh:"
make_repo links-ok
printf 'Ver [docs](docs/guia.md) y [web](https://example.com) y [ancla](#uso).\n' >"$TMP/links-ok/README.md"
mkdir -p "$TMP/links-ok/docs" && printf 'hola\n' >"$TMP/links-ok/docs/guia.md"
commit_all "$TMP/links-ok"
(bash "$CHECK_LINKS" "$TMP/links-ok" >/dev/null); check "enlaces válidos → pasa" 0 $?

make_repo links-bad
printf 'Ver [docs](docs/no-existe.md).\n' >"$TMP/links-bad/README.md"
commit_all "$TMP/links-bad"
(bash "$CHECK_LINKS" "$TMP/links-bad" >/dev/null); check "enlace roto → falla" 1 $?

# ── check-skills.sh ───────────────────────────────────────────────────────────
if [ -f "$CHECK_SKILLS" ]; then
  echo "check-skills.sh:"
  make_skill() { # $1 = repo, $2 = carpeta, $3 = frontmatter completo
    mkdir -p "$TMP/$1/.claude/skills/$2"
    printf '%s\n\ncuerpo\n' "$3" >"$TMP/$1/.claude/skills/$2/SKILL.md"
  }
  DESC_OK="description: Hace X. Úsalo cuando la persona pida X o Y (p. ej. \"haz X\")."

  mkdir -p "$TMP/sk-ok"
  make_skill sk-ok mi-skill "$(printf -- '---\nname: mi-skill\n%s\n---' "$DESC_OK")"
  (bash "$CHECK_SKILLS" "$TMP/sk-ok" >/dev/null); check "skill válida → pasa" 0 $?

  mkdir -p "$TMP/sk-mismatch"
  make_skill sk-mismatch mi-skill "$(printf -- '---\nname: otro-nombre\n%s\n---' "$DESC_OK")"
  (bash "$CHECK_SKILLS" "$TMP/sk-mismatch" >/dev/null); check "name ≠ carpeta → falla" 1 $?

  mkdir -p "$TMP/sk-nodesc"
  make_skill sk-nodesc mi-skill "$(printf -- '---\nname: mi-skill\ndescription: corta\n---')"
  (bash "$CHECK_SKILLS" "$TMP/sk-nodesc" >/dev/null); check "description corta → falla" 1 $?

  mkdir -p "$TMP/sk-agent/.claude/agents"
  printf -- '---\nname: revisor\ndescription: Revisa diffs del proyecto.\n---\ncuerpo\n' \
    >"$TMP/sk-agent/.claude/agents/otro.md"
  (bash "$CHECK_SKILLS" "$TMP/sk-agent" >/dev/null); check "agente name ≠ archivo → falla" 1 $?

  mkdir -p "$TMP/sk-none"
  (bash "$CHECK_SKILLS" "$TMP/sk-none" >/dev/null); check "repo sin capa de IA → pasa" 0 $?
fi

# ── check-herencia.sh ─────────────────────────────────────────────────────────
CHECK_HERENCIA="$REPO_ROOT/.github/scripts/check-herencia.sh"
if [ -f "$CHECK_HERENCIA" ]; then
  echo "check-herencia.sh:"

  instancia() { # $1 = nombre, $2 = fecha de instanciación
    mkdir -p "$TMP/$1/docs/decisions"
    printf 'repo=https://github.com/x/y\ncommit=abc\nfecha=%s\n' "$2" >"$TMP/$1/.template-origin"
  }
  run_herencia() { (bash "$CHECK_HERENCIA" "$TMP/$1" > /dev/null 2>&1); }

  # Sin .template-origin no es una instancia: la plantilla misma no se toca.
  mkdir -p "$TMP/hr-plantilla"
  run_herencia hr-plantilla; check "sin .template-origin → permite" 0 $?

  # Proyecto recién instanciado y limpio.
  instancia hr-ok 2026-08-07
  printf '# Changelog\n\n## [Unreleased]\n\n## [0.1.0] - 2026-08-08\n\n- Inicio.\n' \
    >"$TMP/hr-ok/CHANGELOG.md"
  run_herencia hr-ok; check "instancia limpia → pasa" 0 $?

  # Versión del CHANGELOG anterior a la instanciación = herencia.
  instancia hr-changelog 2026-08-07
  printf '# Changelog\n\n## [Unreleased]\n\n## [0.3.0] - 2026-08-02\n\n- De la plantilla.\n' \
    >"$TMP/hr-changelog/CHANGELOG.md"
  run_herencia hr-changelog; check "CHANGELOG con versión previa → falla" 1 $?

  # ADR anterior a la instanciación = decisión de la plantilla.
  instancia hr-adr 2026-08-07
  printf '# 0004. Guardrails\n\n- **Fecha**: 2026-08-02\n' \
    >"$TMP/hr-adr/docs/decisions/0004-guardrails.md"
  run_herencia hr-adr; check "ADR con fecha previa → falla" 1 $?

  # …pero el 0001 es el ADR canónico y SÍ se hereda.
  instancia hr-adr-canonico 2026-08-07
  printf '# 0001. Registrar decisiones\n\n- **Fecha**: 2026-07-01\n' \
    >"$TMP/hr-adr-canonico/docs/decisions/0001-record-architecture-decisions.md"
  run_herencia hr-adr-canonico; check "ADR 0001 canónico → se hereda, pasa" 0 $?

  # Archivos exclusivos del repo-plantilla.
  instancia hr-parity 2026-08-07
  mkdir -p "$TMP/hr-parity/.github/scripts"
  printf '#!/bin/bash\n' >"$TMP/hr-parity/.github/scripts/check-parity.sh"
  run_herencia hr-parity; check "check-parity.sh sobrante → falla" 1 $?

  # Fecha ilegible: falla abierto, no traba el flujo.
  mkdir -p "$TMP/hr-fecha"
  printf 'repo=x\nfecha=ayer\n' >"$TMP/hr-fecha/.template-origin"
  run_herencia hr-fecha; check "fecha inválida → permite" 0 $?
fi

# ── Estructura de .github/workflows/ ──────────────────────────────────────────
# GitHub ejecuta CUALQUIER .yml/.yaml de esa carpeta, sin mirar el resto del
# nombre: un `ci.example.yml` se ejecuta de verdad y sale en verde sin probar
# nada. Lo que no deba ejecutarse no puede terminar en .yml/.yaml.
WORKFLOWS="$REPO_ROOT/.github/workflows"
if [ -d "$WORKFLOWS" ]; then
  echo "estructura de .github/workflows:"
  ejemplos_ejecutables="$(ls "$WORKFLOWS" | grep -Ei '(example|sample|plantilla|template)\.ya?ml$' || true)"
  [ -z "$ejemplos_ejecutables" ]
  check "ningún workflow de ejemplo termina en .yml/.yaml" 0 $?
  [ -n "$ejemplos_ejecutables" ] && printf '     · %s\n' $ejemplos_ejecutables
fi

# ── Resumen ───────────────────────────────────────────────────────────────────
echo ""
echo "Resultado: $pass OK, $fail fallidas."
[ "$fail" -eq 0 ] || exit 1
