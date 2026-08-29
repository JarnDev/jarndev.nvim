return {
  'sphamba/smear-cursor.nvim',
  event = 'VeryLazy',
  opts = {
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,
    -- The dashboard and terminal repaint constantly; smearing there just looks noisy.
    filetypes_disabled = { 'snacks_dashboard' },
  },
}
