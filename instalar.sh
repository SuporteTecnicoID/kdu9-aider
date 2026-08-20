#!/usr/bin/env bash
# kdu9-aider — instalação com um clique (duplo clique em "instalar.sh"
# e escolha "Executar" no Dolphin; abre terminal que mantém o resumo no fim).
cd "$(dirname "$0")" || exit 1
if command -v konsole >/dev/null 2>&1; then
    exec konsole --hold -e bash install.sh
fi
exec bash install.sh
