" Very Important Buffers <veryimportantbuffers.vim>
"
" Script Info and Documentation  {{{
"=============================================================================
"	  Very Important Buffers
"	  Copyright (C) 2014 Andrea Bonomi
"
"	  Based on Mini Buffer Explorer 
"     Copyright: Copyright (C) 2002 & 2003 Bindu Wavell
"                Copyright (C) 2010 Oliver Uvman
"                Copyright (C) 2010 Danielle Church
"                Copyright (C) 2010 Stephan Sokolow
"                Copyright (C) 2010 & 2011 Federico Holgado
"                Permission is hereby granted to use and distribute this code,
"                with or without modifications, provided that this copyright
"                notice is copied with it. Like anything else that's free,
"                vib.vim is provided *as is* and comes with no
"                warranty of any kind, either expressed or implied. In no
"                event will the copyright holder be liable for any damamges
"                resulting from the use of this software.
"
"  Name Of File: vib.vim
"   Description: Very Important Buffers Vim Plugin
" Documentation: See vib.txt
"
"=============================================================================
" }}}
"
" Startup Check
"
" Has this plugin already been loaded? {{{
"
if exists('loaded_veryimportantbuffers')
    finish
endif
let loaded_veryimportantbuffers = 1

" }}}
"
" Mappings and Commands
"
" VIB commands {{{
"
"
if !exists(':VIBn')
    command! VIBn call <SID>CycleBuffer(1)
endif
if !exists(':VIBp')
    command! VIBp call <SID>CycleBuffer(0)
endif
if !exists(':VIBls')
    command! VIBls call <SID>VIBls()
endif
if !exists(':VIBAdd')
    command! VIBAdd call <SID>VIBAdd()
endif
if !exists(':VIBRemove')
    command! VIBRemove call <SID>VIBRemove()
endif
if !exists(':VIBAddAll')
    command! VIBAddAll call <SID>VIBAddAll()
endif
if !exists(':VIBRemoveAll')
    command! VIBRemoveAll call <SID>VIBRemoveAll()
endif
if !exists(':VIBToggle')
    command! VIBToggle call <SID>VIBToggle()
endif
if !exists(':VIBFocus')
    command! VIBFocus call <SID>FocusExplorer()
endif
if !exists(':VIBOpen')
    command! VIBOpen let t:skipEligibleBuffersCheck = 1 | call <SID>StartExplorer()
endif
if !exists(':VIBClose')
    command! VIBClose let t:skipEligibleBuffersCheck = 0 | call <SID>StopExplorer()
endif
if !exists(':VIBToggleExplorer')
    command! VIBToggleExplorer call <SID>ToggleExplorer()
endif

" }}}
"
" Global Configuration Variables
"
" Start VIB Explorer automatically ? {{{
"
if !exists('g:vibExplAutoStart')
    let g:vibExplAutoStart = 1
endif

" VIBList - Show the VIB list {{{
"
function! <SID>VIBls()
    let l:curBuf = bufnr('%')
    let l:prevBuf = bufnr('#')
    " for l:buf in range(1, bufnr('$'))
    for l:buf in t:VIBList
        if bufexists(l:buf)
            let l:bufName = expand("#" . l:buf . ":p")
            " If the buffer is modified then mark it
            let l:mode = ""
            if l:buf == curBuf
                let l:mode .= '%'
            else
                if l:buf == prevBuf
                    let l:mode .= '#'
                else
                    let l:mode .= ' '
                endif
            endif
            if getbufvar(l:buf, '&modifiable') == 0
                let l:mode .= '-'
            else
                if getbufvar(l:buf, '&readonly') == 1
                    let l:mode .= '='
                else
                    let l:mode .= ' '
                endif
            endif
            if getbufvar(l:buf, '&modified') == 1
                let l:mode .= '+'
            else
                let l:mode .= ' '
            endif
            echo printf("%3d %s \"%s\"\n", l:buf, l:mode, l:bufName)
        endif
    endfor
endfunction

