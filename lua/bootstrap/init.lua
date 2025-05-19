-- Bootstrap configuration
-- This file loads all bootstrap settings in the correct order

-- Load core settings first (leader key, etc.)
require('bootstrap.core')

-- Load UI settings (Nerd Font, etc.)
require('bootstrap.ui')

-- Load editor settings (termguicolors, etc.)
require('bootstrap.editor')

-- Return the module
return {} 