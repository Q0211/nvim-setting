return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", opts = {} },
    },
    config = function()
        -- import lspconfig plugin
        local lspconfig = require("lspconfig")

        -- import cmp-nvim-lsp plugin for autocompletion
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        -- Define on_attach function
        local on_attach = function(client, bufnr)
            -- Buffer local mappings.
            local keymap = vim.keymap -- for conciseness
            local opts = { buffer = bufnr, silent = true }

            -- set keybinds
            opts.desc = "Show LSP references"
            keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

            opts.desc = "Go to declaration"
            keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

            opts.desc = "Show LSP definitions"
            keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

            opts.desc = "Show LSP implementations"
            keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

            opts.desc = "Show LSP type definitions"
            keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

            opts.desc = "See available code actions"
            keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

            opts.desc = "Smart rename"
            keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

            opts.desc = "Show buffer diagnostics"
            keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

            opts.desc = "Show line diagnostics"
            keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

            opts.desc = "Go to previous diagnostic"
            keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

            opts.desc = "Go to next diagnostic"
            keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

            opts.desc = "Show documentation for what is under cursor"
            keymap.set("n", "K", vim.lsp.buf.hover, opts)

            opts.desc = "Restart LSP"
            keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
        end

        -- Capabilities (to enable autocompletion)
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- Change the Diagnostic symbols in the sign column (gutter)
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- Setup LSP servers using mason_lspconfig
        require("mason-lspconfig").setup_handlers({
            -- default handler for installed servers
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = capabilities,
                    on_attach = on_attach,
                })
            end,
            ["clangd"] = function()
                lspconfig["clangd"].setup({
                    cmd = {
                        "clangd",
                        "--tweaks=-Wall",
                        "--tweaks=-Wunused-variable",
                        "--tweaks=-Wextra",
                        "--background-index", -- 백그라운드에서 인덱싱 활성화
                        "--clang-tidy", -- clang-tidy를 이용한 추가적인 코드 분석
                        "--cross-file-rename", -- 파일 간 이름 변경 추적
                        "--completion-style=detailed", -- 상세한 자동완성 정보
                        "--header-insertion=never", -- 헤더 자동 삽입 방지
                        "--header-insertion-decorators",
                    }, -- 기본 설정으로 실행
                    root_dir = require("lspconfig").util.root_pattern("compile_commands.json", ".git", "Makefile"),
                    capabilities = capabilities,
                    on_attach = on_attach,
                })
            end,
            -- Other LSP server setups (like lua_ls, emmet_ls, etc.) remain unchanged
            ["lua_ls"] = function()
                lspconfig["lua_ls"].setup({
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            diagnostics = { globals = { "vim" } },
                            completion = { callSnippet = "Replace" },
                        },
                    },
                    on_attach = on_attach,
                })
            end,
        })
    end,
}
