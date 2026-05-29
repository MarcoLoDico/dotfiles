-- Minimal Neovim config focused on code editing, readable diffs, and reviewing changes.
-- First launch bootstraps lazy.nvim, then installs the small plugin set below.

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3

local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.colorcolumn = "100"
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Editing
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.undofile = true
opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.confirm = true

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
  extra = extra or {}
  extra.desc = desc
  vim.keymap.set(mode, lhs, rhs, extra)
end

-- Everyday editing
map("n", "<leader>w", "<cmd>write<cr>", "Save")
map("n", "<leader>q", "<cmd>quit<cr>", "Quit")
map("n", "<leader>e", "<cmd>Explore<cr>", "Open file explorer")
map("n", "<leader>h", "<cmd>nohlsearch<cr>", "Clear search highlight")
map("n", "<leader>bd", "<cmd>bdelete<cr>", "Close buffer")
map("n", "<leader>tw", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.winrestview(view)
end, "Trim trailing whitespace")

-- Keep selection while indenting.
map("v", "<", "<gv", "Indent left")
map("v", ">", ">gv", "Indent right")

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
    vim.opt_local.colorcolumn = "73"
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

  -- Code-aware highlighting and indentation.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
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
          "jsonc",
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
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
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
})
