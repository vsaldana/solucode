# SOLUCODE

SOLUCODE es OpenCode (licencia MIT, [anomalyco/opencode](https://github.com/anomalyco/opencode)) con la marca de Solutoria.

Conserva la configuración (`%ProgramData%\opencode`, `~/.config/opencode`) y las variables `OPENCODE_*`. Los cambios están en `parches/`:

- el logo lleva un sigma blanco sobre un círculo turquesa antes de SOLUCODE, con «basado en OpenCode» debajo; se adapta al ancho de la terminal y también aparece al cerrar;
- el comando es `solucode`, y `solucode --version` dice `solucode v2.4.2-solucode.4 (basado en OpenCode 2.4.2)`;
- el título de la ventana dice SOLUCODE;
- mientras la terminal está abierta, descarga en segundo plano las versiones nuevas aprobadas por el router; quedan instaladas para la próxima apertura. `solucode upgrade` permite comprobar e instalar manualmente esa misma versión aprobada.
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
- `REVISION` es la revisión SOLUCODE para compilaciones manuales; los releases usan el tag completo, también dentro del ejecutable y del servicio.
- `script/aplicar.sh <versión> <carpeta>` trae OpenCode en esa versión y le aplica `parches/solucode.patch`. Si el parche ya no calza, prueba `parches/marca.py`, que hace los mismos cambios buscando los textos.
- Después aplica obligatoriamente `parches/sugerencias.patch`; si no calza, falla y hay que adaptarlo. Usa una carpeta nueva: el guion no borra destinos existentes.
- Aplica también `parches/autoactualizacion.patch`, con el cliente de actualizaciones y sus pruebas de Windows.
- Finalmente aplica `parches/sigma.patch`, con el emblema de marca para la terminal. Su paleta fija pertenece al dibujo; el nombre y la leyenda conservan los colores del tema.
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

## Actualización aprobada por el router

El cliente instalado en `%LOCALAPPDATA%\solucode\solucode.exe` consulta al abrir la TUI y cada diez minutos
`https://router.conversus.digital/solucode/actualizacion.json`. Solo acepta `{version, url, sha256}` para
un ZIP del release exacto de `vsaldana/solucode`, con una versión completa mayor que la instalada.
Comprueba el SHA256, los tres archivos esperados, su integridad y la versión interna del ejecutable.
Nunca ejecuta el instalador ni descarga una actualización de OpenCode original.

El reemplazo conserva la imagen de los procesos abiertos; si Windows exige renombrarla antes de promover
el candidato, restaura la anterior si la promoción falla.
La sesión actual continúa. Al reabrir se renueva el servicio solamente si no hay otros clientes, sesiones
ni trabajos en curso. Si hay actividad o no se puede comprobar su estado, se conserva el servicio anterior
y se avisa. Los errores de red, descarga o permisos dejan la versión anterior disponible y se reintentan.
El cierre de la TUI cancela una descarga en curso; la próxima apertura vuelve a comprobarla.

La política `update` de `%ProgramData%\opencode\opencode.jsonc` prevalece sobre la del usuario;
`auto`, `notify` y `disable` se respetan, al igual que `OPENCODE_DISABLE_AUTOUPDATE`.
Para pasar desde `.2` o anteriores hay que ejecutar el instalador de producción una vez, porque esas
versiones deshabilitaban la autoactualización. El router publica una versión solamente después de aprobar
su release y hash. Las respuestas antiguas del manifiesto nunca provocan un downgrade.
