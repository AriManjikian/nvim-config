return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "saghen/blink.cmp",
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the vim.uv word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      -- Setup for lua_ls (Lua)
      require("lspconfig").lua_ls.setup {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              disable = { "missing-fields" }, -- 👈 disables the warning
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true), -- better Neovim API awareness
              checkThirdParty = false,                           -- optional: avoids "undefined global" warnings from plugins
            },
          },
        },
      }

      -- Setup for gopls (Go)
      require("lspconfig").gopls.setup { capabilities = capabilities }

      -- Setup for tailwindcss
      require("lspconfig").tailwindcss.setup { capabilities = capabilities }

      -- Setup for tailwindcss
      require("lspconfig").eslint.setup { capabilities = capabilities }

      -- Setup for ts_ls (typescript)
      require("lspconfig").ts_ls.setup({
        capabilities = capabilities,
        init_options = {
          preferences = {
            quotePreference = "single",
            importModuleSpecifierPreference = "relative",
          },
        },
      })

      require("lspconfig").verible.setup {
        cmd = { "verible-verilog-ls", "--rules_config_search" },
        filetypes = { "verilog", "systemverilog" },
        root_dir = require("lspconfig.util").root_pattern(".git", "."),
        capabilities = capabilities,
      }

      require("lspconfig").svlangserver.setup {
        cmd = { "svlangserver", "--stdio" },
        filetypes = { "verilog", "systemverilog" },
        root_dir = require("lspconfig.util").root_pattern(".git", ".svlangserver.toml"),
      }

      require("lspconfig").pylsp.setup {
        capabilities = capabilities,
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                ignore = { "E501" },
                maxLineLength = 100, },
            },
          },
        },
      }

      require("lspconfig").ruff.setup {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- Format with Ruff on save
          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ async = false })
              end,
            })
          end
        end,
        settings = {
          ruff = {
            organizeImports = true,
            fixAll = true,
          },
        },
      }

      require("lspconfig").ocamllsp.setup {
        cmd = { "ocamllsp" },
        filetypes = { "ocaml", "ocamllex", "menhir", "ocamlyacc" },
        root_dir = require("lspconfig.util").root_pattern("dune-project", ".git"),
      }
      -- Setup for clangd (C/C++)
      require("lspconfig").clangd.setup {
        capabilities = capabilities,
        cmd = { "clangd", "--background-index", "--clang-tidy" },
      }

      -- Autocommand to format on save if the LSP supports it
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end
          if client:supports_method('textDocument/formatting') then
            -- Format the current buffer on save
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                vim.cmd([[%s/\s\+$//e]])
                vim.cmd([[%s/\t/    /ge]])
              end,
            })
          end
        end,
      })
    end,
  }
}
