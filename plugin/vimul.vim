" vimul.vim
" Maintainer: Alexis Pereda
" Version: 1

if exists('g:loaded_vimul')
	finish
endif
let g:loaded_vimul = 1

"""""""""""""""" Variables """"""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""" Highlights """""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""" Functions """"""""""""""""""""""""""""

function! VimulApply(function, modifier)
	return vimul#apply(a:function, a:modifier)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""" Commands """""""""""""""""""""""""""""

command! Multiply       :call vimul#apply(function('vimul#multiply'), v:count)
command! Divide         :call vimul#apply(function('vimul#divide'),   v:count)
command! MultByPowerOf2 :call vimul#apply(function('vimul#power2'),   v:count)

command! NextFibonacci  :call vimul#apply(function('vimul#fibo'),     v:count)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""" Autocmd """"""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
