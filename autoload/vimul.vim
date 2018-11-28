"""""""""""""""" Variables """"""""""""""""""""""""""""

let s:num_regex     = '[0-9]'
let s:notnum_regex  = '[^0-9]'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""" Functions """"""""""""""""""""""""""""

function! vimul#gotonum()
	let l:pos   = getpos('.')
	let l:lnum  = l:pos[1]
	let l:cnum  = l:pos[2]

	let l:line  = getline(l:lnum)

	while l:cnum != 0 && l:line[l:cnum-1] =~ s:num_regex
		let l:cnum = l:cnum - 1
	endwhile
	while l:cnum < len(l:line) && l:line[l:cnum] =~ s:notnum_regex
		let l:cnum = l:cnum + 1
	endwhile

	if l:cnum < len(l:line)
		let l:cnum = l:cnum + 1
		let l:enum = l:cnum
		while l:enum < len(l:line) && l:line[l:enum] =~ s:num_regex
			let l:enum = l:enum + 1
		endwhile

		call setpos('.', [l:pos[0], l:lnum, l:cnum, l:pos[3]])
		return [l:cnum, l:enum]
	endif

	return [0, 0]
endfunction

function! vimul#getnumstr()
	let l:str = expand("<cword>")
	return l:str
endfunction

function! vimul#value(str)
	let l:base = 10
	if a:str[0] == '0'
		let l:b = a:str[1]
		if l:b =~ '[xX]'
			let l:base = 16
		elseif l:b =~ '[bB]'
			let l:base = 2
		else
			let l:base = 8
		endif
	endif

	let l:value = str2nr(a:str, l:base)
	return l:value
endfunction

function! vimul#erase(n)
	let l:col = col('.')
	let l:i   = 0
	while l:i != a:n
		execute 'normal x'
		let l:i = l:i + 1
	endwhile

	return l:col != col('.')
endfunction

function! vimul#insert(text, append)
	if a:append
		let l:method = 'a'
	else
		let l:method = 'i'
	endif
	execute 'normal '.l:method.a:text
endfunction

function! vimul#multiply(n)
	let l:pos = vimul#gotonum()
	if l:pos == [0, 0]
		return
	endif

	let l:n = a:n
	if l:n == 0
		let l:n = 2
	endif

	let l:size    = l:pos[1] - l:pos[0] + 1
	let l:value   = vimul#value(vimul#getnumstr())
	let l:append  = vimul#erase(l:size)
	call vimul#insert(l:value * l:n, l:append)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
