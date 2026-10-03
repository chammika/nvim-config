-- luacheck config for this Neovim config directory
std = "lua54"
globals = { "vim" } -- `vim` is injected by Neovim, not a global luacheck knows
max_line_length = false -- stylua owns line width; don't double-report it
