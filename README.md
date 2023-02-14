# commit-prefix.nvim
Insert prefix to commit message by branch name (JIRA ticket for example)
TODO: insert demo
TODO: why not git hook

## Installation
```lua
use 'ofirgall/commit-prefix.nvim'
```

## Usage
```lua
-- Leave empty for default values
require('commit-prefix').setup {
    prefix_match = '%w+-%d+', -- JIRA ticket (PRJ-1234), for more info about matching: https://www.lua.org/pil/20.2.html
    enter_insert_mode = true, -- Enter insert mode
}
```