" }}}
" VIBAddBuf - Add a buffer to the VIB list {{{
"
function! <SID>VIBAddBuf(buf)
    if index(t:VIBList, a:buf) < 0
        call add(t:VIBList, a:buf)
    endif
    call <SID>AutoUpdate(bufnr("%"),1)
endfunction

" }}}
" VIBRemoveBuf - Remove a buffer from the VIB list {{{
"
function! <SID>VIBRemoveBuf(buf)
    if index(t:VIBList, a:buf) >= 0
        call <SID>ListPop(t:VIBList, a:buf)
    endif
    call <SID>AutoUpdate(bufnr("%"),1)
endfunction

" }}}
" VIBAdd - Add the current buffer to the VIB list {{{
"
function! <SID>VIBAdd()
    call <SID>VIBAddBuf(bufnr('%'))
endfunction

" }}}
" VIBRemove - Remove the current buffer from the VIB list {{{
"
function! <SID>VIBRemove()
    call <SID>VIBRemoveBuf(bufnr('%'))
endfunction

" }}}
" VIBToggle - Add/remove the current buffer from the VIB list {{{
"
function! <SID>VIBToggle()
    if index(t:VIBList, bufnr('%')) < 0
        call <SID>VIBAdd()
    else
        call <SID>VIBRemove()
    endif
endfunction

" }}}
" VIBAddAll - Add all the buffers to the VIB list {{{
"
function! <SID>VIBAddAll()
    for l:buf in range(1, bufnr('$'))
        if getbufvar(l:buf, "&buftype") == ''
            call <SID>VIBAddBuf(l:buf)
        endif
    endfor
endfunction

" }}}
" VIBRemoveAll - Clear the VIB list {{{
"
function! <SID>VIBRemoveAll()
    for l:buf in range(1, bufnr('$'))
        call <SID>VIBRemoveBuf(l:buf)
    endfor
endfunction

" }}}
" Split below/above? {{{
" When opening a new -VIBExplorer- window, split the new windows below or
" above the current window?  1 = below, 0 = above.
"
if !exists('g:vibExplBRSplit')
    let g:vibExplBRSplit = &splitbelow
endif

" }}}
" Split to edge? {{{
" When opening a new -VIBExplorer- window, split the new windows to the
" full edge? 1 = yes, 0 = no.
"
if !exists('g:vibExplSplitToEdge')
    let g:vibExplSplitToEdge = 1
endif

" }}}
" TabWrap? {{{
" By default line wrap is used (possibly breaking a tab name between two
" lines.) Turning this option on (setting it to 1) can take more screen
" space, but will make sure that each tab is on one and only one line.
"
if !exists('g:vibExplTabWrap')
    let g:vibExplTabWrap = 0
endif

" }}}
" Single/Double Click? {{{
" flag that can be set to 1 in a users .vimrc to allow
" double click switching of tabs. By default we use
" single click for tab selection.
"
if !exists('g:vibExplUseDoubleClick')
    let g:vibExplUseSingleClick = 1
endif

" }}}
" Close on Select? {{{
" Flag that can be set to 1 in a users .vimrc to hide
" the explorer when a user selects a buffer.
"
if !exists('g:vibExplCloseOnSelect')
    let g:vibExplCloseOnSelect = 0
endif

" }}}
" Status Line Text for VIB window {{{
"
if !exists('g:vibExplStatusLineText')
    let g:vibExplStatusLineText = "Very\\ Important\\ Buffers"
endif

" }}}
"
" Variables used internally
"
" Script/Global variables {{{

" Variable used to pass maxTabWidth info between functions
let s:maxTabWidth = 0

" Very Important Buffer list
let t:VIBList = []

" Global used to store the buffer list so that we don't update the VIB
" unless the list has changed.
let s:vibExplVIBList = ''

" Variable used as a mutex so that AutoUpdates would not get nested.
let s:vibExplInAutoUpdate = 0

" We start out with this off for startup, but once vim is running we
" turn this on. This prevent any BufEnter event from being triggered
" before VimEnter event.
let t:vibExplAutoUpdate = 0

" If VIB was opened manually, then we should skip eligible buffers checking
let t:skipEligibleBuffersCheck = 0

