function loade()
    vim.g['todo#done'] = '✓'
    vim.g['todo#undone'] = '✗'
    vim.g['todo#quit'] = 'q'
    vim.g['todo#quit2'] = '<Esc>'
    vim.g['todo#check'] = '<CR>'
    vim.g['todo#delete'] = 'd'
    vim.g['todo#rename'] = 'r'
    vim.g['todo#add'] = 'a'
    vim.g['todo#addAtLast'] = 'A'
    vim.g['todo#insertBefore'] = 'i'
    vim.g['todo#insertAtBeg'] = 'I'

    -- vim.g['todo#height'] = 25
    -- vim.g['todo#width'] = 60
end

loade()
