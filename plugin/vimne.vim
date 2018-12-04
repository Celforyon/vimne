" vimne.vim
" Maintainer: Alexis Pereda
" Version: 1

if exists('g:loaded_vimne')
	finish
endif
let g:loaded_vimne = 1

"{{{"""""""""""" Variables """"""""""""""""""""""""""""

"}}}"""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{"""""""""""" Highlights """""""""""""""""""""""""""

"}}}"""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{"""""""""""" Functions """"""""""""""""""""""""""""

function! NumEdit(function, modifier)
	return vimne#apply(function(a:function), a:modifier)
endfunction

"}}}"""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{"""""""""""" Commands """""""""""""""""""""""""""""

command! Multiply       :call NumEdit('vimne#multiply',       v:count)
command! Divide         :call NumEdit('vimne#divide',         v:count)

command! MultByPowerOf2 :call NumEdit('vimne#multbypowerof2', v:count)
command! DivByPowerOf2  :call NumEdit('vimne#divbypowerof2',  v:count)

command! PrevFibonacci  :call NumEdit('vimne#prevfibonacci',  v:count)
command! NextFibonacci  :call NumEdit('vimne#nextfibonacci',  v:count)

"}}}"""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{"""""""""""" Autocmd """"""""""""""""""""""""""""""

"}}}"""""""""""""""""""""""""""""""""""""""""""""""""""
