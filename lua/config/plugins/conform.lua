return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        python = { "black" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        ["ipynb"] = {},
      },
      formatters = {
        prettier = {
          prepend_args = {
            "--print-width", "120",
            "--tab-width", "2",
            "--use-tabs", "false",
            "--semi", "true",
            "--single-quote", "true",
            "--bracket-spacing", "false",
            "--arrow-parens", "avoid",
            "--prose-wrap", "never"
          },
        },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    })
  end,
}
