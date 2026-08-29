-- Context-aware `commentstring` for Neovim's builtin `gc`/`gcc`. Without it, commenting
-- inside JSX emits `// ...` instead of `{/* ... */}` -- the same applies to embedded
-- languages generally (vue/svelte/html script+style blocks).
return {
  'folke/ts-comments.nvim',
  event = 'VeryLazy',
  opts = {},
}
