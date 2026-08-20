#!/usr/bin/env bash
# =============================================================
#  kdu9-aider — instalador
#  Aider (IA de programação em par) empacotado para GNU/Linux KDu9
#  Funciona em qualquer distro GNU/Linux com KDE e Python 3.10+
#
#  Uso:  bash install.sh          (instala ou atualiza)
#        bash uninstall.sh        (remove)
#  Reexecutar é seguro: atualiza arquivos sem tocar nas configs.
# =============================================================
set -u

PKG_NAME="kdu9-aider"
VERSION="$(cat "$(cd "$(dirname "$0")" && pwd)/VERSION" 2>/dev/null || echo 1.0.0)"
SRC="$(cd "$(dirname "$0")" && pwd)/src"
VENV_DIR="${KDU9_AIDER_VENV:-$HOME/.aider-env}"
LOG_DIR="$HOME/.cache"
LOG="$LOG_DIR/kdu9-aider-install.log"

say()  { printf '%b\n' "$*"; }
err()  { printf '\033[31mERRO:\033[0m %s\n' "$*" >&2; }
ok()   { printf ' \033[32m[ok]\033[0m %s\n' "$*"; }
warn() { printf ' \033[33m[aviso]\033[0m %s\n' "$*"; }

banner() {
    say ""
    say "==================================================="
    say " $PKG_NAME $VERSION — Aider para GNU/Linux KDu9"
    say "==================================================="
    say ""
}

# ---------- dependências ----------
check_deps() {
    local missing=0

    for cmd in python3 git curl kdialog xdg-open; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            err "Comando '$cmd' não encontrado. Instale-o antes (ex.: sudo apt install $cmd)."
            missing=1
        fi
    done

    if [ "$missing" -eq 1 ]; then exit 1; fi

    if ! python3 -c "import venv" >/dev/null 2>&1; then
        err "O módulo python3-venv está faltando. Instale com: sudo apt install python3-venv"
        exit 1
    fi

    ok "Dependências encontradas (python3, git, curl, kdialog, xdg-open)."
}

# ---------- ambiente virtual + aider ----------
# Raiz compartilhada do sistema (padrão KDu9: /opt/pipx, fora do home para
# não inflar o /etc/skel da distro — no laboratório baixou a ISO de 6.4 GB
# para 5.4 GB). Reusada automaticamente quando já existe; root instala lá.
SHARED_ROOT="${KDU9_AIDER_SHARED_ROOT:-/opt/pipx}"
AIDER_BIN=""

