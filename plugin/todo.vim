let g:SourceTodo=expand('<sfile>:p')[:-16] .'todo.md'
let g:SourceFolder=expand('<sfile>:p')[:-16]
let g:todo#done='✓'
let g:todo#undone='✗'
let g:todo#enable=1
if (g:todo#enable == 1)
    silent execute "! if [ -f " . g:SourceTodo . " ]; then echo 'Already Exists'; else touch " . g:SourceTodo . "; echo 'Created'; fi"
    nnoremap <leader>o :call todo#OpenTodo()<CR>
endif
function todo#OpenTodo()
    if g:todo#enable
        execute 'vs ' g:SourceTodo
        setlocal noma
        setf Todo-list
        setlocal statusline=%y      "filetype
    endif
endfunction

function todo#CheckBuffer()
    if (&ft == 'Todo-list')
        return '1'
    endif
    echo 'Wrong buffer'
    return '0'
endfunction
function todo#GetDoneMark()
    return '[' . g:todo#done . '] '
endfunction
function todo#GetUnDoneMark()
    return '[' . g:todo#undone . '] '
endfunction

function todo#AddNewTodo()
    if (todo#CheckBuffer())
        let s:NewTodo = input("Name new todo: ")
        if (len(s:NewTodo) == 0)
            echo 'Error. Name is empty'
            return ''
        endif
        setlocal ma
        silent call append(line('.'), todo#GetUnDoneMark . s:NewTodo)
        silent w
        setlocal noma
    endif
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

function todo#DeleteTodo()
    if (todo#CheckBuffer())
        setlocal ma
        let item = getline('.')[7:-1]
        silent .,.d
        silent w
        setlocal noma
        echo 'Deleted \"' . item . '\"'
    endif
endfunction

function todo#FixFile()
    if (todo#CheckBuffer())
        silent wq
        silent execute "! cd " . g:SourceFolder . "; ./checkFile.sh"
        silent call todo#OpenTodo()
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
        silent call append(line('.'), todo#GetUnDoneMark() . '0')
        silent call append(line('.'), todo#GetUnDoneMark() . '1')
        silent call append(line('.'), todo#GetUnDoneMark() . '2')
        silent call append(line('.'), todo#GetUnDoneMark() . '3')
        silent call append(line('.'), todo#GetUnDoneMark() . '4')
    setlocal noma
endfunction
function todo#deltetet()
    lines=getbufline(bufnr('%'),1,line('$'))
    i=0
    for s in lines
        i=i+1
        "todo here
        //here
        if (s =~ todo#GetDoneMark()) && (s =~ todo#GetUnDoneMark())
            silent call setline(line(i),'')
        endif
    endfor
    silent w
endfunction

"custom mapping for this filetype
autocmd FileType Todo-list call SetTodoOptions() 
function SetTodoOptions()
    nnoremap <buffer> q :wq<CR>
    nnoremap <buffer> <leader>q :wq<CR>

    nnoremap <buffer> ;a :call todo#AddNewTodo()<CR>
    nnoremap <buffer> ;x :call todo#CheckTodo()<CR>
    nnoremap <buffer> ;d :call todo#DeleteTodo()<CR>
    nnoremap <buffer> ;r :call todo#DeleteDone()<CR>
    nnoremap <buffer> ;e :call todo#RenameElement()<CR>
    nnoremap <buffer> ;u :call todo#Undo()<CR>
endfunction