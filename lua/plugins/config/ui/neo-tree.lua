return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    {
      '\\',
      function()
        require('neo-tree.command').execute { source = 'filesystem', toggle = true }
      end,
      desc = 'Explorer NeoTree (root dir)',
    },
    {
      '<leader>E',
      function()
        require('neo-tree.command').execute { source = 'filesystem', toggle = true, dir = vim.uv.cwd() }
      end,
      desc = 'Explorer NeoTree (cwd)',
    },
  },
  opts = {
    sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
    open_files_do_not_replace_types = { 'terminal', 'Trouble', 'trouble', 'qf', 'Outline' },
    filesystem = {
      use_libuv_file_watcher = false,
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
    commands = {
      open_or_play = function(state)
        local node = state.tree:get_node()
        local path = node:get_id()
        local ext = (path:match '%.(%w+)$' or ''):lower()
        local video_exts = { mp4 = true, mkv = true, avi = true, mov = true, webm = true, flv = true, wmv = true, m4v = true }
        if video_exts[ext] then
          vim.fn.jobstart({ 'mpv', path }, { detach = true })
          vim.notify('Playing: ' .. vim.fn.fnamemodify(path, ':t'))
          return
        end
        require('neo-tree.sources.filesystem.commands').open(state)
      end,
    },
    window = {
      mappings = {
        ['<space>'] = 'none',
        ['<CR>'] = 'open_or_play',
      },
    },
  },
}