shared_aider_bin() {
    local c
    for c in "$SHARED_ROOT/bin/aider" "$SHARED_ROOT"/venvs/*/bin/aider; do
        if [ -x "$c" ]; then echo "$c"; return 0; fi
    done
    return 1
}

install_venv() {
    local sudo_cmd=""

    # 1) instalação compartilhada do sistema já existe → reusa (economiza ~1 GB por usuário)
    if [ -z "${KDU9_AIDER_VENV:-}" ] && AIDER_BIN="$(shared_aider_bin)"; then
        ok "Reusando instalação compartilhada do sistema: $AIDER_BIN"
        return 0
    fi

    # 2) destino do ambiente: explícito > root (build da distro/skel) > usuário
    if [ -z "${KDU9_AIDER_VENV:-}" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            VENV_DIR="$SHARED_ROOT"
            say "  Modo root: instalando compartilhado em $VENV_DIR (padrão KDu9, fora do skel)."
        else
            VENV_DIR="$HOME/.aider-env"
        fi
    fi

    if [ -x "$VENV_DIR/bin/aider" ] && "$VENV_DIR/bin/aider" --version >/dev/null 2>&1; then
        AIDER_BIN="$VENV_DIR/bin/aider"
        ok "Aider já instalado no ambiente virtual ($VENV_DIR) — reaproveitando."
        return 0
    fi

    if [ "${KDU9_AIDER_SKIP_VENV:-0}" = "1" ]; then
        warn "KDU9_AIDER_SKIP_VENV=1 e aider ausente — pulando criação do ambiente (modo teste)."
        return 0
    fi

    # destino fora do home exige privilégio (compartilhado entre usuários)
    case "$VENV_DIR" in
        "$HOME"/*) ;;
        *)
            if [ "$(id -u)" -ne 0 ]; then
                if command -v sudo >/dev/null 2>&1; then
                    sudo_cmd="sudo"
                else
                    err "Instalar em $VENV_DIR precisa de root. Rode com sudo, ou use KDU9_AIDER_VENV=~/.aider-env."
                    exit 1
                fi
            fi
            ;;
    esac

    say "  Criando ambiente virtual Python em $VENV_DIR ..."
    $sudo_cmd rm -rf "$VENV_DIR"
    $sudo_cmd python3 -m venv "$VENV_DIR" >>"$LOG" 2>&1 || { err "Falha ao criar o ambiente virtual (veja $LOG)"; exit 1; }

    say "  Baixando e instalando o aider-chat (pode demorar alguns minutos)..."
    $sudo_cmd "$VENV_DIR/bin/pip" install --upgrade pip >>"$LOG" 2>&1
    $sudo_cmd "$VENV_DIR/bin/pip" install --upgrade 'aider-chat[browser]' >>"$LOG" 2>&1 \
        || { err "Falha ao instalar o aider (veja $LOG). Verifique sua conexão com a internet."; exit 1; }

    AIDER_BIN="$VENV_DIR/bin/aider"
    ok "Aider $("$AIDER_BIN" --version 2>/dev/null || echo '') instalado em $VENV_DIR."
}

# ---------- arquivos do usuário ----------
install_files() {
    local bin_dir="$HOME/.local/bin"
    local apps_dir="$HOME/.local/share/applications"
    local icon_dir="$HOME/.local/share/icons"
    local desktop_dir
    desktop_dir="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
    [ -d "$desktop_dir" ] || desktop_dir="$HOME/Desktop"
    [ -d "$desktop_dir" ] || desktop_dir=""

    mkdir -p "$bin_dir" "$apps_dir" "$icon_dir" "$HOME/.cache/aider-sessions"

    install -m 755 "$SRC/aider-gui"  "$bin_dir/aider-gui"
    install -m 755 "$SRC/aider-stop" "$bin_dir/aider-stop"
    install -m 644 "$SRC/aider.png"  "$icon_dir/aider.png"
    ln -sf "${AIDER_BIN:-$VENV_DIR/bin/aider}" "$bin_dir/aider"
    ok "Scripts e ícone instalados em ~/.local"

    # lançadores do menu (com o caminho real do usuário no lugar de @HOME@)
    local f
    for f in aider aider-stop; do
        sed "s|@HOME@|$HOME|g" "$SRC/$f.desktop.in" > "$apps_dir/$f.desktop"
        chmod +x "$apps_dir/$f.desktop"
    done
    ok "Lançadores criados no menu de aplicativos."

    # atalhos na área de trabalho
    if [ -n "$desktop_dir" ]; then
        for f in aider aider-stop; do
            cp "$apps_dir/$f.desktop" "$desktop_dir/$f.desktop"
            chmod +x "$desktop_dir/$f.desktop"
        done
        ok "Atalhos criados na área de trabalho."
    else
        warn "Pasta da área de trabalho não encontrada — atalhos apenas no menu."
    fi

    # configurações pessoais: NUNCA sobrescrever existentes
    if [ ! -f "$HOME/.aider.conf.yml" ]; then
        install -m 644 "$SRC/aider.conf.yml" "$HOME/.aider.conf.yml"
        ok "Configuração padrão criada (~/.aider.conf.yml)."
    else
        warn "~/.aider.conf.yml já existe — mantido o seu."
    fi
    if [ ! -f "$HOME/.env" ]; then
        install -m 600 "$SRC/env.template" "$HOME/.env"
        ok "Arquivo de chaves criado (~/.env)."
    else
        warn "~/.env já existe — mantido o seu (chaves preservadas)."
    fi

    # caches do menu
    update-desktop-database "$apps_dir" >/dev/null 2>&1 || true
    kbuildsycoca6 >/dev/null 2>&1 || kbuildsycoca5 >/dev/null 2>&1 || true
}

summary() {
    local v="$("${AIDER_BIN:-$VENV_DIR/bin/aider}" --version 2>/dev/null || echo 'aider')"
    say ""
    say "==================================================="
    say " Instalação concluída! ($v)"
    say "==================================================="
    say ""
    say " Como usar:"
    say "   1. Clique no ícone \033[1mAider\033[0m (área de trabalho ou menu)."
    say "   2. No primeiro uso ele pede a chave do Gemini"
    say "      (grátis em aistudio.google.com/apikey)."
    say "   3. Escolha a pasta do projeto e bons códigos!"
    say ""
    say " Ícone \033[1mAider — Parar servidor\033[0m encerra todas as sessões."
    say " Várias sessões independentes: clique de novo no ícone Aider."
    say ""
    say " Log da instalação: $LOG"
    say ""
}

banner
check_deps
install_venv
install_files
summary