" }}}
"
" Auto Commands
"
" Setup an autocommand group and some autocommands {{{
" that keep our explorer updated automatically.
"

augroup VIBExpl
    autocmd!
    autocmd VimEnter      * nested call <SID>VimEnterHandler()
    autocmd TabEnter      * nested call <SID>TabEnterHandler()
    autocmd BufDelete     *        call <SID>BufDeleteHandler()
    if exists('##QuitPre')
        autocmd QuitPre   * if <SID>NextNormalWindow() == -1 | call <SID>StopExplorer(0) | endif
    endif
augroup END

function! <SID>VimEnterHandler()
    let t:VIBList = []
    let t:vibExplAutoUpdate = 1
    call <SID>AutoUpdate(bufnr("%"),0)
endfunction

function! <SID>TabEnterHandler()
    if !exists('t:VIBList')
        let t:VIBList = []
    endif
    if !exists('t:vibExplAutoUpdate')
        let t:vibExplAutoUpdate = 1
    endif
    call <SID>AutoUpdate(bufnr("%"),0)
endfunction

function! <SID>BufDeleteHandler()
    call <SID>VIBRemoveBuf(str2nr(expand("<abuf>")))

    " Handle ':bd' command correctly
    if (bufname('%') == '-VIBExplorer-' && <SID>NextNormalWindow() == -1 && len(t:VIBList) > 0)
        if(tabpagenr('$') == 1)
            setlocal modifiable
            resize
            exec 'noautocmd sb'.t:VIBList[0]
            call <SID>StopExplorer(0)
            call <SID>StartExplorer()
        else
            close
        endif
    endif
endfunction

