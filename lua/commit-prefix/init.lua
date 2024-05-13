---@mod commit-prefix.nvim Insert prefix on commit message
local M = {}

local api = vim.api

local default_config = {
    prefix_match = '%w+-%d+', -- JIRA ticket (PRJ-1234), for more info about matching: https://www.lua.org/pil/20.2.html
    enter_insert_mode = true, -- Enter insert mode
}

local function is_gitcommit(buf)
    return api.nvim_buf_get_option(buf, 'filetype') == 'gitcommit'
end

local function get_branch(buf)
    local on_branch_line_index = vim.fn.search('# On branch', 'n')
    if on_branch_line_index == 0 then
        return nil
    end
    local on_branch = api.nvim_buf_get_lines(buf, on_branch_line_index - 1, on_branch_line_index, true)[1]

    return string.gsub(on_branch, '# On branch', '')
end

---@param config table user config
---@usage [[
---require('commit-prefix').setup {
---    prefix_match = '%w+-%d+', -- JIRA ticket (PRJ-1234), for more info about matching: https://www.lua.org/pil/20.2.html
---    enter_insert_mode = true, -- Enter insert mode
---}
---@usage ]]
M.setup = function(config)
    config = config or {}
    config = vim.tbl_deep_extend('keep', config, default_config)

    api.nvim_create_autocmd('BufWinEnter', {
        callback = function(events)
            if not is_gitcommit(events.buf) then
                return
            end

            local first_line = api.nvim_buf_get_lines(events.buf, 0, 1, true)[1]
            if first_line ~= '' then
                return -- Dont insert prefix to commits with text (amend)
            end

            local branch = get_branch(events.buf)
            local prefix = branch:match(config.prefix_match)
            if prefix then
                api.nvim_buf_set_lines(events.buf, 0, 1, true, { prefix .. ' ' })
            end

            if config.enter_insert_mode then
                -- Enter insert mode at EOL
                vim.schedule(function ()
                    api.nvim_feedkeys('A', 'n', false)
                end)
            end
        end
    })

    -- Abort saving empty commit messages
    api.nvim_create_autocmd('BufUnload', {
        callback = function(events)
            if not events.buf then
                return
            end

            if not is_gitcommit(events.buf) then
                return
            end

            local branch = get_branch(events.buf)
            if branch == nil then
                return
            end
            local prefix = branch:match(config.prefix_match)
            if not prefix then
                return
            end

            -- If the commit line contains only the prefix, remove all the text to abort the commit
            local first_line = api.nvim_buf_get_lines(events.buf, 0, 1, true)[1]
            if first_line == prefix .. ' ' then
                api.nvim_buf_set_lines(events.buf, 0, 1, true, { '' })
                vim.cmd("silent! write")
            end
        end
    })
end

return M
