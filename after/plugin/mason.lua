require("mason").setup()
require("mason-null-ls").setup({
    automatic_installation = true,
    automatic_setup = true, -- Recommended, but optional
})
require("null-ls").setup()

require 'mason-null-ls'.setup_handlers()
