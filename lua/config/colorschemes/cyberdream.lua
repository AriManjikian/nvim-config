return {
  {
    "scottmckendry/cyberdream.nvim",
    name = "cyberdream",
    priority = 1000, -- Ensure it loads before other plugins
    config = function()
      require("cyberdream").setup({
        transparent = false,            -- Set to true if you want a transparent background
        italic_comments = true,         -- Enable italics for comments
        hide_fillchars = true,          -- Hide fill characters for a cleaner UI
        borderless_telescope = true,    -- Remove borders from Telescope
      })
      vim.cmd.colorscheme("cyberdream") -- Apply colorscheme
    end,
  },
}
