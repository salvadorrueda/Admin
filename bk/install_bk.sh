#!/usr/bin/env bash
#
# install_bk.sh — instal·lador de `bk`
#
# Què fa:
#   1. Comprova que hi hagi `curl` (per descarregar) i `rsync` (per executar bk).
#   2. Descarrega l'script `bk.sh` del repositori GitHub.
#   3. El deixa executable a ~/.local/bin/bk perquè es pugui invocar com `bk`
#      des de qualsevol terminal.
#
# Ús:
#   bash bk/install_bk.sh
#   curl -fsSL https://raw.githubusercontent.com/salvadorrueda/Admin/main/bk/install_bk.sh | bash
#
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/salvadorrueda/Admin/main"
BK_SRC="$REPO_RAW/bk/bk.sh"
BIN_DIR="$HOME/.local/bin"
DEST="$BIN_DIR/bk"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m  ✓\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$1"; }
die()   { printf '\033[1;31merror:\033[0m %s\n' "$1" >&2; exit 1; }

# --- Requisits bàsics -------------------------------------------------------
command -v curl >/dev/null 2>&1 || die "cal tenir 'curl' instal·lat per continuar."

info "Comprovant 'rsync' (necessari per executar bk)…"
if command -v rsync >/dev/null 2>&1; then
  ok "rsync trobat."
else
  warn "rsync no trobat. Instal·la'l (p.ex. 'sudo apt install rsync') abans d'usar bk."
fi

# --- 1. Assegurar ~/.local/bin ---------------------------------------------
mkdir -p "$BIN_DIR"

# --- 2. Descarregar bk del repo --------------------------------------------
info "Descarregant 'bk' del repositori…"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
if ! curl -fsSL "$BK_SRC" -o "$tmp"; then
  die "no s'ha pogut descarregar $BK_SRC"
fi
chmod 755 "$tmp"
mv "$tmp" "$DEST"
trap - EXIT
ok "instal·lat a $DEST"

# --- 3. Comprovar el PATH ---------------------------------------------------
case ":$PATH:" in
  *":$BIN_DIR:"*)
    ok "$BIN_DIR ja és al PATH."
    ;;
  *)
    warn "$BIN_DIR no és al PATH."
    # Tria el fitxer de perfil segons la shell de l'usuari.
    case "${SHELL:-}" in
      */zsh) profile="$HOME/.zshrc" ;;
      *)     profile="$HOME/.bashrc" ;;
    esac
    line='export PATH="$HOME/.local/bin:$PATH"'
    if [ -f "$profile" ] && grep -qF "$line" "$profile"; then
      warn "ja existeix la línia del PATH a $profile (potser cal reiniciar la terminal)."
    else
      printf '\n# Afegit per install_bk.sh\n%s\n' "$line" >> "$profile"
      ok "afegit el PATH a $profile."
    fi
    warn "Reinicia la terminal o executa:  source \"$profile\""
    ;;
esac

# --- 4. Missatge final ------------------------------------------------------
info "Instal·lació completada."
printf "Ús:  \033[1mbk <fitxer|carpeta> [més...]\033[0m\n"