" }}}
" StartExplorer - Sets up our explorer and causes it to be displayed {{{
"
function! <SID>StartExplorer()
    let t:vibExplAutoUpdate = 1

    let l:winNum = <SID>FindWindow('-VIBExplorer-')

    if l:winNum != -1
        return
    endif

    call <SID>CreateWindow('-VIBExplorer-', g:vibExplBRSplit, g:vibExplSplitToEdge, 1)

    let l:winNum = <SID>FindWindow('-VIBExplorer-')

    if l:winNum == -1
        return
    endif

    " Save current window number and switch to previous
    " window before entering VIB window so that the later
    " `wincmd p` command will get into this window, then
    " we can preserve a one level window movement history.
    let l:currWin = winnr()
    call s:SwitchWindow('p',1)

    " Switch into VIB allowing autocmd to run will
    " make the syntax highlight in VIB window working
    call s:SwitchWindow('w',0,l:winNum)

    " Make sure we are in our window
    if bufname('%') != '-VIBExplorer-'
        return
    endif

    " Set filetype for VIB buffer
    set filetype=veryimportantbuffers

    " !!! We may want to make the following optional -- Bindu
    " New windows don't cause all windows to be resized to equal sizes
    set noequalalways

    " !!! We may want to make the following optional -- Bindu
    " We don't want the mouse to change focus without a click
    set nomousefocus
    setlocal wrap

    " If folks turn numbering and columns on by default we will turn
    " them off for the VIB window
    setlocal foldcolumn=0
    setlocal nonumber
    if exists("&norelativenumber")
        " relativenumber was introduced in Vim 7.3 - this provides compatibility
        " for older versions of Vim
        setlocal norelativenumber
    endif
    "don't highlight matching parentheses, etc.
    setlocal matchpairs=
    "Depending on what type of split, make sure the VIB buffer is not
    "automatically rezised by CTRL + W =, etc...
    setlocal winfixheight
    setlocal winfixwidth

    " Set the text of the statusline for the VIB buffer. See help:stl for
    " many options
    exec 'setlocal statusline='.g:vibExplStatusLineText

    " No spell check
    setlocal nospell

    " Restore colorcolumn for VIM >= 7.3
    if exists("+colorcolumn")
        setlocal colorcolumn&
    end

    " If you press return, o or e in the -VIBExplorer- then try
    " to open the selected buffer in the previous window.
    nnoremap <buffer> o       :call <SID>VIBSelectBuffer(0)<CR>:<BS>
    nnoremap <buffer> e       :call <SID>VIBSelectBuffer(0)<CR>:<BS>
    nnoremap <buffer> <CR>    :call <SID>VIBSelectBuffer(0)<CR>:<BS>
    " Remote the buffer
    nnoremap <buffer> d       :call <SID>VIBRemoveSelected()<CR>:call search('\[[0-9]*:[^\]]*\]')<CR>:<BS>
    " If you press s in the -VIBExplorer- then try
    " to open the selected buffer in a split in the previous window.
    nnoremap <buffer> s       :call <SID>VIBSelectBuffer(1)<CR>:<BS>
    " If you press j in the -VIBExplorer- then try
    " to open the selected buffer in a vertical split in the previous window.
    nnoremap <buffer> v       :call <SID>VIBSelectBuffer(2)<CR>:<BS>
    " The following allow us to use regular movement keys to
    " scroll in a wrapped single line buffer
    nnoremap <buffer> k       gk
    nnoremap <buffer> j       gj
    nnoremap <buffer> <up>    gk
    nnoremap <buffer> <down>  gj
    " The following allows for quicker moving between buffer
    " names in the [VIB] window it also saves the last-pattern
    " and restores it.
    nnoremap <buffer> l       :call search('\[[0-9]*:[^\]]*\]')<CR>:<BS>
    nnoremap <buffer> h       :call search('\[[0-9]*:[^\]]*\]','b')<CR>:<BS>
    nnoremap <buffer> <right> :call search('\[[0-9]*:[^\]]*\]')<CR>:<BS>
    nnoremap <buffer> <left>  :call search('\[[0-9]*:[^\]]*\]','b')<CR>:<BS>

    " Attempt to perform single click mapping
    " It would be much nicer if we could 'nnoremap <buffer> ...', however
    " vim does not fire the '<buffer> <leftmouse>' when you use the mouse
    " to enter a buffer.
    if g:vibExplUseSingleClick == 1
        let l:mapcmd = ':nnoremap <silent> <LEFTMOUSE> <LEFTMOUSE>'
        let l:clickcmd = ':if bufname("%") == "-VIBExplorer-" <bar> call <SID>VIBSelectBuffer(0) <bar> endif <CR>'
        " no mapping for leftmouse
        if maparg('<LEFTMOUSE>', 'n') == ''
            exec l:mapcmd . l:clickcmd
            " we have a mapping
        else
            let  l:mapcmd = l:mapcmd . substitute(substitute(maparg('<LEFTMOUSE>', 'n'), '|', '<bar>', 'g'), '\c^<LEFTMOUSE>', '', '')
            let  l:mapcmd = l:mapcmd . l:clickcmd
            exec l:mapcmd
        endif
        " If you DoubleClick in the VIB window then try to open the selected
        " buffer in the previous window.
    else
        nnoremap <buffer> <2-LEFTMOUSE> :call <SID>VIBSelectBuffer(0)<CR>:<BS>
    endif

    call <SID>BuildBufferList()
    call <SID>DisplayBuffers()

    " Switch away from VIB allowing autocmd to run which will
    " trigger PowerLine's BufLeave event handler
    call s:SwitchWindow('p',0)

    " Now we are in the previous window, let's enter
    " the window current window, this will preserve
    " one-level backwards window movement history.
    call s:SwitchWindow('w',1,l:currWin)
endfunction

" }}}
" StopExplorer - Looks for our explorer and closes the window if it is open {{{
"
function! <SID>StopExplorer()
    if <SID>HasEligibleBuffers()
        let t:vibExplAutoUpdate = 0
    endif

    let l:winNum = <SID>FindWindow('-VIBExplorer-')
    if l:winNum == -1
        return
    endif

    call s:SwitchWindow('w',1,l:winNum)
    silent! close
    call s:SwitchWindow('p',1)

    " Work around a redraw bug in gVim (Confirmed present in 7.3.50)
    if has('gui_gtk') && has('gui_running')
        redraw!
    endif

endfunction

