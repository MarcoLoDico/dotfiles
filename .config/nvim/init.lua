-- Minimal Neovim config focused on code editing, readable diffs, and reviewing changes.
-- First launch bootstraps lazy.nvim, then installs the small plugin set below.

vim.g.mapleader = " "
vim.g.maplocalleader = ","
-- nvim-tree replaces the built-in netrw browser.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

-- Clean, distraction-free UI. No cursor line, column ruler, or whitespace marks.
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.mousemodel = "popup_setpos"
-- A click only places the cursor; text selection starts only after dragging.
opt.selectmode = ""
opt.cursorline = false
opt.cursorcolumn = false
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.colorcolumn = ""
opt.list = false

-- Comfortable editor defaults.
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.undofile = true
opt.swapfile = false
opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 400

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = "split"

-- Windows / splits
opt.splitbelow = true
opt.splitright = true

-- Better built-in diffs. Especially useful for reviewing AI-generated edits.
opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "algorithm:histogram",
  "indent-heuristic",
  "linematch:60",
}

vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

local function map(mode, lhs, rhs, desc, extra)
  if type(lhs) == "table" then
    for _, key in ipairs(lhs) do
      map(mode, key, rhs, desc, extra)
    end
    return
  end
  extra = extra or {}
  extra.desc = desc
  vim.keymap.set(mode, lhs, rhs, extra)
end

-- Everyday editing. Standard Vim keys still work; these add familiar shortcuts.
map("n", "<leader>w", "<cmd>write<cr>", "Save")
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr>", "Save")
map("n", "<leader>q", "<cmd>quit<cr>", "Quit")
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", "Toggle file tree")
map("n", "<leader>h", "<cmd>nohlsearch<cr>", "Clear search highlight")
map("n", "<leader>bd", "<cmd>bdelete<cr>", "Close buffer")
map("n", "<S-h>", "<cmd>bprevious<cr>", "Previous buffer")
map("n", "<S-l>", "<cmd>bnext<cr>", "Next buffer")
map("n", "<leader>tw", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.winrestview(view)
end, "Trim trailing whitespace")

