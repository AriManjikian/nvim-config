return {
  {
    dir = "~/.config/nvim/plugin/present.nvim",
    config = function()
      require "present".setup()
    end,
  },
  {
    dir = "~/dev/latest_error.nvim",
    config = function()
      require "latest_error".setup()
    end,
  },

}
