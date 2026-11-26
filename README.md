# SOLUCODE

SOLUCODE es OpenCode (licencia MIT, [anomalyco/opencode](https://github.com/anomalyco/opencode)) con la marca de Solutoria.

Por dentro es el mismo programa: la misma configuración (`%ProgramData%\opencode`, `~/.config/opencode`), las mismas variables `OPENCODE_*` y el mismo esquema. Lo único que cambia está en `parches/`:

- el logo dice SOLUCODE, con «basado en OpenCode» debajo;
- el comando es `solucode`, y `solucode --version` dice `solucode v2.4.2 (basado en OpenCode 2.4.2)`;
- el título de la ventana dice SOLUCODE;
- no se actualiza solo ni baja OpenCode: `solucode upgrade` explica que se actualiza volviendo a correr el instalador.

## Instalar

En PowerShell, con la llave que entrega el router:

```powershell
irm https://router.conversus.digital/instalar.ps1 | iex
```

## Cómo se arma

- `VERSION` es la versión de OpenCode de la que parte SOLUCODE.
- `script/aplicar.sh <versión> <carpeta>` trae OpenCode en esa versión y le aplica `parches/solucode.patch`. Si el parche ya no calza, prueba `parches/marca.py`, que hace los mismos cambios buscando los textos.
- `.github/workflows/compilar.yml` compila igual que el `build-cli` de OpenCode:
  - con un tag `v<versión>-solucode.<n>` publica el release con `solucode-windows-x64.zip`;
  - cada lunes revisa si hay una versión nueva de OpenCode y publica un prerelease, o abre un issue si no compila.

## Pasar a una versión nueva de OpenCode

1. Revisa el prerelease automático, o el issue si no compiló.
2. Si hace falta, ajusta `parches/marca.py`, corre `script/aplicar.sh <nueva> upstream` y regenera el parche con `git -C upstream diff > parches/solucode.patch`.
3. Sube `VERSION`, haz commit y crea el tag `v<nueva>-solucode.1`.
4. En conversusgo, cambia la versión fija del instalador del router (`apps/router`).

El exe no está firmado con Authenticode: el de OpenCode lo firma OpenCode, y esta compilación no tiene su certificado.
