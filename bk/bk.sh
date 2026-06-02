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
# Ús: bk <fitxer|carpeta> [més fitxers/carpetes...]

set -euo pipefail

BK_BASE="/bk/$(hostname)"

# Cal almenys un argument
if [ $# -lt 1 ]; then
  echo "Ús: $(basename "$0") <fitxer|carpeta> [més...]" >&2
  exit 1
fi

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

  $SUDO mkdir -p "$(dirname "$dest")"
  $SUDO rsync -a "$abs" "$dest"
  echo "Copiat: $abs -> $dest"
done
