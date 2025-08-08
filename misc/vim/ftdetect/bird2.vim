augroup bird2_ftdetect
  autocmd!
  
  " Filename-based detection
  autocmd BufRead,BufNewFile *.bird,*.bird2,*.bird3,*.bird*.conf setfiletype bird2
  autocmd BufRead,BufNewFile bird.conf,bird6.conf setfiletype bird2
  
  " Heuristic detection for generic *.conf (scan first 200 lines)
  function! s:Bird2MaybeSetFiletype() abort
    " Skip if filetype already set (except for generic 'conf')
    if &filetype !=# '' && &filetype !=# 'conf'
      return
    endif
    
    let l:max_lines = min([200, line('$')])
    if l:max_lines <= 0
      return
    endif
    
    " Enhanced pattern matching for BIRD-specific keywords
    " Includes: protocols, router id, templates, filters, flow/roa tables, static routes
    " Split into simpler patterns to avoid NFA regexp complexity errors
    let l:patterns = [
      \ '\<protocol\s\+\(bgp\|ospf\|rip\|device\|direct\|kernel\|pipe\|babel\|radv\|rpki\|bfd\|static\)\>',
      \ '^\s*router\s\+id\>',
      \ '^\s*template\>',
      \ '^\s*filter\>',
      \ '\<flow[46]\>',
      \ '\<roa[46]\>',
      \ '^\s*table\>',
      \ '^\s*define\>',
      \ '^\s*function\>',
      \ '\<ipv[46]\s\+table\>'
      \ ]
    
    for lnum in range(1, l:max_lines)
      let l:line = getline(lnum)
      " Skip empty lines and comments for efficiency
      if l:line =~# '^\s*$' || l:line =~# '^\s*#'
        continue
      endif
      
      " Check each pattern separately
      for l:pat in l:patterns
        if l:line =~? l:pat
          setfiletype bird2
          return
        endif
      endfor
    endfor
  endfunction
  
  autocmd BufRead,BufNewFile *.conf call s:Bird2MaybeSetFiletype()
augroup END