# kdu9-aider

**Aider — programação em par com IA (Gemini) — empacotado para GNU/Linux KDu9.**

Instala com um clique o [Aider](https://aider.chat) configurado e pronto para usar:
ícones na área de trabalho e no menu, interface no navegador (sem janela de
terminal), suporte a várias sessões independentes ao mesmo tempo e parada
com um clique.

## Recursos

- Instalação e atualização com **um clique duplo** (`instalar.sh`) — sem root;
- Ícone **Aider**: abre a interface no navegador, sem terminal aberto;
- **Várias sessões independentes** (até 8), cada uma com sua pasta de projeto;
- Menu de sessões: reabrir a aba de uma sessão viva ou criar nova;
- Ícone **Aider — Parar servidor**: encerra todas as sessões;
- No primeiro uso, **pede a chave do Gemini** numa janela e guarda com
  permissão restrita (`~/.env`, modo 600);
- Pasta que não é repositório git? O instalador de sessão inicializa o git
  e prepara os arquivos automaticamente para o aider enxergá-los;
- Reinstalar/atualizar é seguro: **nunca sobrescreve** `~/.env` nem
  `~/.aider.conf.yml`.

## Requisitos

- GNU/Linux com KDE (testado no KDu9 / Plasma);
- `python3` 3.10+ com `python3-venv`, `git`, `curl`, `kdialog`, `xdg-open`
  (no KDu9/Debian/Ubuntu: `sudo apt install python3-venv git curl kdialog xdg-utils`);
- Internet na primeira instalação (baixa o aider-chat do PyPI);
- Chave grátis da API do Gemini: <https://aistudio.google.com/apikey>.

## Instalação

Filosofia KDu9: **1 clique sempre** (minimizando L.E.R.).

### Jeito fácil — 1 clique (interface)

1. Extraia o pacote (`kdu9-aider-<versão>.zip` ou `.tar.gz`);
2. Clique **1 vez em `Instalar-Aider.desktop`** — na primeira vez o KDE
   pede para *Confiar* (padrão de segurança); confirme e pronto;
3. O terminal abre mostrando o progresso e fica no final com o resumo;
   os ícones aparecem na área de trabalho e no menu.

Para remover depois: `Desinstalar-Aider.desktop` (também 1 clique).

### Pelo terminal

```bash
cd kdu9-aider
bash install.sh
```

## Instalação compartilhada do sistema (padrão KDu9: /opt/pipx)

O ambiente Python do aider ocupa perto de **1 GB**. Para não inflar o
`/etc/skel` (e a ISO) do KDu9, o padrão do laboratório é instalá-lo
**fora do home**, em `/opt/pipx`, compartilhado por todos os usuários —
foi uma das mudanças que baixaram a distro de 6.4 GB para 5.4 GB.

O instalador entende esse padrão automaticamente:

- **Já existe `/opt/pipx` com aider?** → reusa, sem baixar nada, e nenhum
  usuário ganha ~1 GB no home;
- **Rodando como root** (build da distro/skel) → instala direto em
  `/opt/pipx`;
- **Usuário comum sem `/opt/pipx`** → instala em `~/.aider-env` (funciona
  sem root em qualquer distro).

Personalização:

```bash
KDU9_AIDER_SHARED_ROOT=/opt/pipx   # raiz compartilhada (padrão /opt/pipx)
KDU9_AIDER_VENV=...                # força o caminho do ambiente virtual
KDU9_AIDER_BIN=...                 # força o binário do aider
```

A desinstalação nunca remove o ambiente compartilhado (ele pode servir a
outros usuários) — para isso: `sudo rm -rf /opt/pipx`.

## Primeiro uso

1. Clique no ícone **Aider**;
2. Na primeira vez, ele pede a chave do Gemini (cole e confirme);
3. Escolha a pasta do projeto e converse! A interface abre no navegador.

Para trocar o modelo padrão, edite `~/.aider.conf.yml` (ex.:
`model: gemini/gemini-3.6-pro`).

## Desinstalação

```bash
bash uninstall.sh          # mantém ~/.env e ~/.aider.conf.yml
bash uninstall.sh --tudo   # remove tudo, inclusive chave e configs
```

## Estrutura do pacote

```
kdu9-aider/
├── Instalar-Aider.desktop  # instalação com 1 clique (filosofia KDu9)
├── Desinstalar-Aider.desktop
├── install.sh              # instalador/atualizador (terminal)
├── instalar.sh             # wrapper de instalação (abre Konsole)
├── uninstall.sh            # desinstalador
├── VERSION                 # versão do pacote
├── src/
│   ├── aider-gui           # lançador das sessões (sem terminal)
│   ├── aider-stop          # encerra todas as sessões
│   ├── aider.desktop.in    # modelo do lançador (menu/área de trabalho)
│   ├── aider-stop.desktop.in
│   ├── aider.conf.yml      # config padrão do aider
│   ├── env.template        # modelo de ~/.env (chaves)
│   └── aider.png           # ícone (logo oficial do projeto aider)
└── dist/                   # pacotes prontos para publicar (.zip/.tar.gz)
```

## Versões

| Versão | Data       | Novidades |
|--------|------------|-----------|
| 1.0.0  | 2026-08-20 | Versão inicial: instalação por clique, sessões múltiplas, pedido de chave no 1º uso. |

## Downloads

- GitHub: (preencher após publicar)
- SourceForge: (preencher após publicar)

## Créditos e licenças

- Este empacotamento (scripts de instalação/lançadores): licença MIT
  (arquivo `LICENSE`);
- [Aider](https://aider.chat) e seu ícone: projeto Aider, licença
  Apache 2.0 — sem alterações no programa, apenas empacotamento;
- KDu9: distribuição GNU/Linux mantida por KDu9.