-- Familiar editor shortcuts. Command works when the terminal forwards it;
-- Control is the reliable terminal equivalent. Standard Vim keys still work.
map("x", "p", [=["_dP]=], "Paste without replacing clipboard")
map({ "x", "s" }, { "<C-c>", "<D-c>" }, [=["+y]=], "Copy selection")
map({ "x", "s" }, { "<C-x>", "<D-x>" }, [=["+d]=], "Cut selection")
map("n", { "<C-v>", "<D-v>" }, [=["+p]=], "Paste from system clipboard")
map("i", { "<C-v>", "<D-v>" }, "<C-r>+", "Paste from system clipboard")
map({ "x", "s" }, { "<C-v>", "<D-v>" }, [=["_d"+P]=], "Replace with system clipboard")
map("n", { "<C-z>", "<D-z>" }, "u", "Undo")
map("i", { "<C-z>", "<D-z>" }, "<C-o>u", "Undo")
map("n", { "<C-y>", "<D-S-z>" }, "<C-r>", "Redo")
map("i", { "<C-y>", "<D-S-z>" }, "<C-o><C-r>", "Redo")
map("n", { "<C-a>", "<D-a>" }, "ggVG", "Select all")
map("i", { "<C-a>", "<D-a>" }, "<Esc>ggVG", "Select all")
map("n", "<C-q>", "<C-v>", "Visual block mode")
map("x", "<leader>y", [=["+y]=], "Copy selection to system clipboard")
map("n", "<leader>p", [=["+p]=], "Paste from system clipboard")
map({ "n", "x" }, "<leader>d", [=["_d]=], "Delete without replacing clipboard")
map({ "n", "x" }, "<leader>x", [=["_x]=], "Remove character without replacing clipboard")
map("n", "<leader>a", "ggVG", "Select all")

-- Keep selections while indenting, and move selected lines with Alt-j/k.
map("v", "<", "<gv", "Indent left")
map("v", ">", ">gv", "Indent right")
map("v", "<M-j>", ":m '>+1<cr>gv=gv", "Move selection down")
map("v", "<M-k>", ":m '<-2<cr>gv=gv", "Move selection up")
map("n", "<M-j>", "<cmd>move .+1<cr>==", "Move line down")
map("n", "<M-k>", "<cmd>move .-2<cr>==", "Move line up")

-- Move around splits quickly.
map("n", "<C-h>", "<C-w>h", "Go to left split")
map("n", "<C-j>", "<C-w>j", "Go to lower split")
map("n", "<C-k>", "<C-w>k", "Go to upper split")
map("n", "<C-l>", "<C-w>l", "Go to right split")

-- Diagnostics are ready for any LSP you add later.
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
map("n", "<leader>dl", vim.diagnostic.setloclist, "Diagnostics list")

local augroup = vim.api.nvim_create_augroup("marco_nvim", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 180 })
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lines = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.textwidth = 72
  end,
})

-- Bootstrap lazy.nvim.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. out)
  end
end
opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Lightweight, clickable project tree on the left.
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    opts = {
      hijack_cursor = true,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = { enable = true, update_root = false },
      view = {
        side = "left",
        width = 30,
        preserve_window_proportions = true,
      },
      renderer = {
        root_folder_label = function(path)
          return vim.fn.fnamemodify(path, ":t")
        end,
        group_empty = false,
        highlight_git = true,
        indent_markers = { enable = true },
        icons = { show = { file = false, folder = true, folder_arrow = true, git = true } },
      },
      -- Show useful dotfiles such as .vimrc, but hide Git's internal database.
      filters = { dotfiles = false, custom = { "^%.git$" } },
      actions = { open_file = { quit_on_open = false, resize_window = true } },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        -- Dragging in the file tree should never create a text selection.
        vim.keymap.set({ "n", "x", "s" }, "<LeftDrag>", "<Nop>", {
          buffer = bufnr,
          desc = "Ignore drag in file tree",
        })
      end,
    },
    config = function(_, opts)
      local api = require("nvim-tree.api")
      require("nvim-tree").setup(opts)

      -- Mouse mappings must be global so the first click works even when the
      -- editor currently has focus. Press focuses the tree; release opens it.
      local function tree_mouse(event, open_node)
        local mouse = vim.fn.getmousepos()
        if mouse.winid ~= 0 and vim.api.nvim_win_is_valid(mouse.winid) then
          local buf = vim.api.nvim_win_get_buf(mouse.winid)
          if vim.bo[buf].filetype == "NvimTree" then
            if vim.fn.mode():find("^[iR]") then
              vim.cmd("stopinsert")
            elseif vim.fn.mode():find("^[vVsS\22]") then
              vim.cmd("normal! \27")
            end
            vim.api.nvim_set_current_win(mouse.winid)
            pcall(vim.api.nvim_win_set_cursor, mouse.winid, {
              mouse.line,
              math.max(mouse.column - 1, 0),
            })
            if open_node then
              api.node.open.edit()
            end
            return
          end
        end
        vim.api.nvim_feedkeys(vim.keycode(event), "n", false)
      end

      vim.keymap.set({ "n", "i", "x", "s" }, "<LeftMouse>", function()
        tree_mouse("<LeftMouse>", false)
      end, { desc = "Place cursor or focus file tree" })
      vim.keymap.set({ "n", "i", "x", "s" }, "<LeftRelease>", function()
        tree_mouse("<LeftRelease>", true)
      end, { desc = "Finish selection or open tree entry" })

      -- Make :q exit normally when the tree is the only other window.
      vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
          if vim.bo.filetype == "NvimTree" then
            return
          end

          local editor_windows = 0
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(win)
            local buf = vim.api.nvim_win_get_buf(win)
            if config.relative == "" and vim.bo[buf].filetype ~= "NvimTree" then
              editor_windows = editor_windows + 1
            end
          end

          if editor_windows <= 1 then
            api.tree.close()
          end
        end,
      })

      vim.schedule(function()
        api.tree.open()
        if vim.fn.winnr("$") > 1 then
          vim.cmd("wincmd p")
        end
      end)
    end,
  },

  -- Show available leader-key commands in a clean popup.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      icons = { mappings = false },
    },
  },

  -- Nice, high-contrast highlighting without extra setup.
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Code-aware highlighting. The main branch is required by Neovim 0.12+.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local parsers = {
        "bash",
        "c",
        "cpp",
        "css",
        "diff",
        "dockerfile",
        "go",
        "gomod",
        "gosum",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "ruby",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      }

      local treesitter = require("nvim-treesitter")
      treesitter.setup({})
      -- JSON-with-comments uses the JSON parser in the rewritten plugin.
      vim.treesitter.language.register("json", "jsonc")
      treesitter.install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        callback = function(args)
          local language = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if language and vim.tbl_contains(parsers, language) then
            pcall(vim.treesitter.start, args.buf, language)
          end
        end,
      })
    end,
  },

  -- File finding and text search.
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files({ hidden = true }) end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Search text" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Find buffers" },
      { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Recent files" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
    },
    opts = {
      defaults = {
        file_ignore_patterns = { "%.git/", "node_modules/", "vendor/" },
      },
    },
  },

  -- Git signs, hunks, blame, and quick previews inline with your code.
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      current_line_blame = false,
      preview_config = { border = "rounded" },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function gmap(mode, lhs, rhs, desc, extra)
          extra = extra or {}
          extra.buffer = bufnr
          extra.desc = desc
          vim.keymap.set(mode, lhs, rhs, extra)
        end

        gmap("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(gs.next_hunk)
          return "<Ignore>"
        end, "Next git hunk", { expr = true })

        gmap("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(gs.prev_hunk)
          return "<Ignore>"
        end, "Previous git hunk", { expr = true })

        gmap({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<cr>", "Stage hunk")
        gmap({ "n", "v" }, "<leader>gx", ":Gitsigns reset_hunk<cr>", "Reset hunk")
        gmap("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
        gmap("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        gmap("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        gmap("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle line blame")
        gmap("n", "<leader>gd", gs.diffthis, "Diff current file")
        gmap("n", "<leader>gD", function() gs.diffthis("~") end, "Diff against previous commit")
        gmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>", "Git hunk")
      end,
    },
  },

  -- Full-screen git diff/review UI. Great for reviewing generated changes before committing.
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewFocusFiles", "DiffviewToggleFiles" },
    keys = {
      { "<leader>gr", "<cmd>DiffviewOpen<cr>", desc = "Review uncommitted changes" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close review" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Current file history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history" },
    },
    opts = {
      enhanced_diff_hl = true,
      file_panel = { listing_style = "tree" },
    },
  },
}, {
  install = { colorscheme = { "tokyonight" } },
  change_detection = { notify = false },
  -- None of these plugins use LuaRocks; disabling it avoids a pointless toolchain warning.
  rocks = { enabled = false },
})
