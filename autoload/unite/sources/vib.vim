let s:unite_source = { 'name': 'vib' }

function! s:unite_source.gather_candidates(args, context)
    let l:bufList = []
    if !exists('t:VIBList')
        let t:VIBList = []
    endif
    for l:buf in t:VIBList
        if bufexists(l:buf)
            let l:bufName = expand( "#" . l:buf . ":p:t")
            let l:bufPath = expand( "#" . l:buf . ":p")
            let l:dict = {
                \ "word": l:bufName,
                \ "source": "vib",
                \ "kind": "buffer",
                \ "action__buffer_nr": l:buf  
                \ }
            call add(l:bufList, l:dict)
        endif
    endfor
    return l:bufList
endfunction

function! unite#sources#vib#define()
    return s:unite_source
endfunction
