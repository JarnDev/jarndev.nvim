return {
  'ruifm/gitlinker.nvim',
  event = 'BufReadPre',
  dependencies = 'nvim-lua/plenary.nvim',
  config = function()
    require('gitlinker').setup({
      opts = {
        callbacks = {
          ['github.com'] = require('gitlinker.hosts').get_github_type_url,
          ['gitlab.com'] = require('gitlinker.hosts').get_gitlab_type_url,
          ['bitbucket.org'] = require('gitlinker.hosts').get_bitbucket_type_url,
        },
      },
    })
  end,
} 