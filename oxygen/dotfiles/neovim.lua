local map = vim.keymap.set
local opt = vim.opt

map("n", ">", ">>")
map("n", "<", "<<")
map("v", ">", ">gv")
map("v", "<", "<gv")
map("n", "<C-u>", "<C-u>zz")
map("n", "<C-d>", "<C-d>zz")

map("n", "<leader><space>", ":nohlsearch<CR>")

if vim.g.vscode == nil then
    opt.mouse = "a";
    opt.number = true;

    require("nvim-tree").setup()
    map("n", "<C-b>", "<cmd> NvimTreeToggle <CR>")

--    vim.cmd([[
--        colorscheme github_light
--        set guifont=JetBrains\ Mono\ Nerd\ Font
--    ]])

    -- Plugins

    -- opt.termguicolors = true
    require("bufferline").setup({})

    map("n", "<C-p>", "<cmd> lua require('telescope.builtin').git_files() <CR>")
    map("n", "<C-o>", "<cmd> lua require('telescope.builtin').lsp_workspace_symbols() <CR>")

    require('nvim-treesitter.configs').setup({
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
    })

    require('Comment').setup()
    map("n", "<C-_>", "<CMD>lua require('Comment.api').toggle_current_linewise()<CR>")
    map("x", "<C-_>", "<ESC><CMD>lua require('Comment.api').locked.toggle_linewise_op(vim.fn.visualmode())<CR>gv")

    -- require("nvim-tree").setup()

    -- LSP Config

    local nvim_lsp = require("lspconfig")
    nvim_lsp.pyright.setup({})
    nvim_lsp.rnix.setup({})
    nvim_lsp.rust_analyzer.setup({
        -- on_attach = function(client) 
        --     require("completion").on_attach(client) 
        -- end,
        settings = {
            ["rust-analyzer"] = {
                assist = {
                    importGranularity = "module",
                    importPrefix = "self",
                },
                cargo = {
                    loadOutDirsFromCheck = true
                },
                procMacro = {
                    enable = true
                },
            }
        }
    })
end
