local border_chars = {
    TOP_LEFT = '┌',
    TOP_RIGHT = '┐',
    MID_HORIZONTAL = '─',
    MID_VERTICAL = '│',
    BOTTOM_LEFT = '└',
    BOTTOM_RIGHT = '┘',
}

-- fields with marks for checked and unchecked element
done_mark = vim.g['todo#done']
undone_mark = vim.g['todo#undone']


-- gets the [mark] 
local function get_checked()
    return '[' .. done_mark .. ']'
end

-- gets the [mark] 
local function get_unchecked()
    return '[' .. undone_mark .. ']'
end

-- input handler in lua for making new Todo elem
-- It uses input function from ./plugin/todo.vim file
local function get_new_todo_input()
    vim.g.input_message="Give the name of new todo item, send q to escape: "
    name = vim.fn['todo#input']('') 
    while name == '' do
        name = vim.fn['todo#input']() 
    end
    if name == 'q' or name=='Q' then
        return
    end
    return name
end

-- callbacks for changing selection and closed list
local function select_callback(index, line)
    -- funciton job here
end

local function close_callback(index, line)
    print('Todos closed')
end

-- changes the state of todo element by using internal (popfix) list element
-- looks for [mark] and changes it
local function check(data)
    local popup = data.popup
    index, line = popup:get_current_selection()
    change=""
    if string.find(line,get_checked(),1,true) then
        line = string.gsub(line,done_mark,undone_mark,1)

        change = "Changed " .. index .. " line to undone."
    else
        line = string.gsub(line,undone_mark,done_mark,1)

        change = "Changed " .. index .. " line to done."
    end
    renameElement({line = line, popup = popup,index=index})
    print(change)
end

-- It's used on startup, opens file with lua and uses custom format to get todo
-- Format is:
-- First line is 1 or 0 for checked or unchecked
-- Second line is todo data represented by date(D) and line with name (N):
--  D | N
--  This format is needed for rename function
local function get_data()
    data ={}
    f= io.open(vim.g.SourceFolder .. "todo.md")
    new = true
    new_checked=false
    str=''
    for line in f:lines() do
        if new == true then
            new = false
            if line == '1' then
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

-- Saves file as follows:
-- 1. saves opened buffer with todo's to temporary tod.md file
-- 2. saves marks to file named marks.md, as they can be changed from sesh to sesh
-- 3. executes saveFile precompiled script which changes tod.md raw data to custom format.
-- 4. Uses external handler for closing buffer
local function save(popup)
    vim.cmd('silent w! ' .. vim.g.SourceFolder .. 'tod.md')
    vim.cmd('silent ! echo "' .. vim.g['todo#done'] .. '\\n' .. vim.g['todo#undone'] .. '" > ' .. vim.g.SourceFolder .. 'marks.md')
    vim.cmd('silent ! cd ' .. vim.g.SourceFolder .. ' && ' .. vim.g.SourceFolder .. 'saveFile')
    popup:close(close_callback)
end


-- Deletes an element that is under cursor.
local function clearElement(popup)
    index,line = popup:get_current_selection()
    local buf = vim.api.nvim_get_current_buf()

    index = index-1
    if index < 0 or index > popup.list.numData then return end

    local start = index
    local ending = -1
    if index + 1 ~= popup.list.numData then 
        ending = index+1
    end

    if vim.api.nvim_buf_is_loaded(buf) then
        vim.api.nvim_buf_set_option(buf, 'modifiable', true)
        vim.api.nvim_buf_set_lines(buf, start, ending, true, {})
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    end
    popup.list.numData  = popup.list.numData - 1
end

-- Renames todo item from under cursor
-- Data is {popup,line} where line is string to which line should be changed
-- if no line is present input is used to get desired new name 
-- It occours when you `check` item in list
-- It uses input function from ./plugin/todo.vim file
-- Message of the input is specified in vim.g.input_messsage
function renameElement(data)
    local popup = data.popup
    local buf = vim.api.nvim_get_current_buf()

    if data.line == nil then
        index, line = popup:get_current_selection()
        end_index = line:find("|",1)
        vim.g.input_message="Give the name of renamed todo item. Enter q to cancel: "
        name = vim.fn['todo#input'](line:sub(end_index+2)) 
        while name == '' do
            name = vim.fn['todo#input'](line:sub(end_index+2)) 
        end
        if name == 'q' or name=='Q' then
            return
        end
        if string.find(line,get_checked(),1,true) then
            data.line = get_checked() .. " " .. os.date("%d/%m/%y, %H:%M| ") .. name
        else
            data.line = get_unchecked() .. " " .. os.date("%d/%m/%y, %H:%M| ") .. name
        end
    end
    line = data.line

    index = index - 1
    if index < 0 or index > popup.list.numData then return end

    local ending = -1
    if index + 1 ~= popup.list.numData then 
        ending = index+1
    end

    local start = index
    if vim.api.nvim_buf_is_loaded(buf) then
        vim.api.nvim_buf_set_option(buf, 'modifiable', true)
        vim.api.nvim_buf_set_lines(buf, start, ending, true, {line})
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    end
end

-- Function used to append or insert data to buffer
-- param data is {popup,index} where index is line where to put new element
-- if no index is present index is taken from under cursor and added after it
local function add(data)
    local buf = vim.api.nvim_get_current_buf()
    local index = data.index
    local popup = data.popup
    if index == nil then index, line = popup:get_current_selection() end

    name = get_new_todo_input()
    if name == nil then print("Cancelled") return end

    line = {get_unchecked() .. os.date(" %d/%m/%y, %H:%M| ") .. name}

    if vim.api.nvim_buf_is_loaded(buf) then
        vim.api.nvim_buf_set_option(buf, 'modifiable', true)
        vim.api.nvim_buf_set_lines(buf,index,index,true,line) 
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    end

    popup.list.numData  = popup.list.numData + 1
end

local opts = {
    height = vim.g['todo#height'],
    width = vim.g['todo#width'],
    mode = 'editor',
    close_on_bufleave = true,
    data = get_data(), 
    keymaps = {
        n = {
            [vim.g['todo#quit']] = function(popup) save(popup) end,
            [vim.g['todo#quit2']] = function(popup) save(popup) end,
            [vim.g['todo#check']] =function(popup) check({popup=popup}) end,
            [vim.g['todo#delete']] =function(popup) clearElement(popup) end,
            [vim.g['todo#rename']] =function(popup) renameElement({popup= popup}) end,
            [vim.g['todo#addAtLast']] = function(popup) add({popup = popup,index = -1}) end,
            [vim.g['todo#add']] = function(popup) add({popup = popup}) end,
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
