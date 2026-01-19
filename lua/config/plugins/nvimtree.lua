return {

  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  priority = 1000, -- ensure it loads early to disable netrw
  config = function()
    -- disable netrw at the very start
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    vim.opt.termguicolors = true
    -- setup with options
    require("nvim-tree").setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      update_focused_file = {
        enable = true,

      },
      filters = {
        git_ignored = false,
        dotfiles = false,
      },
    })
  end,
  keys = {
    { "<C-b>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
  }
}
