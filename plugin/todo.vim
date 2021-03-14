let g:SourceTodo=expand('<sfile>:p')[:-16] .'todo.md'
let g:SourceFolder=expand('<sfile>:p')[:-16]
let g:SourceTodTemp=g:SourceFolder . 'tod.md'
let g:todo#done='✓'
let g:todo#undone='✗'
let g:todo#enable=1

if (g:todo#enable == 1)
    silent execute "! if [ -f " . g:SourceTodo . " ]; then echo 'Already Exists'; else touch " . g:SourceTodo . "; echo 'Created'; fi"
    let str = g:SourceFolder . "lua/todo.lua"
    nnoremap <expr> <leader>o ':luafile'. str . '<CR>'
endif

function todo#GetDoneMark()
    return '[' . g:todo#done . '] '
endfunction

function todo#GetUnDoneMark()
    return '[' . g:todo#undone . '] '
endfunction

function todo#AddNewTodoLua()
    let s:NewTodo = input("Name new todo: ")
    if (len(s:NewTodo) == 0)
        echo 'Error. Name is empty'
        return ''
    endif
    setlocal ma
    silent call append(line('.'), todo#GetUnDoneMark() . s:NewTodo)
    setlocal noma
endfunction

function todo#CheckTodo()
    if (todo#CheckBuffer())
        let line=getline('.')
        if (line =~ g:todo#undone)
            setlocal ma
            silent call setline('.',substitute(line,g:todo#undone,g:todo#done,'g'))
            silent w
            setlocal noma
        elseif (line =~ g:todo#done)
            setlocal ma
            silent call setline('.',substitute(line,g:todo#done,g:todo#undone,'g'))
            silent w
            setlocal noma
        else
            echo 'Something wrong with file'
        endif
    endif
endfunction

function todo#DeleteDone()
    if (todo#CheckBuffer())
        silent wq
        silent execute "! cd " . g:SourceFolder . "; ./deleteDone.sh"
        silent call todo#OpenTodo()
    endif
endfunction

function todo#RenameElement()
    if (todo#CheckBuffer())
        let line = input('New name: ', substitute(getline('.'), '[.\] ', '', 'g'))
        setlocal ma
        silent call setline(line('.'), todo#GetUnDoneMark() . line)
        silent w
        setlocal noma
    endif
endfunction

function todo#populate()
    setlocal ma
        silent call append(line('.'), '0')
        silent call append(line('.'), 'q')
        silent call append(line('.'), '1')
        silent call append(line('.'), 'w')
        silent call append(line('.'), '0')
        silent call append(line('.'), 'e')
        silent call append(line('.'), '1')
        silent call append(line('.'), 'r')
        silent call append(line('.'), '0')
        silent call append(line('.'), 't')
        silent call append(line('.'), '1')
        silent call append(line('.'), 'y')
    setlocal noma
endfunction

