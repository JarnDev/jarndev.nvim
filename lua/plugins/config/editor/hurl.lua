-- HTTP requests from the editor with Hurl (hurl.dev, Orange, Apache-2.0): plain-text
-- .hurl files with asserts (`HTTP 200`, `jsonpath "$.id" == 1`) that also run in CI
-- as API tests (`hurl --test`). Replaced kulala, whose engine became a closed binary
-- behind a license token. Needs the `hurl` binary (brew / GitHub release).
local function cmd(c)
  return '<cmd>' .. c .. '<cr>'
end

return {
  'jellydn/hurl.nvim',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  ft = 'hurl',
  keys = {
    { '<leader>rr', cmd 'HurlRunnerAt', ft = 'hurl', desc = '[R]un the request under the cursor' },
    { '<leader>rR', cmd 'HurlRunner', ft = 'hurl', desc = '[R]un every request in the file' },
    { '<leader>re', cmd 'HurlSetEnvFile', ft = 'hurl', desc = 'HTTP s[E]t the env file' },
    { '<leader>ri', cmd 'HurlVerbose', ft = 'hurl', desc = 'HTTP [I]nspect: run verbose' },
    { '<leader>rl', cmd 'HurlShowLastResponse', ft = 'hurl', desc = 'HTTP: [L]ast response' },
  },
  opts = {
    mode = 'split', -- response in a split (edgy-friendly); `popup` is the float
    show_notification = false,
  },
}
