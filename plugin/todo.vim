let g:SourceFolder=expand('<sfile>:p')[:-16]

if (!exists("g:todo#enable"))
    let g:todo#enable=1
endif

if (g:todo#enable == 1)
    silent execute "! if [ -f " . g:SourceFolder .'todo.md' . " ]; then echo 'Already Exists'; else touch " . g:SourceFolder . 'todo.md' . "; echo 'Created'; fi"
    silent execute "! if [ -f " . g:SourceFolder .'tod.md' . " ]; then echo 'Already Exists'; else touch " . g:SourceFolder . 'tod.md' . "; echo 'Created'; fi"
    let str = g:SourceFolder . "lua/vim_todo/todo.lua"
    nnoremap <expr> <leader>o ':silent luafile '. str . '<CR>'
endif

function todo#input(prompt)
    let s:strr = input(g:input_message,a:prompt)
    if (len(s:strr) == 0)
        echo 'Error. Empty input'
        return ''
    endif
    return s:strr
endfunction

" Used for development only for populating sample data into buffer
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