" }}}
" FocusExplorer {{{
"
function! <SID>FocusExplorer()
    let t:vibExplAutoUpdate = 1
    let l:winNum = <SID>FindWindow('-VIBExplorer-')

    if l:winNum == -1
        return
    endif

    call s:SwitchWindow('w',0,l:winNum)
endfunction

" }}}
" ToggleExplorer - Looks for our explorer and opens/closes the window {{{
"
function! <SID>ToggleExplorer()
    let l:winNum = <SID>FindWindow('-VIBExplorer-')
    if l:winNum != -1
        let t:skipEligibleBuffersCheck = 0
        call <SID>StopExplorer()
    else
        let t:skipEligibleBuffersCheck = 1
        call <SID>StartExplorer()
    endif
endfunction

" }}}
" UpdateExplorer {{{
"
function! <SID>UpdateExplorer(curBufNum)
    if !<SID>BuildBufferList()
        return
    endif

    let l:winNum = <SID>FindWindow('-VIBExplorer-')

    if l:winNum == -1
        return
    endif

    if l:winNum != winnr()
        let l:winChanged = 1

        " Save current window number and switch to previous
        " window before entering VIB window so that the later
        " `wincmd p` command will get into this window, then
        " we can preserve a one level window movement history.
        let l:currWin = winnr()
        call s:SwitchWindow('p',1)

        " Switch into VIB allowing autocmd to run will
        " make the syntax highlight in VIB window working
        call s:SwitchWindow('w',0,l:winNum)
    endif

    call <SID>DisplayBuffers()

    if exists('l:winChanged')
        " Switch away from VIB allowing autocmd to run which will
        " trigger PowerLine's BufLeave event handler
        call s:SwitchWindow('p',0)

        " Now we are in the previous window, let's enter
        " the window current window, this will preserve
        " one-level backwards window movement history.
        call s:SwitchWindow('w',1,l:currWin)
    endif
endfunction

" }}}
" FindWindow - Return the window number of a named buffer {{{
" If none is found then returns -1.
"
function! <SID>FindWindow(bufName)
    " Try to find an existing window that contains
    " our buffer.
    let l:winnr = bufwinnr(a:bufName)
    return l:winnr
endfunction

" }}}
" CreateWindow {{{
"
" brSplit, 0 no, 1 yes
"   split the window below/right to current window
" forceEdge, 0 no, 1 yes
"   split the window at the edege of the editor
" isPluginWindow, 0 no, 1 yes
"   if it is a plugin window
"
function! <SID>CreateWindow(bufName, brSplit, forceEdge, isPluginWindow)
    " Window number will change after creating a new window,
    " we need to save both current and previous window number
    " so that we can canculate theire correct window number
    " after the new window creating.
    let l:currWin = winnr()
    call s:SwitchWindow('p',1)
    let l:prevWin = winnr()
    call s:SwitchWindow('p',1)

    " Save the user's split setting.
    let l:saveSplitBelow = &splitbelow
    let l:saveSplitRight = &splitright

    " Set to our new values.
    let &splitbelow = a:brSplit
    let &splitright = a:brSplit

    let l:bufNum = bufnr(a:bufName)

    if l:bufNum == -1
        let l:spCmd = 'sp'
    else
        let l:spCmd = 'sb'
    endif

    if a:forceEdge == 1
        let l:edge = &splitbelow

        if l:edge
            silent exec 'noautocmd bo '.l:spCmd.' '.a:bufName
        else
            silent exec 'noautocmd to '.l:spCmd.' '.a:bufName
        endif
    else
        silent exec 'noautocmd '.l:spCmd.' '.a:bufName
    endif

    " Restore the user's split setting.
    let &splitbelow = l:saveSplitBelow
    let &splitright = l:saveSplitRight

    " Turn off the swapfile, set the buftype and bufhidden option, so that it
    " won't get written and will be deleted when it gets hidden.
    if a:isPluginWindow
        setlocal noswapfile
        setlocal nobuflisted
        setlocal buftype=nofile
        setlocal bufhidden=delete
    endif

    " Canculate the correct window number, for those whose window
    " number before the creating is greater than or equal to the
    " number of the newly created window, their window number should
    " increase by one.
    let l:prevWin = l:prevWin >= winnr() ? l:prevWin + 1 : l:prevWin
    let l:currWin = l:currWin >= winnr() ? l:currWin + 1 : l:currWin
    " This will preserve one-level backwards window movement history.
    call s:SwitchWindow('w',1,l:prevWin)
    call s:SwitchWindow('w',1,l:currWin)

