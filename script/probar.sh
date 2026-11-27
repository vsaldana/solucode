#!/usr/bin/env bash
# Se ejecuta dentro de upstream, después de instalar las dependencias.
set -euo pipefail
(cd packages/client && bun run generate)
(cd packages/core && bun run script/test.ts test/generate.test.ts)
(cd packages/tui && bun test --timeout 30000 --only-failures)
(cd packages/protocol && bun test test/experimental-identifiers.test.ts)
for paquete in core server protocol client tui; do
  (cd "packages/$paquete" && bun run typecheck:tsc)
done
