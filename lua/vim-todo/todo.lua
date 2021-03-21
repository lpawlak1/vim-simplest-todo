local border_chars = {
    TOP_LEFT = '┌',
    TOP_RIGHT = '┐',
    MID_HORIZONTAL = '─',
    MID_VERTICAL = '│',
    BOTTOM_LEFT = '└',
    BOTTOM_RIGHT = '┘',
}

local function get_checked()
    return '[' .. vim.g['todo#done'] .. ']'
end

local function get_unchecked()
    return '[' .. vim.g['todo#undone'] .. ']'
end

done_mark = vim.g['todo#done']
undone_mark = vim.g['todo#undone']

local function select_callback(index, line)
    -- funciton job here
end

local function close_callback(index, line)
    print('Todos closed')
end

local function check(popup)
    index, line = popup:get_current_selection()
    change=""
    if string.find(line,get_checked(),1,true) then
        line = string.gsub(line,done_mark,undone_mark,1)

        change = "Changed " .. index .. " line to undone."
    else
        line = string.gsub(line,undone_mark,done_mark,1)

        change = "Changed " .. index .. " line to done."
    end
    popup.list:renameElement(index,line)
    print(change)
end

local function get_data()
    data ={}
    f= io.open(vim.g.SourceFolder .. "todo.md")
    new = true
    new_checked=false
    str=''
    for line in f:lines() do
        if new == true then
            new = false
            if line == '1'then
                new_checked = true
                str = get_checked()
            else
                str = get_unchecked()
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

local function save()
    vim.cmd('silent w! ' .. vim.g.SourceFolder .. 'tod.md')
    vim.cmd('silent ! echo "' .. vim.g['todo#done'] .. '\\n' .. vim.g['todo#undone'] .. '" > ' .. vim.g.SourceFolder .. 'marks.md')
    vim.cmd('silent ! cd ' .. vim.g.SourceFolder .. ' && ' .. vim.g.SourceFolder .. 'saveFile')
end

local function rename(popup)
    index, line = popup:get_current_selection()
    end_index = line:find("|",1)
    vim.g.input_message="Give the name of renamed todo item. Enter q to cancel: "
    name = vim.fn['todo#input'](line:sub(end_index+2)) 
    while name == '' do
        name = vim.fn['todo#input']() 
    end
    if name == 'q' or name=='Q' then
        return
    end
    if string.find(line,get_checked(),1,true) then
        line = get_checked() .. " " .. os.date("%d/%m/%y, %H:%M| ") .. name
    else
        line = get_unchecked() .. " " .. os.date("%d/%m/%y, %H:%M| ") .. name
    end
    popup.list:renameElement(index,line)
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
                save()
                popup:close(close_callback)
            end,
            ['<Esc>'] = function(popup)
                save()
                popup:close(close_callback)
            end,
            ['<CR>'] = function(popup)
                check(popup)
            end,
            ['d'] = function(popup)
                index, line = popup:get_current_selection()
                popup.list:clearElement(index)
            end,
            ['r'] = function(popup)
                rename(popup)
            end,
            ['a'] = function(popup)
                index, line = popup:get_current_selection()
                vim.g.input_message="Give the name of new todo item, send q to escape: "
                name = vim.fn['todo#input']('') 
                while name == '' do
                    name = vim.fn['todo#input']() 
                end
                if name == 'q' or name=='Q' then
                    return
                end
                popup.list:addData({get_unchecked() .. " " .. os.date("%d/%m/%y, %H:%M| ") .. name})
            end,
            ['i'] = function(popup)
                index, line = popup:get_current_selection()
            end,
            ['tt'] = function(popup)
                index, line = popup:get_current_selection()
                end_index = line:find("|",1)
                print(end_index)
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
