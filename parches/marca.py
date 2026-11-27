#!/usr/bin/env python3
# Aplica la marca SOLUCODE sobre un clon de anomalyco/opencode (v2.4.2).
# Uso: python3 marca.py <raiz del clon>
import sys, pathlib

raiz = pathlib.Path(sys.argv[1])
MENSAJE = "Para actualizar SOLUCODE, vuelve a correr: irm https://router.conversus.digital/instalar.ps1 | iex"

def cambiar(ruta, viejo, nuevo, veces=1):
    p = raiz / ruta
    texto = p.read_text(encoding="utf-8")
    n = texto.count(viejo)
    if n != veces:
        sys.exit(f"{ruta}: se esperaba {veces} vez/veces y hay {n}: {viejo[:60]!r}")
    p.write_text(texto.replace(viejo, nuevo), encoding="utf-8")

# 1. El logo: «solu» atenuado y «code» en negrita, como «open» y «code».
cambiar("packages/tui/src/logo.ts",
    '  left: ["                   ", "█▀▀█ █▀▀█ █▀▀█ █▀▀▄", "█__█ █__█ █^^^ █__█", "▀▀▀▀ █▀▀▀ ▀▀▀▀ ▀~~▀"],',
    '  left: ["             ▄     ", "   █▀▀▀ █▀▀█ █ █  █", "   ▀▀▀█ █__█ █ █__█", "   ▀▀▀▀ ▀▀▀▀ ▀ ▀▀▀▀"],')

# 2. «basado en OpenCode», chico y atenuado, debajo del logo.
cambiar("packages/tui/src/component/logo.tsx",
    '''        </For>
      )}
    </box>
  )
}''',
    '''        </For>
      )}
      {dimensions().height < 12 || dimensions().width < 22 ? null : (
        <box flexDirection="row" justifyContent="flex-end">
          <text fg={theme.text.muted} attributes={TextAttributes.DIM} selectable={false}>
            basado en OpenCode
          </text>
        </box>
      )}
    </box>
  )
}''')

# 3. Lo que se imprime al cerrar la TUI.
cambiar("packages/tui/src/util/presentation.ts",
    '    ...wordmark("  "),\n',
    '    ...wordmark("  "),\n    `  ${dim}basado en OpenCode${reset}`,\n')
cambiar("packages/tui/src/util/presentation.ts", "${bold}opencode${reset}", "${bold}solucode${reset}")
cambiar("packages/tui/src/util/presentation.ts", "`opencode -s ${", "`solucode -s ${")

# 4. El título de la ventana de la terminal.
cambiar("packages/tui/src/app.tsx", 'setTerminalTitle(renderer, "OpenCode")', 'setTerminalTitle(renderer, "SOLUCODE")', 2)
cambiar("packages/tui/src/app.tsx", "`OC | ${", "`SOLUCODE | ${", 2)

# 5. El nombre del comando y --version: «solucode v2.4.2 (basado en OpenCode 2.4.2)».
cambiar("packages/cli/script/build.ts", 'OPENCODE_CLI_NAME: "\'opencode\'",', 'OPENCODE_CLI_NAME: "\'solucode\'",')
cambiar("packages/cli/src/commands/commands.ts",
    'description: "OpenCode command line interface",',
    'description: "SOLUCODE, basado en OpenCode",')
cambiar("packages/cli/src/index.ts",
    "return yield* Runtime.run(Commands, Handlers, { version: OPENCODE_VERSION })",
    "return yield* Runtime.run(Commands, Handlers, { version: `${OPENCODE_VERSION} (basado en OpenCode ${OPENCODE_VERSION})` })")

# 6. Nada se actualiza solo ni baja el OpenCode original: se actualiza con el instalador.
cambiar("packages/cli/src/services/updater.ts",
    "  return Service.of({ run, check, apply, method, managed, latest, upgrade, removal })",
    f'''  const servicioOriginal = {{ run, check, apply, method, managed, latest, upgrade, removal }}
  const mensajeSolucode = {MENSAJE!r}
  return Service.of({{
    ...servicioOriginal,
    run: () => Effect.succeed(undefined),
    check: () => Effect.succeed({{ type: "unavailable" as const, message: mensajeSolucode }}),
    apply: () => Effect.fail(new Error(mensajeSolucode)),
    upgrade: () => Effect.fail(new Error(mensajeSolucode)),
  }})''')
cambiar("packages/cli/src/commands/handlers/upgrade.ts",
    '      intro("Upgrade")\n',
    f'      intro("SOLUCODE")\n      log.info({MENSAJE!r})\n      outro("Listo")\n      if (Date.now() > 0) return\n')
print("marca aplicada")
