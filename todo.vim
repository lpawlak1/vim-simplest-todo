let g:SourceTodo='/home/lukas/todo/todo.md'
function! OpenTodo()
    
    call 'vs ' join(g:SourceTodo)
    setlocal noma
    echo 'done'
    "setlocal ma
endfunction
