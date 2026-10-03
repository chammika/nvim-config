# nvim-config

A single-file Neovim configuration built on Neovim's own built-ins — `vim.pack`
for plugins, `vim.lsp.config`/`vim.lsp.enable` for language servers, and
treesitter for highlighting and folds. No plugin manager, no module tree: the
whole config is one `init.lua` that reads top-to-bottom in load order.

Requires **Neovim 0.11+** (developed on 0.12).

## Layout

`init.lua` is ordered so that dependencies always precede their consumers:

| Section | Why it sits there |
|---|---|
| `OPTIONS` | `termguicolors` and `background` must precede the colorscheme |
| `PLUGINS` | `vim.pack.add` is synchronous; nothing below can `require` a plugin until it runs |
| colorscheme | catppuccin `setup()` → `colorscheme` |
| `KEYMAPS` | `mapleader` is set first — leader is resolved at definition time |
| `AUTOCMDS` | defines the shared `augroup` and the format-on-save allowlist |
| `PLUGIN CONFIGS` | mini.icons registers its devicons shim before nvim-tree/lualine |
| `LSP` | blink.cmp first, since servers pull capabilities from it |
| `TRANSPARENCY` | runs last so it wins over per-plugin highlight tweaks |
| `FLOATING TERMINAL` | no dependencies |

## Plugins

Installed with `vim.pack.add`. Update with `:lua vim.pack.update()`.

| Plugin | Role |
|---|---|
| [catppuccin](https://github.com/catppuccin/nvim) | colorscheme (mocha), `flavour = "auto"` follows `background` |
| [mini.nvim](https://github.com/echasnovski/mini.nvim) | ai, clue, comment, diff, git, surround, pairs, move, sessions, icons, notify, bufremove, indentscope, cursorword, trailspace |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | statusline, `catppuccin-nvim` theme |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua) | files, grep, buffers, LSP pickers |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | file explorer |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (`main`) | parsers, highlighting, folds |
| [nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring) | correct comments in embedded languages |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | server definitions |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | installs servers, linters, formatters |
| [efmls-configs-nvim](https://github.com/creativenull/efmls-configs-nvim) | linter/formatter configs for efm |
| [blink.cmp](https://github.com/saghen/blink.cmp) (pinned `1.*`) | completion, snippets, signature help |
| [rustaceanvim](https://github.com/mrcjkb/rustaceanvim) | Rust tooling on top of rust-analyzer |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | unified window/pane movement |

`mini.clue` shows every mapping as you type a prefix, so the keymaps below are
discoverable in-editor — press `<leader>`, `g`, `[`, `]`, or `<C-w>`.

## Keymaps

Leader is `<Space>`. Prefix groups: `b` buffers, `c` code, `f` find, `g` go-to,
`h` git hunks, `R` Rust, `u` UI toggles.

### Movement & editing

| Key | Action |
|---|---|
| `j` / `k` | wrap-aware down/up |
| `n` / `N`, `<C-d>` / `<C-u>` | centered search results / half-page scroll |
| `<A-j>` / `<A-k>` | move line or selection down/up |
| `<` / `>` | indent and reselect |
| `J` | join lines, keep cursor position |
| `<leader>/` | clear search highlights |
| `<leader>p` / `<leader>x` | paste / delete without yanking |
| `<LeftRelease>` | mouse selection copies to system clipboard |
| `<leader>pa` | copy full file path |

### Windows, buffers, terminal

| Key | Action |
|---|---|
| `<C-h/j/k/l>` | move between nvim splits *and* tmux panes |
| `<leader>¥` / `<leader>-` | split vertical / horizontal (mirrors tmux) |
| `<C-Up/Down/Left/Right>` | resize window |
| `<leader>bn` / `<leader>bp` | next / previous buffer |
| `<leader>bd` / `<leader>bD` | delete buffer, keeping split layout / force |
| `<leader>bq` | close split, keep buffer |
| `<leader>e` | toggle file explorer |
| `<leader>t` | toggle floating terminal (`<C-q>` closes, `<Esc>` to normal mode) |

### Find (fzf-lua)

`<leader>ff` files · `<leader>fg` live grep · `<leader>fb` buffers ·
`<leader>fh` help tags · `<leader>fx` / `<leader>fX` document / workspace diagnostics

### LSP (buffer-local, attach-time)

| Key | Action |
|---|---|
| `gd` / `<leader>gd` | go to definition (shadows Vim's local-declaration `gd`) |
| `<leader>gD` / `<leader>gS` | definition without picker / in a vsplit |
| `K` | hover documentation |
| `<leader>ca` / `<leader>cr` | code action / rename |
| `<leader>cf` / `<leader>co` | format buffer / organize imports |
| `<leader>cd` / `<leader>d` | diagnostics for line / under cursor |
| `<leader>nd` / `<leader>pd` | next / previous diagnostic |
| `<leader>q` / `<leader>ud` | diagnostic list / toggle diagnostics |
| `<leader>fr` `ft` `fs` `fw` `fi` | references, typedefs, document & workspace symbols, implementations |

### Git (mini.diff / mini.git)

`]h` / `[h` next / previous hunk · `<leader>hs` stage · `<leader>hp` diff overlay ·
`<leader>hb` blame

### Rust (rustaceanvim, `.rs` buffers only)

`<leader>ca` is overridden with `:RustLsp codeAction`, which renders
rust-analyzer's *grouped* code actions that the built-in picker drops.

`<leader>Rr` runnables · `Rt` testables · `Re` expand macro · `RE` explain error ·
`RD` render diagnostic · `Rc` Cargo.toml · `Ro` docs.rs · `Rp` parent module ·
`Rj` join lines · `Rs` syntax tree · `Rh` hover actions

## Language servers & tooling

Servers are registered with `vim.lsp.config` and started by `vim.lsp.enable`.
A server with no executable on `PATH` is skipped silently — check
`:checkhealth vim.lsp`.

```
:MasonInstall lua-language-server efm pyright ruff bash-language-server \
  typescript-language-server gopls stylua luacheck prettierd eslint_d fixjson \
  shellcheck shfmt cpplint clang-format revive gofumpt
```

Linting and formatting go through **efm** (`efmls-configs`); Rust is handled by
rustaceanvim, which starts rust-analyzer itself — do not also enable
`rust_analyzer`, or two clients will compete.

Format-on-save is deliberately restricted: it only runs when the attached client
is on an allowlist (`efm`, `rust-analyzer`), so a general-purpose server never
reformats a buffer unexpectedly. `<leader>cf` uses the same allowlist.

## Notes & gotchas

- **treesitter tracks the `main` branch**, which compiles parsers locally and
  needs the `tree-sitter` CLI (`brew install tree-sitter-cli`) plus a C compiler.
- **`luacheck` is a LuaRocks package** — it needs `brew install luarocks` before
  Mason can build it. `.luacheckrc` declares the `vim` global.
- **blink.cmp is pinned to `1.*`** via `vim.version.range("1.*")` — `vim.pack`
  needs a `vim.VersionRange` object here, not the bare `"1.*"` string that
  lazy.nvim accepts. v2 is a breaking rewrite that also needs `blink.lib`.
- **mini.icons is mocked as `nvim-web-devicons`** (`mock_nvim_web_devicons()`),
  so nvim-tree, lualine and fzf-lua get icons without that plugin installed.
- **Transparency merges rather than replaces highlights**: `nvim_set_hl` would
  otherwise discard the colorscheme's `fg` along with the background. A
  `ColorScheme` autocmd re-applies it after a theme switch.
- Terminal transparency has to be enabled in the terminal too; nvim only stops
  painting its own background.
