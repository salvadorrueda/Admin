#!/usr/bin/env bash
#
# install_claudia.sh — instal·lador de `claudia`
#
# Què fa:
#   1. Comprova si `claude` (Claude Code) està instal·lat i, si no, l'instal·la
#      amb l'instal·lador oficial.
#   2. Descarrega el llançador `claudia` del repositori GitHub.
#   3. El deixa executable a ~/.local/bin/claudia perquè es pugui invocar des de
#      qualsevol terminal.
#
# Ús:
#   bash claudia/install_claudia.sh
#   curl -fsSL https://raw.githubusercontent.com/salvadorrueda/Admin/main/claudia/install_claudia.sh | bash
#
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/salvadorrueda/Admin/main"
CLAUDIA_SRC="$REPO_RAW/claudia/claudia"
BIN_DIR="$HOME/.local/bin"
DEST="$BIN_DIR/claudia"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m  ✓\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$1"; }
die()   { printf '\033[1;31merror:\033[0m %s\n' "$1" >&2; exit 1; }

# --- Requisits bàsics -------------------------------------------------------
command -v curl >/dev/null 2>&1 || die "cal tenir 'curl' instal·lat per continuar."

# --- 1. Comprovar / instal·lar claude ---------------------------------------
info "Comprovant Claude Code (claude)…"
if command -v claude >/dev/null 2>&1; then
  ok "claude ja està instal·lat ($(claude --version 2>/dev/null || echo 'versió desconeguda'))."
else
  warn "claude no trobat. Instal·lant amb l'instal·lador oficial…"
  curl -fsSL https://claude.ai/install.sh | bash

  # Després de la instal·lació pot caldre tenir ~/.local/bin al PATH d'aquesta
  # mateixa sessió per detectar-lo.
  case ":$PATH:" in
    *":$BIN_DIR:"*) : ;;
    *) export PATH="$BIN_DIR:$PATH" ;;
  esac

  if command -v claude >/dev/null 2>&1; then
    ok "claude instal·lat ($(claude --version 2>/dev/null || echo 'versió desconeguda'))."
  else
    die "claude s'ha instal·lat però no es troba al PATH. Reinicia la terminal i torna a executar aquest script."
  fi
fi

# --- 2. Assegurar ~/.local/bin ---------------------------------------------
mkdir -p "$BIN_DIR"

# --- 3. Descarregar claudia del repo ---------------------------------------
info "Descarregant 'claudia' del repositori…"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
if ! curl -fsSL "$CLAUDIA_SRC" -o "$tmp"; then
  die "no s'ha pogut descarregar $CLAUDIA_SRC"
fi
chmod 755 "$tmp"
mv "$tmp" "$DEST"
trap - EXIT
ok "instal·lat a $DEST"

# --- 4. Comprovar el PATH ---------------------------------------------------
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
      printf '\n# Afegit per install_claudia.sh\n%s\n' "$line" >> "$profile"
      ok "afegit el PATH a $profile."
    fi
    warn "Reinicia la terminal o executa:  source \"$profile\""
    ;;
esac

# --- 5. Missatge final ------------------------------------------------------
info "Instal·lació completada."
printf "Ús:  entra en una carpeta del teu projecte i executa  \033[1mclaudia\033[0m\n"
