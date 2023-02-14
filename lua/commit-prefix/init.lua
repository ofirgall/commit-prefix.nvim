---@mod commit-prefix.nvim Insert prefix on commit message
local M = {}

local api = vim.api

local default_config = {
    prefix_match = '%w+-%d+', -- JIRA ticket (PRJ-1234), for more info about matching: https://www.lua.org/pil/20.2.html
    enter_insert_mode = true, -- Enter insert mode
}

---@param config table user config
---@usage [[
---@usage ]]
M.setup = function(config)
    config = config or {}
    config = vim.tbl_deep_extend('keep', config, default_config)

    api.nvim_create_autocmd('BufWinEnter', {
        callback = function(events)
            local ft = api.nvim_buf_get_option(events.buf, 'filetype')
            if ft ~= 'gitcommit' then
                return
            end

            local first_line = api.nvim_buf_get_lines(events.buf, 0, 1, true)[1]
            if first_line ~= '' then
                return -- Dont insert prefix to commits with text (amend)
            end

            local on_branch_line_index = vim.fn.search('# On branch', 'n')
            local on_branch = api.nvim_buf_get_lines(events.buf, on_branch_line_index - 1, on_branch_line_index, true)
                [1]
            local branch = string.gsub(on_branch, '# On branch', '')
            local ticket_num = branch:match(config.prefix_match)

            if ticket_num then
                api.nvim_buf_set_lines(events.buf, 0, 1, true, { ticket_num .. ' ' })
            end

            if config.enter_insert_mode then
                -- Enter insert mode at EOL
                api.nvim_feedkeys('A', 'n', false)
            end
        end
    })
end

return M
