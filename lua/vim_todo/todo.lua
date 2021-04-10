local api = vim.api
local M = {}

-- settings loading
require'vim_todo.sett'

-- callbacks for changing selection and closed list
function select_callback(index, line)
    -- funciton job here
end

function close_callback(index, line)
    print('Todos closed')
end

local list_api = require'vim_todo.api_todo'
list_api:new()

function get_height()
    return math.ceil((vim.api.nvim_win_get_height(vim.api.nvim_get_current_win)-8)*0.9)
end
function get_width()
    return math.ceil((vim.api.nvim_win_get_width(vim.api.nvim_get_current_win)-8)*0.8)
end

local opts = {
    height = vim.g['todo#height'] or get_height(),
    width = vim.g['todo#width'] or get_width(),
    mode = 'editor',
    close_on_bufleave = true,
    data = list_api:get_data(), 
    keymaps = {
        n = {
            [vim.g['todo#quit']] = function(popup) list_api:save() end,
            [vim.g['todo#quit2']] = function(popup) list_api:save() end,
            [vim.g['todo#check']] =function(popup) list_api:check() end,
            [vim.g['todo#delete']] =function(popup) list_api:clearElement() end,
            [vim.g['todo#rename']] =function(popup) list_api:renameElement() end,
            [vim.g['todo#addAtLast']] = function(popup) list_api:addElem({index = -1}) end,
            [vim.g['todo#add']] = function(popup) list_api:addElem({popup = popup}) end,
        }
    },
    callbacks = {
        select = select_callback, -- automatically calls it when selection changes
        close = close_callback, -- automatically calls it when window closes.
    },
    list = {
        border = true,
        numbering = true,
        title = 'Todos',
    },
}


local popup = require'popfix':new(opts)
list_api:addPopup(popup)

return M