endfunction

" }}}
" DisplayBuffers - Wrapper for getting VIB window shown {{{
"
" Makes sure we are in our explorer, then erases the current buffer and turns
" it into a VB explorer window.
"
function! <SID>DisplayBuffers()
    " Make sure we are in our window
    if bufname('%') != '-VIBExplorer-'
        return
    endif

    call <SID>ShowBuffers()
    call <SID>ResizeWindow()
endfunction

" }}}
" Resize Window - Set width/height of VIB window {{{
"
" Makes sure we are in our explorer, then sets the height/width for our explorer
" window so that we can fit all of our information without taking extra lines.
"
function! <SID>ResizeWindow()
    " Make sure we are in our window
    if bufname('%') != '-VIBExplorer-'
        return
    endif

    " Prevent a report of our actions from showing up.
    let l:save_rep = &report
    let l:save_sc  = &showcmd
    let &report    = 10000
    set noshowcmd

    let l:width  = winwidth('.')

    if g:vibExplTabWrap == 0
        let l:length = strlen(getline('.'))
        let l:height = 0
        if (l:width == 0)
            let l:height = winheight('.')
        else
            let l:height = (l:length / l:width)
            " handle truncation from div
            if (l:length % l:width) != 0
                let l:height = l:height + 1
            endif
        endif
    else
        " We need to be able to modify the buffer
        setlocal modifiable

        exec "setlocal textwidth=".l:width
        normal gg
        normal gq}
        normal G
        let l:height = line('.')
        normal gg

        " Prevent the buffer from being modified.
        setlocal nomodifiable
    endif

    " enfore min window height
    if l:height < 1 || l:height == 0
        let l:height = 1
    endif

    if &winminheight > l:height
        let l:saved_winminheight = &winminheight
        let &winminheight = 1
        exec 'resize '.l:height
        let &winminheight = l:saved_winminheight
    else
        exec 'resize '.l:height
    endif

    let saved_ead = &ead
    let &ead = 'ver'
    set equalalways
    let &ead = saved_ead
    set noequalalways

    normal! zz
    let &report  = l:save_rep
    let &showcmd = l:save_sc
endfunction

" }}}
" ShowBuffers - Clear current buffer and put the VIB text into it {{{
"
" Makes sure we are in our explorer, then adds a list of all VIB
"
function! <SID>ShowBuffers()
    " Make sure we are in our window
    if bufname('%') != '-VIBExplorer-'
        return
    endif

    let l:save_rep = &report
    let l:save_sc = &showcmd
    let &report = 10000
    set noshowcmd

    " We need to be able to modify the buffer
    setlocal modifiable

    " Delete all lines in buffer.
    silent 1,$d _

    " Goto the end of the buffer put the buffer list
    " and then delete the extra trailing blank line
    $
    put! =s:vibExplVIBList
    silent $ d _

    " Prevent the buffer from being modified.
    setlocal nomodifiable

    let &report  = l:save_rep
    let &showcmd = l:save_sc
endfunction

" }}}
" CycleBuffer - Cycle Through Buffers {{{
"
" Move to next or previous buffer in the current window. If there
" are no more modifiable buffers then stay on the current buffer.
" can be called with no parameters in which case the buffers are
" cycled forward. Otherwise a single argument is accepted, if
" it's 0 then the buffers are cycled backwards, otherwise they
" are cycled forward.
"
function! <SID>CycleBuffer(forward)
    if <SID>IsBufferIgnored(bufnr('%')) == 1
        return
    endif

    let curBufNum = bufnr('%')
    let curBufIndex = index(t:VIBList, l:curBufNum)
    let forBufIndex = l:curBufIndex + 1 >= len(t:VIBList) ? 0 : l:curBufIndex + 1
    let bacBufIndex = l:curBufIndex - 1 < 0 ? len(t:VIBList) - 1 : l:curBufIndex - 1

    if a:forward
        let l:moveCmd = 'b! '.t:VIBList[l:forBufIndex]
    else
        let l:moveCmd = 'b! '.t:VIBList[l:bacBufIndex]
    endif

    exec l:moveCmd
