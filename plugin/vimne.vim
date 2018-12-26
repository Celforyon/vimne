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

function! BaseEdit(modifier)
	return vimne#changebase(a:modifier)
endfunction

"}}}"""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{"""""""""""" Commands """""""""""""""""""""""""""""

command! Add            :call NumEdit('vimne#calc#add',             v:count)
command! Subtract       :call NumEdit('vimne#calc#subtract',        v:count)
command! Multiply       :call NumEdit('vimne#calc#multiply',        v:count)
command! Divide         :call NumEdit('vimne#calc#divide',          v:count)

command! Or             :call NumEdit('or',                         v:count)
command! And            :call NumEdit('and',                        v:count)
command! Xor            :call NumEdit('xor',                        v:count)

command! MultByPowerOf2 :call NumEdit('vimne#calc#multbypowerof2',  v:count)
command! DivByPowerOf2  :call NumEdit('vimne#calc#divbypowerof2',   v:count)

command! PrevFibonacci  :call NumEdit('vimne#calc#prevfibonacci',   v:count)
command! NextFibonacci  :call NumEdit('vimne#calc#nextfibonacci',   v:count)


command! ChangeBase     :call BaseEdit(v:count)
command! ToBase2        :call BaseEdit(2)
command! ToBase8        :call BaseEdit(8)
command! ToBase10       :call BaseEdit(10)
command! ToBase16       :call BaseEdit(16)

"}}}"""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{"""""""""""" Autocmd """"""""""""""""""""""""""""""

"}}}"""""""""""""""""""""""""""""""""""""""""""""""""""
