-- Open the quickfix in trouble when a task produced diagnostics, otherwise just say the
-- check passed. Pairs with on_result_diagnostics_quickfix (core/checks.lua).
---@type overseer.ComponentFileDefinition
return {
  desc = 'Open trouble on the quickfix when the task result has diagnostics',
  constructor = function()
    return {
      on_result = function(_, task, result)
        local n = #(result.diagnostics or {})
        vim.schedule(function()
          if n > 0 then
            vim.cmd 'Trouble qflist open'
          else
            vim.notify(task.name .. ': nenhum problema', vim.log.levels.INFO)
          end
        end)
      end,
    }
  end,
}
