local api = vim.api
local list_api = {}
function list_api:new(opts)
    self.__index = self
    local obj = {}
    setmetatable(obj,self)
    self.opts = opts
end

function list_api:addPopup(popup)
    self.popup = popup
    self.buf = api.nvim_get_current_buf()
end


-- Function used to append or insert data to buffer
-- param data is {popup,index} where index is line where to put new element
-- if no index is present index is taken from under cursor and added after it
function list_api:addElem(data)
    local buf = self.buf
    if data == nil then data = {} end
    local index = data.index
    local popup = self.popup

    if index == nil then index, line = popup:get_current_selection() end

    if data.change then index = index + data.change end

    name = self:get_new_todo_input()
    if name == nil then print("Cancelled") return end

    line = {self:get_unchecked() .. os.date(" %d/%m/%y, %H:%M| ") .. name}

    if api.nvim_buf_is_loaded(buf) then
        api.nvim_buf_set_option(buf, 'modifiable', true)
        api.nvim_buf_set_lines(buf,index,index,true,line) 
        api.nvim_buf_set_option(buf, 'modifiable', false)
    end

    popup.list.numData  = popup.list.numData + 1
end
-- gets the [mark] 
function list_api:get_checked()
    return '[' .. vim.g['todo#done'] .. ']'
end

-- gets the [mark] 
function list_api:get_unchecked()
    return '[' .. vim.g['todo#undone'] .. ']'
end

-- input handler in lua for making new Todo elem
-- It uses input function from ./plugin/todo.vim file
function list_api:get_new_todo_input()
    vim.g.input_message="Give the name of new todo item, send q to escape: "
    str = vim.fn['todo#input']('') 
    while str == '' do
        str = vim.fn['todo#input']() 
    end
    if str == 'q' or str=='Q' then
        return
    end
    return str
end


-- changes the state of todo element using internal rename element method.
-- looks for [mark] and changes it
function list_api:check(data)
    local popup = self.popup
    index, line = popup:get_current_selection()
    change=""
    if string.find(line,self:get_checked(),1,true) then
        line = string.gsub(line,vim.g['todo#done'],vim.g['todo#undone'],1)

        change = "Changed " .. index .. " line to undone."
    else
        line = string.gsub(line,vim.g['todo#undone'],vim.g['todo#done'],1)

        change = "Changed " .. index .. " line to done."
    end
    self:renameElement({line = line,index=index})
    print(change)
end

-- It's used on startup, opens file with lua and uses custom format to get todo
-- Format is:
-- First line is 1 or 0 for checked or unchecked
-- Second line is todo data represented by date(D) and line with name (N):
--  D | N
--  This format is needed for rename function
function list_api:get_data()
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
                str = self:get_checked()
            else
                str = self:get_unchecked()
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
function list_api:save()
    vim.g.input_message="Do you want to save [Y/n]: "
    name = vim.fn['todo#input']('') 
    if name == 'n' or name=='N' then
        self.popup:close(close_callback)
        return
    end
    vim.cmd('silent w! ' .. vim.g.SourceFolder .. 'tod.md')
    vim.cmd('silent ! echo "' .. vim.g['todo#done'] .. '\\n' .. vim.g['todo#undone'] .. '" > ' .. vim.g.SourceFolder .. 'marks.md')
    vim.cmd('silent ! cd ' .. vim.g.SourceFolder .. ' && ' .. vim.g.SourceFolder .. 'saveFile')
    self.popup:close(close_callback)
end


-- Deletes an element that is under cursor.
function list_api:clearElement()
    vim.g.input_message="Do you want to save [y/N]: "
    name = vim.fn['todo#input']('') 
    if name == 'n' or name=='N' or name=='' then
        return
    end
    local popup = self.popup
    local index,line = popup:get_current_selection()
    local buf = self.buf

    index = index-1
    if index < 0 or index > popup.list.numData then return end

    local start = index
    local ending = -1
    if index + 1 ~= popup.list.numData then 
        ending = index+1
    end

    if api.nvim_buf_is_loaded(buf) then
        api.nvim_buf_set_option(buf, 'modifiable', true)
        api.nvim_buf_set_lines(buf, start, ending, true, {})
        api.nvim_buf_set_option(buf, 'modifiable', false)
    end
    popup.list.numData  = popup.list.numData - 1
end

-- Renames todo item from under cursor
-- Data is {line} where line is string to which line should be changed
-- Message of the input is specified in vim.g.input_messsage
function list_api:renameElement(data)
    local popup = self.popup
    local buf = self.buf
    if data == nil then data = {} end

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
        if string.find(line,self:get_checked(),1,true) then
            data.line = self:get_checked() .. " " .. os.date("%d/%m/%y, %H:%M| ") .. name
        else
            data.line = self:get_unchecked() .. " " .. os.date("%d/%m/%y, %H:%M| ") .. name
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
    if api.nvim_buf_is_loaded(buf) then
        api.nvim_buf_set_option(buf, 'modifiable', true)
        api.nvim_buf_set_lines(buf, start, ending, true, {line})
        api.nvim_buf_set_option(buf, 'modifiable', false)
    end
end

return list_api
