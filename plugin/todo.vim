let g:SourceTodo=expand('<sfile>:p')[:-16] .'/todo.md'
let g:todo#done='✅'
let g:todo#undone='❎'
nnoremap <leader>o :call todo#OpenTodo()<CR>
function todo#OpenTodo()
    execute 'vs ' g:SourceTodo
    setlocal noma
    setf Todo-list
    " Formats the statusline
    setlocal statusline=%y      "filetype
endfunction

function todo#AddNewTodo()
    if (g:SourceTodo =~ expand('%:p'))
        return ''
    endif
    let s:NewTodo = input("Name new todo: ")
    if (len(s:NewTodo) == 0)
        echo 'Error. Name is empty'
        return ''
    endif
    setlocal ma
    call append(line('.'), '[' . g:todo#undone . '] ' . s:NewTodo)
    setlocal noma
endfunction

function todo#CheckTodo()
    let line=getline('.')
    if (line =~ g:todo#undone)
        setlocal ma
        call setline('.',substitute(line,g:todo#undone,g:todo#done,'g'))
        setlocal noma
    elseif (line =~ g:todo#done)
        setlocal ma
        call setline('.',substitute(line,g:todo#done,g:todo#undone,'g'))
        setlocal noma
    else
        echo 'Something wrong with file'
    endif
endfunction

function todo#DeleteTodo()
    setlocal ma
    let item = getline('.')[7:-1]
    .,.d
    setlocal noma
    echo 'Deleted \"' . item . '\"'
endfunction

function todo#populate()
    setlocal ma
        call append(line('.'), '[' . g:todo#undone . '] ' . '0')
        call append(line('.'), '[' . g:todo#undone . '] ' . '1')
        call append(line('.'), '[' . g:todo#undone . '] ' . '2')
        call append(line('.'), '[' . g:todo#undone . '] ' . '3')
        call append(line('.'), '[' . g:todo#undone . '] ' . '4')
    setlocal noma
endfunction


"custom mapping for this filetype
autocmd FileType Todo-list call SetTodoOptions() 
function SetTodoOptions()
    nnoremap <buffer> q :wq<CR>
    nnoremap <buffer> <leader>q :wq<CR>
    nnoremap <buffer> a :call todo#AddNewTodo()<CR>
    nnoremap <buffer> x :call todo#CheckTodo()<CR>
    nnoremap <buffer> v :echo 'Visual mode is disabled here.'<CR>
    nnoremap <buffer> i :echo 'Insert mode is disabled here'<CR>
    nnoremap <buffer> d :call todo#DeleteTodo()<CR>
endfunction
" for future changes
" if [ -f ~/.config/nvim/plugged/vim-simplest-todo/todo.md ]; then echo "aaaa"; fi