-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- LSP settings.
local on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  if client.name == "eslint" then
    vim.cmd([[ LspStop eslint ]])
    return
  end

  nmap("<leader>vrn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>vca", vim.lsp.buf.code_action, "[C]ode [A]ction")
  nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-m>", vim.lsp.buf.signature_help, "Signature Documentation")
  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
    vim.lsp.buf.format()
  end, { desc = "Format current buffer with LSP" })

  local icons = require "jvsr.icons"
  local signs = {

    { name = "DiagnosticSignError", text = icons.diagnostics.Error },
    { name = "DiagnosticSignWarn",  text = icons.diagnostics.Warning },
    { name = "DiagnosticSignHint",  text = icons.diagnostics.Hint },
    { name = "DiagnosticSignInfo",  text = icons.diagnostics.Information },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    -- disable virtual text
    virtual_lines = true,
    virtual_text = true,
    -- show signs
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      -- border = {"▄","▄","▄","█","▀","▀","▀","█"},
      source = "if_many", -- Or "always"
      header = "",
      prefix = "",
      -- width = 40,
    },
  }

  vim.diagnostic.config(config)
end

vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format()
end)

local servers = {}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require("mason").setup()
require("mason-null-ls").setup({ automatic_installation = true, automatic_setup = true })
require("null-ls").setup()

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
  function(server_name)
    require("lspconfig")[server_name].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    })
  end,
})

-- nvim-cmp setup
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip/loaders/from_vscode").lazy_load()

luasnip.config.setup({})
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local select_opts = { behavior = 'select' }
local icons = require "jvsr.icons"

local kind_icons = icons.kind

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
vim.api.nvim_set_hl(0, "CmpItemKindTabnine", { fg = "#CA42F0" })
vim.api.nvim_set_hl(0, "CmpItemKindEmoji", { fg = "#FDE030" })
vim.api.nvim_set_hl(0, "CmpItemKindCrate", { fg = "#F64D00" })

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  formatting = {
    fields = { "kind", "abbr", "menu" },

    format = function(entry, vim_item)
      -- Kind icons
      vim_item.kind = kind_icons[vim_item.kind]

      -- NOTE: order matters
      vim_item.menu = ({
            nvim_lsp = "",
            nvim_lua = "",
            luasnip = "",
            buffer = "",
            path = "",
            emoji = "",
          })[entry.source.name]
      return vim_item
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-f>"] = cmp.mapping.scroll_docs(5),
    ["<C-u>"] = cmp.mapping.scroll_docs( -5),

    -- confirm selection
    ['<C-y>'] = cmp.mapping.confirm({ select = false }),

    -- navigate items on the list
    ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
    ['<Down>'] = cmp.mapping.select_next_item(select_opts),
    ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
    ['<C-n>'] = cmp.mapping.select_next_item(select_opts),

    -- toggle completion
    ['<C-e>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.abort()
      else
        cmp.complete()
      end
    end),

    -- go to next placeholder in the snippet
    ['<C-d>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { 'i', 's' }),

    -- go to previous placeholder in the snippet
    ['<C-b>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable( -1) then
        luasnip.jump( -1)
      else
        fallback()
      end
    end, { 'i', 's' })
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip", keyword_length = 2 },
  },
})
