# claude-orquestador

Plugin de Claude Code para gastar menos tokens: la sesión principal (Opus) planifica, decide y
revisa, y reparte la lectura, la búsqueda, la ejecución y la verificación en 5 subagentes que
corren en modelos más baratos (Haiku y Sonnet). Cada worker devuelve un reporte de 15 líneas
como máximo, así Opus no lee archivos ni logs enteros.

## Qué resuelve

Por defecto, los subagentes de Claude Code (`Explore`, `general-purpose`) usan **el mismo modelo
que tu sesión**. Si trabajás con Opus, delegar en ellos no ahorra nada.

Este plugin trae dos cosas:

- La skill `orquestar`, que le enseña a la sesión principal cuándo conviene delegar, cómo partir
  la tarea, a qué worker mandar cada parte, cómo escribir el brief y cómo verificar lo que vuelve.
- 5 workers con el modelo fijado por familia (`haiku` o `sonnet`). Como usan el alias y no una
  versión, siguen funcionando cuando salen modelos nuevos.

Por token, Haiku es la familia más barata, Sonnet la intermedia y Opus la más cara; en lectura
de caché la diferencia es menor. Las cifras cambian con cada modelo: mirá los
[precios oficiales](https://platform.claude.com/docs/en/about-claude/pricing).

El ahorro no está medido con un benchmark propio. Después de la primera tarea real, revisá
`/usage` para ver si te rinde.

## Instalación

Necesitás Claude Code actualizado: los campos `effort` y `maxTurns` de los workers no existen en
versiones viejas. Probado con la 2.1.295.

En tu terminal:

```bash
claude plugin install orquestar --marketplace Ranteck/claude-orquestador
```

O dentro de una sesión de Claude Code:

```
/plugin install orquestar --marketplace Ranteck/claude-orquestador
```

Si usás varios perfiles de Claude Code (por ejemplo, con `CLAUDE_CONFIG_DIR`), instalalo en cada
uno: los plugins de un perfil no aparecen en otro.

Después **abrí una sesión nueva**: los agentes no aparecen en la sesión donde los instalaste.

## Comprobar que quedó instalado

```bash
claude plugin details orquestar
```

Tiene que listar la skill `orquestar` y los agentes `explorador`, `verificador`, `mecanico`,
`ejecutor` y `navegador`. También podés preguntarle a una sesión nueva "¿qué subagentes tenés
disponibles?": tienen que aparecer como `orquestar:explorador`, `orquestar:verificador`, etc.

## Uso

Escribí `/orquestar:orquestar <tarea>` o pedí "orquestá esto". La skill también se activa sola
ante tareas con muchas piezas independientes, o si pedís "usá subagentes" o "ahorrá tokens".

```
/orquestar:orquestar revisá los 8 módulos de src/ y decime cuáles no tienen tests
```

Qué pasa después:

1. Opus decide si conviene delegar. Si la tarea es una sola cadena de pasos dependientes, te lo
   dice en una línea y la hace directo.
2. Parte la tarea en unidades, cada una con objetivo, entradas, criterio de "terminado" y
   formato de salida.
3. Manda cada unidad al worker más barato que la resuelve, en paralelo cuando son independientes.
4. Verifica lo que vuelve: revisa las citas `archivo:línea` de las que depende una decisión y
   hace correr los tests a un `verificador` aparte.
5. Te cierra con qué se hizo, cómo se verificó y cómo se repartió el trabajo.

El plan nunca sale de Opus. Ningún worker recibe un plan entero ni decisiones de diseño: reciben
pedidos concretos y cerrados. Si algo no encaja con lo que dice el brief, se frenan y lo reportan.

## Los workers

| Worker | Modelo | Para qué |
|---|---|---|
| `explorador` | Haiku, solo lectura | Buscar código y resumir archivos, docs o páginas, siempre con `archivo:línea` |
| `verificador` | Haiku | Correr tests, lint o build y resumir los fallos, sin arreglarlos |
| `mecanico` | Haiku | Cambios exactos: renombres, reemplazos, textos, boilerplate |
| `ejecutor` | Sonnet, esfuerzo medio | Implementar cambios acotados con una especificación clara |
| `navegador` | Sonnet, esfuerzo medio | Usar el navegador; se frena antes de guardar o enviar si no lo aprobaste |

Notas:

- Cada worker tiene un tope de turnos (`maxTurns`). El límite de 15 líneas acota el reporte, no
  lo que el worker gasta por dentro.
- Ante la duda entre Haiku y Sonnet, la skill elige Sonnet. Si un worker falla, reintenta una vez
  subiendo de escalón (Haiku → Sonnet → Opus); si vuelve a fallar, lo hace Opus.
- `navegador` usa la extensión **Claude in Chrome** (herramientas `mcp__claude-in-chrome__*`),
  que funciona desde la terminal. Sin la extensión, arranca sin herramientas de navegador.
- Que `explorador` y `verificador` usen Bash solo para leer o correr comandos lo pide su prompt;
  Claude Code no lo bloquea. Si necesitás garantías, agregá reglas de `permissions.deny`.
- En Windows, agregá `PowerShell` a los `tools` de `explorador`, `verificador`, `mecanico` y
  `ejecutor` (en Linux y macOS no existe).

## Cuándo conviene delegar

Delegar tiene un costo fijo: el brief, el arranque del subagente sin caché compartida, el reporte
y la revisión. Solo paga cuando hay volumen para repartir.

Conviene si se cumple al menos una:

- Hay 3 o más piezas independientes (archivos, módulos, búsquedas, tickets, páginas).
- Hay una lectura o búsqueda grande de la que solo necesitás la conclusión.
- Es trabajo mecánico bien especificado (renombres, cambios repetitivos, correr tests y resumir).

No conviene si es una cadena donde cada paso depende del anterior (debug fino, diseño), si son
menos de 3 archivos, o si hace falta el contexto intermedio para juzgar bien.

Anthropic lo midió ([fuente](https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence)):
un coordinador grande con 25 workers Sonnet salió 47–55% más barato que los modelos solos, pero
sacó 10–12 puntos menos de calidad. Por eso la skill trata la verificación como obligatoria.

## Actualizar y desinstalar

Actualizar:

```bash
claude plugin marketplace update claude-orquestador
claude plugin update orquestar@claude-orquestador
```

Desinstalar:

```bash
claude plugin uninstall orquestar@claude-orquestador
claude plugin marketplace remove claude-orquestador
```

## Instalación manual

Si no querés usar plugins, copiá los archivos a tu perfil (`~/.claude`, o
`C:\Users\<tu usuario>\.claude` en Windows):

```bash
git clone https://github.com/Ranteck/claude-orquestador.git
mkdir -p ~/.claude/skills ~/.claude/agents
cp -r claude-orquestador/skills/orquestar ~/.claude/skills/
cp claude-orquestador/agents/*.md ~/.claude/agents/
```

Así los nombres no llevan prefijo: la skill se invoca con `/orquestar` y los agentes se llaman
`explorador`, `verificador`, etc. La skill reconoce las dos formas.

Opcional: si agregás `"env": { "CLAUDE_CODE_SUBAGENT_MODEL": "sonnet" }` al `settings.json` de tu
perfil, cualquier subagente lanzado sin modelo asignado corre en Sonnet en vez de heredar el de la
sesión.

## Licencia

[MIT](LICENSE)
