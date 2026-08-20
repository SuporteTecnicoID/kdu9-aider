#!/usr/bin/env bash
# kdu9-aider — desinstalador
# Uso: bash uninstall.sh [-y] [--tudo]
#   -y       não pede confirmação
#   --tudo   remove também ~/.env e ~/.aider.conf.yml (chave e configs)
set -u

VENV_DIR="${KDU9_AIDER_VENV:-$HOME/.aider-env}"
ASSUME_YES=0
REMOVE_ALL=0
for arg in "$@"; do
    case "$arg" in
        -y) ASSUME_YES=1 ;;
        --tudo) REMOVE_ALL=1 ;;
    esac
done

say() { printf '%s\n' "$*"; }

say ""
say "kdu9-aider — desinstalação"
say ""

if [ "$ASSUME_YES" -eq 0 ]; then
    read -r -p "Remover o Aider e todos os arquivos do kdu9-aider? (s/N) " resp
    case "$resp" in
        s|S|sim|SIM) ;;
        *) say "Cancelado."; exit 0 ;;
    esac
fi

# encerra sessões em execução
pkill -f "bin/aider --browser" >/dev/null 2>&1
sleep 1

# segurança: só remove o venv se estiver dentro de $HOME
# (instalação compartilhada do sistema, ex.: /opt/pipx, fica — pode servir
#  a outros usuários; para remover: sudo rm -rf /opt/pipx)
case "$VENV_DIR" in
    "$HOME"/*) rm -rf "$VENV_DIR" ;;
    *) say "AVISO: ambiente compartilhado em $VENV_DIR mantido (remove com: sudo rm -rf $VENV_DIR)." ;;
esac

rm -f "$HOME/.local/bin/aider" \
      "$HOME/.local/bin/aider-gui" \
      "$HOME/.local/bin/aider-stop" \
      "$HOME/.local/share/icons/aider.png" \
      "$HOME/.local/share/applications/aider.desktop" \
      "$HOME/.local/share/applications/aider-stop.desktop" \
      "$HOME/Desktop/aider.desktop" \
      "$HOME/Desktop/aider-stop.desktop"
rm -rf "$HOME/.cache/aider-sessions"

if [ "$REMOVE_ALL" -eq 1 ]; then
    rm -f "$HOME/.aider.conf.yml" "$HOME/.env"
    say "Configurações e ~/.env removidos."
else
    say "Mantidos: ~/.aider.conf.yml e ~/.env (use --tudo para remover)."
fi

update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
kbuildsycoca6 >/dev/null 2>&1 || kbuildsycoca5 >/dev/null 2>&1 || true

say ""
say "kdu9-aider removido. Até logo!"
say ""
