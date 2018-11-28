" vimne.vim
" Maintainer: Alexis Pereda
" Version: 1

if exists('g:loaded_vimne')
	finish
endif
let g:loaded_vimne = 1

"""""""""""""""" Variables """"""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""" Highlights """""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""" Functions """"""""""""""""""""""""""""

function! VimulApply(function, modifier)
	return vimne#apply(a:function, a:modifier)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""" Commands """""""""""""""""""""""""""""

command! Multiply       :call vimne#apply(function('vimne#multiply'),       v:count)
command! Divide         :call vimne#apply(function('vimne#divide'),         v:count)

command! MultByPowerOf2 :call vimne#apply(function('vimne#multbypowerof2'), v:count)
command! DivByPowerOf2  :call vimne#apply(function('vimne#divbypowerof2'),  v:count)

command! NextFibonacci  :call vimne#apply(function('vimne#nextfibonacci'),  v:count)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""" Autocmd """"""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
