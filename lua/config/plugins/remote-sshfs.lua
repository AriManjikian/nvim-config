return {
  "nosduco/remote-sshfs.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  opts = {
    connections = {
      hosts = {
        {
          name = "gt-ece",
          sshfs_args = { "gt-ece:/" },
        },
      },
      sshfs_args = { "-o reconnect", "-o ConnectTimeout=5" },
    },
    mounts = {
      base_dir = vim.fn.expand("$HOME/.sshfs/"),
      unmount_on_exit = true,
    },
  },
  config = function(_, opts)
    local api = require("remote-sshfs.api")
    local connections = require("remote-sshfs.connections")
    local builtin = require("telescope.builtin")

    -- Setup plugin
    require("remote-sshfs").setup(opts)

    -- Load Telescope extension safely
    vim.schedule(function()
      local ok = pcall(require("telescope").load_extension, "remote-sshfs")
      if not ok then
        vim.notify("Failed to load remote-sshfs Telescope extension", vim.log.levels.WARN)
      end
    end)

    -- Keymaps for remote-sshfs API
    vim.keymap.set("n", "<leader>rc", api.connect, { desc = "Remote SSHFS Connect" })
    vim.keymap.set("n", "<leader>rd", api.disconnect, { desc = "Remote SSHFS Disconnect" })
    vim.keymap.set("n", "<leader>re", api.edit, { desc = "Remote SSHFS Edit" })
  end,
}
