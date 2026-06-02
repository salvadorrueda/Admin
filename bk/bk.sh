#!/usr/bin/env bash
#
# bk.sh - Còpia de seguretat de fitxers/carpetes cap a /bk/<hostname>
#
# Copia els fitxers i carpetes passats com a paràmetre a /bk/<hostname>,
# replicant la ruta absoluta de l'origen.
#
#   Exemple:  bk test.txt   (des de /home/salvadorrueda)
#   Resultat: /bk/u01/home/salvadorrueda/test.txt   (si hostname és "u01")
#
# Ús: bk [--dry-run] <fitxer|carpeta> [més fitxers/carpetes...]
#   --dry-run, -n   Mostra les comandes que s'executarien, sense fer res.

set -euo pipefail

BK_BASE="/bk/$(hostname)"
DRY_RUN=0

usage() {
  echo "Ús: $(basename "$0") [--dry-run] <fitxer|carpeta> [més...]" >&2
}

# Separa les opcions dels arguments posicionals
args=()
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help)    usage; exit 0 ;;
    *)            args+=("$arg") ;;
  esac
done
set -- ${args[@]+"${args[@]}"}

# Cal almenys un argument
if [ $# -lt 1 ]; then
  usage
  exit 1
fi

# Mostra la comanda i, si no estem en --dry-run, l'executa
run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run]'
  else
    printf '+'
  fi
  printf ' %q' "$@"
  printf '\n'

  [ "$DRY_RUN" -eq 1 ] || "$@"
}

# Determina si cal sudo per crear/escriure a /bk
SUDO=""
if [ ! -d /bk ] || [ ! -w /bk ]; then
  SUDO="sudo"
  echo "Nota: cal sudo per crear/escriure a /bk" >&2
fi

for src in "$@"; do
  if [ ! -e "$src" ]; then
    echo "Avís: '$src' no existeix, s'omet." >&2
    continue
  fi

  abs="$(realpath "$src")"        # ruta absoluta de l'origen
  dest="$BK_BASE$abs"             # p.ex. /bk/u01/home/salvadorrueda/test.txt
  destdir="$(dirname "$dest")"

  if [ -n "$SUDO" ]; then
    run sudo mkdir -p "$destdir"
    run sudo rsync -a "$abs" "$dest"
  else
    run mkdir -p "$destdir"
    run rsync -a "$abs" "$dest"
  fi

  [ "$DRY_RUN" -eq 1 ] || echo "Copiat: $abs -> $dest"
done
