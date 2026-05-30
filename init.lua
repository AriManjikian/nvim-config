require("config.lazy")
require("config.autocmds")

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 5
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.wo.number = true
vim.opt.fileformat = 'unix'
vim.diagnostic.config({ virtual_text = true })

vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set("n", "-", "<cmd>Oil<CR>")

-- Key mappings for saving with <C-s> in normal and insert modes
vim.keymap.set('n', '<C-s>', function()
    -- Save the file
    vim.cmd('w!')
    -- Silently remove carriage returns
    pcall(vim.cmd, '%s/\\r//ge')
end, { noremap = true, silent = true })

vim.keymap.set('i', '<C-s>', function()
    -- Exit insert mode, save the file, remove carriage returns, and re-enter insert mode
    vim.cmd('stopinsert') -- Exit insert mode
    vim.cmd('w!')
    pcall(vim.cmd, '%s/\\r//ge')
    vim.cmd('startinsert')                 -- Re-enter insert mode
    vim.api.nvim_feedkeys('a', 'n', false) -- Append after cursor
end, { noremap = true, silent = true })

vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true })
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { noremap = true, silent = true })
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { noremap = true, silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd('TermOpen', {
    desc = 'Open Terminal Window',
    group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
    end,
})

vim.keymap.set("n", "<space>st", function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 10)
    vim.cmd.startinsert()
end)

-- Colorschemes
local colorschemes = { "cyberdream", "tokyonight-moon", "mfd-paper", "moonfly", "onedark" }
local index = 4
vim.cmd("colorscheme " .. colorschemes[index])
local function nextTheme()
    index = index % #colorschemes + 1
    vim.cmd("colorscheme " .. colorschemes[index])
end
vim.keymap.set("n", "<space>cs", nextTheme)



-- AriManjikian --
