#!/usr/bin/env bash
# Trae OpenCode en la versión pedida y le aplica la marca SOLUCODE.
# Uso: script/aplicar.sh <versión de OpenCode, sin v> <carpeta de destino>
#
# Primero prueba parches/solucode.patch, que es el cambio revisado. Si no
# aplica (OpenCode movió esas líneas), prueba parches/marca.py, que busca los
# mismos textos por contenido. Si tampoco, falla: hay que revisar a mano.
set -euo pipefail

version="${1:?falta la versión de OpenCode}"
destino="${2:?falta la carpeta de destino}"
raiz="$(cd "$(dirname "$0")/.." && pwd)"

if [ -e "$destino" ]; then
  echo "El destino ya existe: $destino. Usa una carpeta nueva para no borrar trabajo." >&2
  exit 1
fi
git clone -q --depth 1 --branch "v$version" https://github.com/anomalyco/opencode.git "$destino"
cd "$destino"

if git apply --check "$raiz/parches/solucode.patch" 2>/dev/null; then
  git apply "$raiz/parches/solucode.patch"
  echo "marca aplicada con parches/solucode.patch"
else
  echo "parches/solucode.patch no aplica sobre OpenCode $version; pruebo parches/marca.py"
  python3 "$raiz/parches/marca.py" .
fi
git apply --check "$raiz/parches/sugerencias.patch"
git apply "$raiz/parches/sugerencias.patch"
echo "sugerencias aplicadas con parches/sugerencias.patch"
git apply --check "$raiz/parches/autoactualizacion.patch"
git apply "$raiz/parches/autoactualizacion.patch"
echo "autoactualización aplicada con parches/autoactualizacion.patch"
git apply --check "$raiz/parches/sigma.patch"
git apply "$raiz/parches/sigma.patch"
echo "sigma aplicado con parches/sigma.patch"
git apply --check "$raiz/parches/actividad.patch"
git apply "$raiz/parches/actividad.patch"
echo "actividad visible aplicada con parches/actividad.patch"
git --no-pager diff --stat
