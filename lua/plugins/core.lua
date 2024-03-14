return {
  "nvim-lua/plenary.nvim",
  "echasnovski/mini.bufremove",
  {
    "AstroNvim/astrotheme",
    opts = {
      palette = "astrodark", -- String of the default palette to use when calling `:colorscheme astrotheme`
      background = {      -- :h background, palettes to use when using the core vim background colors
        light = "astrolight",
        dark = "astrodark",
      },

      style = {
        transparent = true,      -- Bool value, toggles transparency.
        inactive = true,         -- Bool value, toggles inactive window color.
        float = true,            -- Bool value, toggles floating windows background colors.
        neotree = true,          -- Bool value, toggles neo-trees background color.
        border = true,           -- Bool value, toggles borders.
        title_invert = true,     -- Bool value, swaps text and background colors.
        italic_comments = true,  -- Bool value, toggles italic comments.
        simple_syntax_colors = true, -- Bool value, simplifies the amounts of colors used for syntax highlighting.
      },

      termguicolors = true, -- Bool value, toggles if termguicolors are set by AstroTheme.

      terminal_color = true, -- Bool value, toggles if terminal_colors are set by AstroTheme.

      plugin_default = "auto", -- Sets how all plugins will be loaded
      -- "auto": Uses lazy / packer enabled plugins to load highlights.
      -- true: Enables all plugins highlights.
      -- false: Disables all plugins.

      plugins = { -- Allows for individual plugin overrides using plugin name and value from above.
        ["bufferline.nvim"] = false,
      },

      palettes = {
        global = { -- Globally accessible palettes, theme palettes take priority.
          my_grey = "#ebebeb",
          my_color = "#ffffff",
        },
        astrodark = {     -- Extend or modify astrodarks palette colors
          ui = {
            red = "#800010", -- Overrides astrodarks red UI color
            accent = "#CC83E3", -- Changes the accent color of astrodark.
          },
          syntax = {
            cyan = "#800010", -- Overrides astrodarks cyan syntax color
            comments = "#CC83E3", -- Overrides astrodarks comment color.
          },
          my_color = "#000000", -- Overrides global.my_color
        },
      },

      highlights = {
        global = { -- Add or modify hl groups globally, theme specific hl groups take priority.
          modify_hl_groups = function(hl, c)
            hl.PluginColor4 = { fg = c.my_grey, bg = c.none }
          end,
          ["@String"] = { fg = "#ff00ff", bg = "NONE" },
        },
        astrodark = {
          -- first parameter is the highlight table and the second parameter is the color palette table
          modify_hl_groups = function(hl, c) -- modify_hl_groups function allows you to modify hl groups,
            hl.Comment.fg = c.my_color
            hl.Comment.italic = true
          end,
          ["@String"] = { fg = "#ff00ff", bg = "NONE" },
        },
      },
    },
  },
  { "max397574/better-escape.nvim", event = "InsertCharPre", opts = { timeout = 300 } },
  {
    "NMAC427/guess-indent.nvim",
    event = "User AstroFile",
    config = require("plugins.configs.guess-indent"),
  },
  { -- TODO: REMOVE neovim-session-manager with AstroNvim v4
    "Shatur/neovim-session-manager",
    event = "BufWritePost",
    cmd = "SessionManager",
    enabled = vim.g.resession_enabled ~= true,
  },
  {
    "stevearc/resession.nvim",
    enabled = vim.g.resession_enabled == true,
    opts = {
      buf_filter = function(bufnr)
        return require("astronvim.utils.buffer").is_restorable(bufnr)
      end,
      tab_buf_filter = function(tabpage, bufnr)
        return vim.tbl_contains(vim.t[tabpage].bufs, bufnr)
      end,
      extensions = { astronvim = {} },
    },
  },
  {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    opts = { picker_config = { statusline_winbar_picker = { use_winbar = "smart" } } },
  },
  {
    "mrjones2014/smart-splits.nvim",
    opts = { ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" }, ignored_buftypes = { "nofile" } },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = { java = false },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0,
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
    config = require("plugins.configs.nvim-autopairs"),
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { group = vim.g.icons_enabled and "" or "+", separator = "" },
      disable = { filetypes = { "TelescopePrompt" } },
    },
    config = require("plugins.configs.which-key"),
  },
  {
    "kevinhwang91/nvim-ufo",
    event = { "User AstroFile", "InsertEnter" },
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      preview = {
        mappings = {
          scrollB = "<C-b>",
          scrollF = "<C-f>",
          scrollU = "<C-u>",
          scrollD = "<C-d>",
        },
      },
      provider_selector = function(_, filetype, buftype)
        local function handleFallbackException(bufnr, err, providerName)
          if type(err) == "string" and err:match("UfoFallbackException") then
            return require("ufo").getFolds(bufnr, providerName)
          else
            return require("promise").reject(err)
          end
        end

        return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
            or function(bufnr)
              return require("ufo")
                  .getFolds(bufnr, "lsp")
                  :catch(function(err)
                    return handleFallbackException(bufnr, err, "treesitter")
                  end)
                  :catch(function(err)
                    return handleFallbackException(bufnr, err, "indent")
                  end)
            end
      end,
    },
  },
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    opts = function()
      local commentstring_avail, commentstring =
          pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      return commentstring_avail and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      size = 10,
      on_create = function()
        vim.opt.foldcolumn = "0"
        vim.opt.signcolumn = "no"
      end,
      open_mapping = [[<F7>]],
      shading_factor = 2,
      direction = "float",
      float_opts = {
        border = "curved",
        highlights = { border = "Normal", background = "Normal" },
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
  },
  "folke/trouble.nvim",

  {
    "ThePrimeagen/harpoon",
  },

  "b0o/incline.nvim",
}
