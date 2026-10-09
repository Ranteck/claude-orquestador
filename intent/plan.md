# Plan: claude-orquestador (desde spec.md 2026-10-08 e intent.md 2026-10-08)
Estado: aceptado

## Archivos que cambian
Existentes: `intent/intent.md` y `intent/spec.md` (sin cambios). Todo lo demás es nuevo:
- `.claude-plugin/plugin.json`: plugin `orquestar`, versión 0.1.0, MIT, autor y repo.
- `.claude-plugin/marketplace.json`: marketplace `claude-orquestador` con una entrada `orquestar`
  y `source: "./"` (formato verificado en la documentación oficial de plugins).
- `skills/orquestar/SKILL.md` y `agents/{explorador,verificador,mecanico,ejecutor,navegador}.md`:
  extraídos del archivo corregido, con dos cambios. (1) Sin versiones de modelo: costos en
  términos relativos y la medición de Anthropic citada por familia. (2) Una línea en la skill que
  indica usar el nombre exacto que figure en la lista de agentes: `orquestar:<worker>` si se
  instaló como plugin, `<worker>` si se copió a mano.
- `README.md`: en español, con las 8 secciones de REQ-5 en ese orden.
- `LICENSE`: MIT, con el mismo titular que ai-native-sdlc.
- `tests/check.sh`: chequeos estáticos con `sh` y `grep`, sin dependencias.

## Tests a escribir
| Test (comportamiento observable) | REQ que cubre |
| --- | --- |
| `claude plugin validate .` no informa errores | REQ-1, REQ-2 |
| `check.sh`: cada agente declara la familia, el esfuerzo, el `maxTurns` y las herramientas del archivo corregido | REQ-2 |
| `check.sh`: los nombres de plugin y marketplace coinciden entre manifiestos | REQ-1 |
| `check.sh`: ningún archivo contiene una familia de modelo seguida de un número de versión | REQ-4 |
| `check.sh`: el README tiene las 8 secciones en orden y enlaza a los precios oficiales | REQ-4, REQ-5 |
| `check.sh`: `LICENSE` es MIT | REQ-7 |
| Diff contra el archivo corregido: solo cambian versiones de modelo y la línea de nombres | REQ-3 |
| `claude -p --plugin-dir .` con una tarea de 3 o más piezas independientes: delega con `Agent` en workers `orquestar:*` y nunca en `general-purpose` ni `Explore` | REQ-3 |
| `claude -p --plugin-dir .` con una cadena dependiente: no llama a `Agent` | REQ-3 |
| `claude -p` en un directorio temporal con la skill y los agentes copiados a `.claude/`: delega en workers sin prefijo | REQ-6 |
| Búsqueda de secretos y datos personales (patrones de tokens, emails, rutas de home) sin hallazgos | REQ-7 |
| `gh repo view`: público y MIT | REQ-7 |
| En cada perfil, instalado desde GitHub, `claude plugin details orquestar` lista la skill y los 5 agentes | REQ-1, REQ-8 |

## Orden de trabajo
1. `git init` en `~/Proyectos/claude-orquestador`, `LICENSE` y los dos manifiestos (REQ-1, REQ-7).
2. Escribir `tests/check.sh` y verlo fallar (REQ-2, REQ-4, REQ-5).
3. Crear la skill y los 5 agentes desde el archivo corregido, con los dos cambios (REQ-2, REQ-3,
   REQ-4).
4. Escribir el README (REQ-5, REQ-6).
5. Correr `check.sh`, `claude plugin validate .` y el diff contra el original (REQ-1 a REQ-5).
6. Pruebas en modo headless: delegar, no delegar e instalación manual (REQ-3, REQ-6).
7. Búsqueda de secretos y datos personales; commit local (REQ-7).
8. **Frenar y pedir confirmación explícita para publicar** (REQ-7).
9. Con el OK: `gh repo create Ranteck/claude-orquestador --public` y push (REQ-7).
10. Instalar desde GitHub en `~/.claude` y `~/.claude-personal` y verificar (REQ-1, REQ-8).

## Riesgos
- **Delegación no determinista:** con piezas chicas, Opus puede decidir hacerlo directo, como
  la skill permite. Uso una tarea con volumen real y hasta 2 intentos. Si nunca delega, lo
  informo como hallazgo; no aflojo el test.
- **Perfil `~/.claude`:** esta sesión tiene `CLAUDE_CONFIG_DIR=~/.claude-personal`. Para el otro
  perfil corro los comandos sin esa variable, no apuntándola a `~/.claude`, porque cambia dónde
  se lee la configuración global.
- **Caché de plugins:** lo instalado es una copia. Cambios futuros requieren subir la versión y
  correr `/plugin update`; el README lo explica.
- **Enlace de precios:** puede moverse; compruebo que responda antes de publicar.
- **Herramientas en background:** todas las que usan los workers figuran entre las que Claude
  Code mantiene para subagentes en background (verificado en la documentación).

## Prueba
- `sh tests/check.sh` sale con código 0 → REQ-1, REQ-2, REQ-4, REQ-5, REQ-7 (licencia).
- `claude plugin validate .` sin errores → REQ-1, REQ-2.
- Diff revisado de cada archivo contra su bloque original → REQ-3.
- Transcripts `stream-json` de las 3 corridas headless: `subagent_type` usados o ausencia de
  `Agent` → REQ-3, REQ-6.
- Búsqueda de secretos limpia antes del push; `gh repo view --json visibility,licenseInfo` →
  REQ-7.
- `claude plugin list` y `claude plugin details orquestar` en ambos perfiles → REQ-1, REQ-8.
  Chequeo manual tuyo: abrir una sesión nueva y preguntar qué subagentes hay.
