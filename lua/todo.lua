local border_chars = {
	TOP_LEFT = '┌',
	TOP_RIGHT = '┐',
	MID_HORIZONTAL = '─',
	MID_VERTICAL = '│',
	BOTTOM_LEFT = '└',
	BOTTOM_RIGHT = '┘',
}

local function select_callback(index, line)
    -- funciton job here
end

local function close_callback(index, line)
    -- wczytac linie
    -- przejsc po nich
    -- zapisac calosc do pliku
    -- zapis i przejscie w asyncu jak sie da :)
end
local function check(index, line)
    print(index, line, 'lkjlkjlkj')
end
function DeepPrint (e)
    --if e is a table, we should iterate over its elements
    if type(e) == "table" then
        for k,v in pairs(e) do -- for every element in the table
            print(k)
            DeepPrint(v)       -- recursively repeat the same procedure
        end
    else -- if not, we can just print it
        print(e)
    end
end
-- let g:todo#done='✓'
--   1 let g:todo#undone='✗'
local function get_data()
    data ={}
    f= io.open(vim.g.SourceTodo)
    new = true
    new_checked=false
    str=''
    for line in f:lines() do
        if new == true then
            new = false
            if line == '1'then
                new_checked = true
                str = '[' .. vim.g['todo#done'] .. ']'
            else
                str = '[' .. vim.g['todo#undone'] .. ']'
                new_checked = false
            end
        else
            new = true
            str = str .. line
            table.insert(data, str)
        end
    end
    f:close()
    return data
end

local opts = {
	height = 40,
	width = 80,
	mode = 'editor',
	close_on_bufleave = true,
	data = get_data(), 
	keymaps = {
		n = {
            ['q'] = function(popup)
                vim.cmd('silent w! ' .. vim.g.SourceFolder .. 'tod.md')
                vim.cmd('silent ! echo "' .. vim.g['todo#done'] .. '\\n' .. vim.g['todo#undone'] .. '" > ' .. vim.g.SourceFolder .. 'marks.md')
                vim.cmd('silent ! cd ' .. vim.g.SourceFolder .. ' && ' .. vim.g.SourceFolder .. 'saveFile')
                popup:close(close_callback)
            end,
            ['<CR>'] = function(popup)
                index, line = popup:get_current_selection()
                check(index, line)
            end,
            ['d'] = function(popup)
                vim.cmd("set ma")
                vim.api.nvim_del_current_line()
                vim.cmd("set noma")
            end,
            ['r'] = function(popup)
                index, line = popup:get_current_selection()
            end,
            ['a'] = function(popup)
                index, line = popup:get_current_selection()
                vim.api.nvim_command('call todo#AddNewTodoLua()')
                -- TODO if return true ^ then add 1 to list:data in lua
            end,
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
		border_chars = border_chars,
		highlight = 'Normal',
		selection_highlight = 'Visual',
	},
}

local popup = require'popfix':new(opts)
