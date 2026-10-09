#!/bin/sh
# Chequeos estáticos del plugin. Uso: sh tests/check.sh (desde cualquier directorio).
# Resultado por stdout; cada falla por stderr. Sale con 1 si algo falla.

cd "$(dirname "$0")/.." || exit 1
fails=0

fail() {
  echo "FALLA: $1" >&2
  fails=$((fails + 1))
}

frontmatter() {
  sed -n '1,/^---$/p' "$1" | sed '1d'
}

has_line() {
  frontmatter "$1" | grep -qxF "$2" || fail "$1: falta '$2' en el frontmatter"
}

lacks_key() {
  frontmatter "$1" | grep -q "^$2:" && fail "$1: no debería declarar '$2'"
}

# REQ-2: familia, esfuerzo, tope de turnos y herramientas de cada worker
check_agent() {
  file="agents/$1.md"
  if [ ! -f "$file" ]; then
    fail "falta $file"
    return
  fi
  has_line "$file" "name: $1"
  has_line "$file" "model: $2"
  has_line "$file" "maxTurns: $4"
  has_line "$file" "tools: $5"
  if [ -n "$3" ]; then has_line "$file" "effort: $3"; else lacks_key "$file" effort; fi
}

check_agent explorador haiku "" 20 "Read, Grep, Glob, Bash, WebFetch, WebSearch"
check_agent verificador haiku "" 10 "Read, Grep, Glob, Bash"
check_agent mecanico haiku "" 30 "Read, Edit, Write, Grep, Glob, Bash"
check_agent ejecutor sonnet medium 40 "Read, Edit, Write, Grep, Glob, Bash, WebFetch"
check_agent navegador sonnet medium 30 "Read, mcp__claude-in-chrome__tabs_context_mcp, mcp__claude-in-chrome__tabs_create_mcp, mcp__claude-in-chrome__tabs_close_mcp, mcp__claude-in-chrome__navigate, mcp__claude-in-chrome__computer, mcp__claude-in-chrome__read_page, mcp__claude-in-chrome__get_page_text, mcp__claude-in-chrome__find, mcp__claude-in-chrome__form_input, mcp__claude-in-chrome__javascript_tool, mcp__claude-in-chrome__read_console_messages, mcp__claude-in-chrome__read_network_requests, mcp__claude-in-chrome__resize_window, mcp__claude-in-chrome__browser_batch"

# REQ-1, REQ-3, REQ-6: la skill existe y contempla el nombre con prefijo de plugin
skill=skills/orquestar/SKILL.md
if [ -f "$skill" ]; then
  has_line "$skill" "name: orquestar"
  grep -qF 'orquestar:<worker>' "$skill" || fail "$skill: no explica el nombre con prefijo de plugin"
else
  fail "falta $skill"
fi

# REQ-1: el nombre del plugin coincide entre manifiestos
for manifest in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  grep -qF '"name": "orquestar"' "$manifest" || fail "$manifest: el plugin no se llama 'orquestar'"
done

# REQ-4: ninguna versión de modelo en lo que se distribuye. intent/ queda afuera porque
# describe el problema original citando las versiones que había.
versions=$(grep -rnEi '(haiku|sonnet|opus|fable)[ -]?[0-9]' \
  README.md skills agents .claude-plugin 2>/dev/null)
[ -n "$versions" ] && fail "versiones de modelo encontradas:
$versions"

# REQ-4, REQ-5: secciones del README en orden y enlace a los precios oficiales
if [ -f README.md ]; then
  prev=0
  for heading in "Qué resuelve" "Instalación" "Comprobar que quedó instalado" "Uso" \
    "Los workers" "Cuándo conviene delegar" "Actualizar y desinstalar" "Instalación manual"; do
    line=$(grep -nxF "## $heading" README.md | head -n 1 | cut -d: -f1)
    if [ -z "$line" ]; then
      fail "README.md: falta la sección '## $heading'"
    elif [ "$line" -le "$prev" ]; then
      fail "README.md: '## $heading' está fuera de orden"
    else
      prev=$line
    fi
  done
  grep -qF 'https://platform.claude.com/docs/en/about-claude/pricing' README.md \
    || fail "README.md: falta el enlace a los precios oficiales"
else
  fail "falta README.md"
fi

# REQ-7: licencia MIT
[ "$(head -n 1 LICENSE 2>/dev/null)" = "MIT License" ] || fail "LICENSE no es MIT"

if [ "$fails" -gt 0 ]; then
  echo "$fails chequeo(s) fallaron"
  exit 1
fi
echo "OK: todos los chequeos pasaron"
