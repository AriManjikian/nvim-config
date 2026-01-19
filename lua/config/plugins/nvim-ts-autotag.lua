return {
  "windwp/nvim-ts-autotag",
  event = "InsertEnter",
  config = function()
    require("nvim-ts-autotag").setup({
      opts = {
        enable_close = true,          -- auto close tags
        enable_rename = true,         -- auto rename closing tag when opening tag changes
        enable_close_on_slash = false -- don't auto-close on </
      },
      per_filetype = {
        html = {
          enable_close = false -- override for HTML files
        }
      }
    })
  end,
}
