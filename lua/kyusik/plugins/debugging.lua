return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "rcarriga/nvim-dap-ui",
        "leoluz/nvim-dap-go",
        "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
        local dap, dapui = require("dap"), require("dapui")

        require("dapui").setup()
        require("nvim-dap-virtual-text").setup()

        -- dap-ui config
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        -- dap-virtual-text config
        require("nvim-dap-virtual-text").setup({
            enabled = true, -- enable this plugin (the default)
            enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
            highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
            highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
            show_stop_reason = true, -- show stop reason when stopped for exceptions
            commented = false, -- prefix virtual text with comment string
            only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
            all_references = false, -- show virtual text on all all references of the variable (not only definitions)
            clear_on_continue = false, -- clear virtual text on "continue" (might cause flickering when stepping)
            display_callback = function(variable, buf, stackframe, node, options)
                -- by default, strip out new line characters
                if options.virt_text_pos == "inline" then
                    return " = " .. variable.value:gsub("%s+", " ")
                else
                    return variable.name .. " = " .. variable.value:gsub("%s+", " ")
                end
            end,
            -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
            virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",

            -- experimental features:
            all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
            virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
            virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
            -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
        })

        -- debugging languages
        require("dap-go").setup()

        dap.adapters.lldb = {
            type = "executable",
            command = "/opt/homebrew/opt/llvm/bin/lldb-dap", -- lldb-vscode 경로
            name = "lldb",
        }

        dap.configurations.cpp = {
            {
                name = "Launch",
                type = "lldb",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
                args = {},
            },
        }

        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp

        -- Keymap
        vim.keymap.set("n", "<F5>", function()
            require("dap").continue()
        end)
        vim.keymap.set("n", "<F10>", function()
            require("dap").step_over()
        end)
        vim.keymap.set("n", "<F11>", function()
            require("dap").step_into()
        end)
        vim.keymap.set("n", "<F12>", function()
            require("dap").step_out()
        end)
        vim.keymap.set("n", "<Leader>b", function()
            require("dap").toggle_breakpoint()
        end)
        vim.keymap.set("n", "<Leader>B", function()
            require("dap").set_breakpoint()
        end)
        vim.keymap.set("n", "<Leader>lp", function()
            require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end)
        vim.keymap.set("n", "<Leader>dr", function()
            require("dap").repl.open()
        end)
        vim.keymap.set("n", "<Leader>dl", function()
            require("dap").run_last()
        end)
        vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
            require("dap.ui.widgets").hover()
        end)
        vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
            require("dap.ui.widgets").preview()
        end)
        vim.keymap.set("n", "<Leader>df", function()
            local widgets = require("dap.ui.widgets")
            widgets.centered_float(widgets.frames)
        end)
        vim.keymap.set("n", "<Leader>ds", function()
            local widgets = require("dap.ui.widgets")
            widgets.centered_float(widgets.scopes)
        end)
    end,
}
