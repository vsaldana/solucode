#!/usr/bin/env bash
# Decide qué compila esta corrida y qué publica. Escribe en $GITHUB_OUTPUT:
#   compilar  true o false
#   version   la versión de OpenCode (sin v)
#   tag       el tag del release (vacío si no se publica)
#   publicar  release, prerelease o nada
#   modo      tag, manual o semanal
set -euo pipefail

salida() { echo "$1=$2" >> "$GITHUB_OUTPUT"; echo "$1=$2"; }

case "$GITHUB_EVENT_NAME" in
  push)
    # v2.4.2-solucode.1 -> 2.4.2
    tag="$GITHUB_REF_NAME"
    version="${tag#v}"
    version="${version%%-solucode.*}"
    salida modo tag
    salida compilar true
    salida version "$version"
    salida solucode "${tag#v}"
    salida tag "$tag"
    salida publicar release
    ;;
  workflow_dispatch)
    version="${ENTRADA_VERSION:-}"
    [ -n "$version" ] || version="$(tr -d '[:space:]' < VERSION)"
    salida modo manual
    salida compilar true
    salida version "${version#v}"
    salida solucode "${version#v}-solucode.$(tr -d '[:space:]' < REVISION)"
    salida tag ""
    salida publicar nada
    ;;
  schedule)
    actual="$(tr -d '[:space:]' < VERSION)"
    ultima="$(gh api repos/anomalyco/opencode/releases/latest -q .tag_name)"
    ultima="${ultima#v}"
    salida modo semanal
    salida version "$ultima"
    salida solucode "$ultima-solucode.1"
    if [ "$ultima" = "$actual" ]; then
      echo "OpenCode $ultima es la versión de SOLUCODE: no hay nada nuevo"
      salida compilar false
      exit 0
    fi
    tag="v$ultima-solucode.1"
    if gh release view "$tag" >/dev/null 2>&1; then
      echo "ya existe el prerelease $tag"
      salida compilar false
      exit 0
    fi
    if [ -n "$(gh issue list --state open --search "\"OpenCode $ultima\" in:title" --json number -q '.[].number')" ]; then
      echo "ya hay un issue abierto por OpenCode $ultima"
      salida compilar false
      exit 0
    fi
    salida compilar true
    salida tag "$tag"
    salida publicar prerelease
    ;;
  *)
    echo "evento no esperado: $GITHUB_EVENT_NAME" >&2
    exit 1
    ;;
esac