endfunction

" }}}
" IsBufferIgnored - check to see if buffer should be ignored {{{
"
" Returns 0 if this buffer should be displayed in the list, 1 otherwise.
"
function! <SID>IsBufferIgnored(buf)
    " Skip unlisted buffers.
    if buflisted(a:buf) == 0 || index(t:VIBList,a:buf) == -1
        return 1
    endif

    " Skip non normal buffers.
    if getbufvar(a:buf, "&buftype") != ''
        return 1
    endif

    return 0
endfunction

" }}}
" BuildBufferList - Build the text for the VIB window {{{
"
" Creates the buffer list string and returns 1 if it is different than
" last time this was called and 0 otherwise.
"
function! <SID>BuildBufferList()
    let l:tabList = []
    let l:maxTabWidth = 0

    " Loop through every buffer in VIB list
    for l:i in t:VIBList
        let l:tab = '['
        let l:tab .= l:i.':'
        let l:tab .= expand( "#" . l:i . ":p:t")
        let l:tab .= ']'

        let l:maxTabWidth = strlen(l:tab) > l:maxTabWidth ? strlen(l:tab) : l:maxTabWidth
        call add(l:tabList, l:tab)
    endfor

    let l:vibExplVIBList = ''
    for l:tab in l:tabList
        let l:vibExplVIBList = l:vibExplVIBList.l:tab

        " If tab wrap is turned on we need to add spaces
        if g:vibExplTabWrap != 0
            let l:vibExplVIBList = l:vibExplVIBList.' '
        endif
    endfor

    if (s:vibExplVIBList != l:vibExplVIBList)
        let s:maxTabWidth = l:maxTabWidth
        let s:vibExplVIBList = l:vibExplVIBList
        return 1
    else
        return 0
    endif
endfunction

" }}}
" HasEligibleBuffers - Are there enough VIB eligible buffers to open the VIB window? {{{
"
" Returns 1 if there are any buffers that can be displayed in a
" VIB explorer. Otherwise returns 0.
"
function! <SID>HasEligibleBuffers()
    if len(t:VIBList) > 0
        return 1
    else
        return 0
    endif
endfunction

" }}}
" Auto Update - Function called by auto commands for auto updating the VIB {{{
"
" IF auto update is turned on        AND
"    we are in a real buffer         AND
"    we have enough eligible buffers THEN
" Update our explorer and get back to the current window
"
" If we get a buffer number for a buffer that
" is being deleted, we need to make sure and
" remove the buffer from the list of eligible
" buffers in case we are down to one eligible
" buffer, in which case we will want to close
" the VIB window.
"
function! <SID>AutoUpdate(curBufNum,force)
    if (s:vibExplInAutoUpdate == 1)
        return
    else
        let s:vibExplInAutoUpdate = 1
    endif

    " Skip windows holding ignored buffer
    if !a:force && <SID>IsBufferIgnored(a:curBufNum) == 1
        let s:vibExplInAutoUpdate = 0
        return
    endif

    " Only allow updates when the AutoUpdate flag is set
    " this allows us to stop updates on startup.
    if exists('t:vibExplAutoUpdate') && t:vibExplAutoUpdate == 1
        " if we don't have a window then create one
        let l:winnr = <SID>FindWindow('-VIBExplorer-')

        if (exists('t:skipEligibleBuffersCheck') && t:skipEligibleBuffersCheck == 1) || <SID>HasEligibleBuffers() == 1
            if (l:winnr == -1)
                if g:vibExplAutoStart == 1
                    call <SID>StartExplorer()
                else
                    let s:vibExplInAutoUpdate = 0
                    return
                endif
            else
                call <SID>UpdateExplorer(a:curBufNum)
            endif
        else
            if (l:winnr == -1)
                let s:vibExplInAutoUpdate = 0
                return
            else
                call <SID>StopExplorer()
                " we do not want to turn auto-updating off
                let t:vibExplAutoUpdate = 1
            endif
        endif
    endif

    let s:vibExplInAutoUpdate = 0
