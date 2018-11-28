"""""""""""""""" Variables """"""""""""""""""""""""""""

let s:num_regex     = '[0-9a-fA-F.+-]'
let s:notnum_regex  = '[^0-9.+-]'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""" Functions """"""""""""""""""""""""""""

function! vimul#gotonum()
	let l:pos   = getpos('.')
	let l:lnum  = l:pos[1]
	let l:cnum  = l:pos[2]

	let l:line  = getline(l:lnum)

	while l:cnum != 0 && l:line[l:cnum] =~ s:num_regex
		let l:cnum = l:cnum - 1
	endwhile
	while l:cnum < len(l:line) && l:line[l:cnum] =~ s:notnum_regex
		let l:cnum = l:cnum + 1
	endwhile

	if l:cnum < len(l:line)
		let l:cnum = l:cnum + 1
		call setpos('.', [l:pos[0], l:lnum, l:cnum, l:pos[3]])
		return 1
	endif

	return 0
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
