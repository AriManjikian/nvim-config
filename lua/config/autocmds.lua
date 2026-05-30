-- build cpp files
vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function()
        vim.keymap.set("n", "<leader>b", function()
            vim.cmd("w")
            local file = vim.fn.expand("%:p")
            local out = vim.fn.expand("%:p:r")
            local build_cmd = string.format("g++ -O2 %s -o %s && %s", file, out, out)
            local asm_cmd = string.format("g++ -O2 -S %s -o %s.s", file, out)

            local width = math.floor(vim.o.columns * 0.8)
            local height = math.floor(vim.o.lines * 0.6)
            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((vim.o.columns - width) / 2)

            local buf = vim.api.nvim_create_buf(false, true)

            local win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = width,
                height = height,
                row = row,
                col = col,
                style = "minimal",
                border = "rounded",
                title = "Building: " .. vim.fn.expand("%:t") .. " ",
                title_pos = "center",
                footer = " [q] close",
                footer_pos = "center",
            })

            vim.api.nvim_set_option_value("winhl",
                "Normal:NormalFloat,FloatBorder:FloatBorder", { win = win })
            vim.api.nvim_set_option_value("winblend", 5, { win = win })

            vim.fn.termopen(build_cmd, {
                on_exit = function(_, exit_code)
                    if not vim.api.nvim_win_is_valid(win) then return end
                    local icon = exit_code == 0 and "✓" or "✗"
                    pcall(vim.api.nvim_win_set_config, win, {
                        title = " " .. icon .. "  " .. vim.fn.expand("%:t") .. " ",
                        title_pos = "center",
                    })


                    if exit_code == 0 then
                        vim.fn.jobstart(asm_cmd, {
                            on_exit = function(_, asm_exit_code)
                                if asm_exit_code ~= 0 then
                                    vim.notify("asm generation failed", vim.log.levels.WARN)
                                end
                            end,
                        })
                    end
                end,
            })

            for _, key in ipairs({ "q", "<Esc>" }) do
                vim.keymap.set({ "n", "t" }, key, function()
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                    end
                end, { buffer = buf, nowait = true })
            end

            vim.cmd("startinsert")
        end, { buffer = true })
    end,
})
