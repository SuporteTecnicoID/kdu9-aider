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
- Menu de sessões: reabrir, criar nova ou **encerrar só as que você escolher**;
- Ícone **Aider — Parar servidor**: encerra todas as sessões;
- Abre o navegador em **janela privativa** — sem histórico, sem abas mortas de
  sessões antigas e sem cache velho do Streamlit após atualizações;
- Chave do Gemini **por projeto** (`.aider.key` na pasta do projeto, modo 600 e
  fora do git) — cada projeto pode usar uma chave diferente para dividir o
  limite da conta grátis;
- Sessão não subiu? O aviso mostra a **causa real** (lida do log da tentativa)
  e o que fazer — não culpa a chave à toa;
- Pasta que não é repositório git? O instalador de sessão inicializa o git
  e prepara os arquivos automaticamente para o aider enxergá-los;
- Reinstalar/atualizar é seguro: **nunca sobrescreve** `~/.env` nem
  `~/.aider.conf.yml`.

## Requisitos

- GNU/Linux com KDE (testado no KDu9 / Plasma);
- `python3` 3.10+ com `python3-venv`, `git`, `curl`, `kdialog`, `yad`, `xdg-open`
  (no KDu9/Debian/Ubuntu: `sudo apt install python3-venv git curl kdialog yad xdg-utils`);
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
  `/opt/pipx/venvs/aider-chat` (mesmo layout do pipx) e cria o link
  `/usr/local/bin/aider`;
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

## Modo --skel (build da distro no laboratório)

Formaliza o fluxo usado no laboratório KDu9: excluir os arquivos do aider
do sync do `/etc/skel` e dar **acesso global** — foi o que, junto com
outras mudanças, baixou a ISO de 6.4 GB para 5.4 GB. Durante o build da
distro (como root):

```bash
bash install.sh --skel /etc/skel
```

Layout resultante:

| Caminho | O quê |
|---|---|
| `/opt/pipx/venvs/aider-chat` | ambiente do aider (~1 GB, global, fora do skel) |
| `/usr/local/bin/aider` (link), `aider-gui`, `aider-stop` | lançadores (valem para todos) |
| `/usr/share/pixmaps/aider.png` | ícone global |
| `/usr/share/applications/aider*.desktop` | menu para todos os usuários |
| `/etc/skel/Desktop/aider*.desktop` | atalhos prontos para novos usuários |
| `/etc/skel/.aider.conf.yml`, `.env` | configs iniciais dos novos usuários |

Os lançadores usam caminhos fixos (idênticos para qualquer usuário — sem
substituição de home). Novo usuário faz login e os ícones já estão lá; no
primeiro clique o Aider pede a chave do Gemini. Nada dos ~1 GB entra no
home de ninguém.

Destinos personalizáveis para testes: `KDU9_GLOBAL_BIN`,
`KDU9_GLOBAL_APPS`, `KDU9_GLOBAL_PIXMAPS` (padrões `/usr/local/bin`,
`/usr/share/applications`, `/usr/share/pixmaps`).

## Primeiro uso

1. Clique no ícone **Aider**;
2. Na primeira vez de cada projeto, ele pede a chave do Gemini (cole e
   confirme);
3. Escolha a pasta do projeto e converse! A interface abre no navegador.

O lançador usa `gemini/gemini-3.7-flash` com `--map-tokens 1024` — mapa do
repositório enxuto, economiza a cota da conta grátis. Para trocar, edite a
linha do `--model` em `src/aider-gui` e reinstale.

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
| 1.2.1  | 2026-08-21 | Correção da janela privativa: detecção via `xdg-mime` (o `xdg-settings` não funciona em todos os KDEs) com comparação em minúsculas. |
| 1.2.0  | 2026-08-21 | Modo navegador garantido também em instalações reusadas (`ensure_browser`); layout pipx `/opt/pipx/venvs/aider-chat` + link `/usr/local/bin/aider`; janela privativa do navegador; encerramento seletivo de sessões no menu; diagnóstico real de falhas (lê o log e diz o que fazer); cache do pip limpo após instalar. |
| 1.1.0  | 2026-08-20 | Modo `--skel` para builds da distro (global em /opt/pipx + lançadores de caminho fixo + esqueleto pronto). |
| 1.0.0  | 2026-08-20 | Versão inicial: instalação por clique, sessões múltiplas, pedido de chave no 1º uso. |

## Downloads

- GitHub: (preencher após publicar)
- SourceForge: (preencher após publicar)

## ☕ Apoie o projeto

O **Projeto Linux KDu (KDu9)** é desenvolvido e mantido pelo
**Lab's & Tecnologia I.A.** — software livre e gratuito, feito de madrugada,
para o mundo. Se ele ajudar você, pode retribuir:

- **Pix (Brasil)** — escaneie o QR code abaixo (chave aleatória/EVP,
  a chave pessoal fica protegida):

  ![QR Code Pix — Projeto Linux KDu](docs/apoie-pix-qrcode.jpg)

- **Ko-fi / PayPal** (internacional): *(inserir link)*
- **GitHub Sponsors**: *(inserir link)*

### Support the project

KDu9 is free and open source software, maintained by **Lab's & Tecnologia
I.A.** If it helps you, consider supporting via Pix (QR code above), Ko-fi or
GitHub Sponsors.

## Créditos e licenças

- Este empacotamento (scripts de instalação/lançadores): licença MIT
  (arquivo `LICENSE`);
- [Aider](https://aider.chat) e seu ícone: projeto Aider, licença
  Apache 2.0 — sem alterações no programa, apenas empacotamento;
- KDu9: distribuição GNU/Linux mantida por KDu9.
