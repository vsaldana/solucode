# SOLUCODE

SOLUCODE es OpenCode (licencia MIT, [anomalyco/opencode](https://github.com/anomalyco/opencode)) con la marca de Solutoria.

Conserva la configuración (`%ProgramData%\opencode`, `~/.config/opencode`) y las variables `OPENCODE_*`. Los cambios están en `parches/`:

- el logo dice SOLUCODE, con «basado en OpenCode» debajo;
- el comando es `solucode`, y `solucode --version` dice `solucode v2.4.2 (basado en OpenCode 2.4.2)`;
- el título de la ventana dice SOLUCODE;
- no se actualiza solo ni baja OpenCode: `solucode upgrade` explica que se actualiza volviendo a correr el instalador.
- al terminar una respuesta, puede sugerir el próximo mensaje; Tab o flecha derecha lo copia al editor, donde se puede modificar antes de enviarlo con Enter. Escribir descarta la sugerencia.
- los modelos del router no ofrecen selector ni comandos de esfuerzo; ese ajuste se administra en `router.conversus.digital`.

## Sugerencias de próximo mensaje

Se activan por omisión y se pueden desactivar en `/experiments`, «Sugerir próximo mensaje»,
o en la configuración de la terminal con `experimental.solucode-suggestions: false`.
Solo aparecen con el editor vacío después de una ejecución exitosa observada en esa terminal.
No se generan al abrir el historial, después de errores ni mientras hay un borrador.

Cada sugerencia hace una llamada breve adicional al modelo que respondió, sin herramientas.
Envía solo texto del último intercambio, acotado a 3.000 caracteres de entrada y 5.000 de respuesta,
y solicita hasta 128 tokens de salida. Puede decidir que no hay nada que sugerir.
El consumo se registra en el router; el contador de la conversación de OpenCode no suma estas
generaciones auxiliares. La solicitud incluye la sesión y `x-solucode-purpose: prompt-suggestion`,
además de una instrucción de sistema que identifica la llamada automática. No agrega mensajes al historial.

## Instalar

En PowerShell, con la llave que entrega el router:

```powershell
irm https://router.conversus.digital/instalar.ps1 | iex
```

## Cómo se arma

- `VERSION` es la versión de OpenCode de la que parte SOLUCODE.
- `script/aplicar.sh <versión> <carpeta>` trae OpenCode en esa versión y le aplica `parches/solucode.patch`. Si el parche ya no calza, prueba `parches/marca.py`, que hace los mismos cambios buscando los textos.
- Después aplica obligatoriamente `parches/sugerencias.patch`; si no calza, falla y hay que adaptarlo. Usa una carpeta nueva: el guion no borra destinos existentes.
- `script/probar.sh`, desde el clon con sus dependencias, regenera el cliente y prueba lógica, terminal, generación y tipos. `verificar.yml` lo hace en Linux y Windows; Linux ejecuta también `bun run check`.
- `.github/workflows/compilar.yml` compila igual que el `build-cli` de OpenCode:
  - con un tag `v<versión>-solucode.<n>` publica el release con `solucode-windows-x64.zip`;
  - cada lunes revisa si hay una versión nueva de OpenCode y publica un prerelease, o abre un issue si no compila.

## Pasar a una versión nueva de OpenCode

1. Revisa el prerelease automático, o el issue si no compiló.
2. Si hace falta, ajusta `parches/marca.py`. En un clon nuevo de OpenCode aplica solo `marca.py` para regenerar `parches/solucode.patch`; después adapta `parches/sugerencias.patch` por separado, sin duplicar los cambios de marca. Regenera el cliente y ejecuta `verificar.yml` antes de publicar.
3. Sube `VERSION`, haz commit y crea el tag `v<nueva>-solucode.1`.
4. En conversusgo, cambia la versión fija del instalador del router (`apps/router`).

El exe no está firmado con Authenticode: el de OpenCode lo firma OpenCode, y esta compilación no tiene su certificado.