endfunction

" }}}
" GetSelectedBuffer - From the VIB window, return the bufnum for buf under cursor {{{
"
" If we are in our explorer window then return the buffer number
" for the buffer under the cursor.
"
function! <SID>GetSelectedBuffer()
    " Make sure we are in our window
    if bufname('%') != '-VIBExplorer-'
        return -1
    endif

    let l:save_rep = &report
    let l:save_sc  = &showcmd
    let &report    = 10000
    set noshowcmd

    let l:save_reg = @"
    let @" = ""
    normal ""yi[
    if @" != ""
        let l:retv = substitute(@",'\([0-9]*\):.*', '\1', '') + 0
        let @" = l:save_reg
        return l:retv
    else
        let @" = l:save_reg
        return -1
    endif

    let &report  = l:save_rep
    let &showcmd = l:save_sc
endfunction

" }}}
" VIBSelectBuffer - From the VIB window, open buffer under the cursor {{{
"
" If we are in our explorer, then we attempt to open the buffer under the
" cursor in the previous window.
"
" Split indicates whether to open with split, 0 no split, 1 split horizontally
"
function! <SID>VIBSelectBuffer(split)
    " Make sure we are in our window
    if bufname('%') != '-VIBExplorer-'
        return
    endif

    let l:bufnr = <SID>GetSelectedBuffer()
    if(l:bufnr != -1)             " If the buffer exists.
        let l:saveAutoUpdate = t:vibExplAutoUpdate
        let t:vibExplAutoUpdate = 0

        call s:SwitchWindow('p',1)

        " if <SID>IsBufferIgnored(bufnr('%'))
        "     let l:winNum = <SID>NextNormalWindow()
        "     if l:winNum != -1
        "         call s:SwitchWindow('w',1,l:winNum)
        "     else
        "         return
        "     endif
        " endif

        if a:split == 0
            exec 'b! '.l:bufnr
        elseif a:split == 1
            exec 'sb! '.l:bufnr
        elseif a:split == 2
            exec 'vertical sb! '.l:bufnr
        endif

        let t:vibExplAutoUpdate = l:saveAutoUpdate
        call <SID>AutoUpdate(bufnr("%"),0)
    endif

    if g:vibExplCloseOnSelect == 1
        call <SID>StopExplorer()
    endif
endfunction

" }}}
" VIBRemoveSelected {{{
"
function! <SID>VIBRemoveSelected()
    " Make sure we are in our window
    if bufname('%') != '-VIBExplorer-'
        return
    endif

    let l:bufnr = <SID>GetSelectedBuffer()
    if(l:bufnr != -1) " If the buffer exists.
        call <SID>VIBRemoveBuf(l:bufnr)
        call <SID>UpdateExplorer(bufnr("%"))
        " call <SID>AutoUpdate(bufnr("%"),1)
    endif
endfunction

" }}}
" NextNormalWindow {{{
"
function! <SID>NextNormalWindow()
    let l:winSum = winnr('$')
    let l:i = 1
    while(l:i <= l:winSum)
        if !<SID>IsBufferIgnored(winbufnr(l:i)) && l:i != winnr()
            return l:i
        endif
        let l:i = l:i + 1
    endwhile

    return -1
endfunction

" }}}
" ListPop {{{
"
function! <SID>ListPop(list,val)
    call filter(a:list, 'v:val != '.a:val)
endfunction

" }}}
" SwitchWindow {{{
"
function! s:SwitchWindow(action, ...)
    if a:action !~ '[hjkltbwWpP]'
        return
    endif

    if exists('a:1') && a:1 == 1
        let l:aucmd = 'noautocmd '
    else
        let l:aucmd = ''
    endif

    if exists('a:2')
        let l:winnr = a:2
    else
        let l:winnr = ''
    endif

    let l:wincmd = l:aucmd.l:winnr.'wincmd '.a:action
    exec l:wincmd
endfunction

" }}}

