"""""""""""""""" Variables """"""""""""""""""""""""""""

let s:num_regex     = '[0-9A-Fa-fx]'
let s:notnum_regex  = '[^0-9]'
let s:digits        = '0123456789abcdef'
let s:upper_digits  = '0123456789ABCDEF'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""" Functions """"""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""
"""" Utility """"""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""
function! vimul#setcursor(col)
	let l:pos     = getpos('.')
	let l:pos[2]  = a:col

	call setpos('.', l:pos)
endfunction

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
		call vimul#setcursor(l:cnum)
		return l:cnum
	endif
	return 0
endfunction

function! vimul#numpos(bnum)
	let l:line = getline('.')
	let l:enum = a:bnum

	let l:digit_regex = '[0-9]'
	if l:line[l:enum-1] == '0' && l:enum < len(l:line)
		if l:line[l:enum] ==? 'x'
			let l:digit_regex = '[0-9A-Fa-f]'
			let l:enum        = l:enum + 1
		elseif l:line[l:enum] ==? 'b'
			let l:digit_regex = '[01]'
			let l:enum        = l:enum + 1
		elseif l:line[l:enum] =~ '[0-7]'
			let l:digit_regex = '[0-7]'
		endif
	endif

	while l:enum < len(l:line) && l:line[l:enum] =~ l:digit_regex
		let l:enum = l:enum + 1
	endwhile

	return [a:bnum, l:enum]
endfunction

function! vimul#getnumstr(range)
	let l:str = getline('.')[a:range[0]-1:a:range[1]-1]
	return l:str
endfunction

function! vimul#base(str)
	let l:base = 10
	if a:str[0] == '0'
		let l:b = a:str[1]
		if l:b ==? 'x'
			let l:base = 16
		elseif l:b ==? 'b'
			let l:base = 2
		elseif l:b =~ '[0-7]'
			let l:base = 8
		endif
	endif

	return l:base
endfunction

function! vimul#nr2str(value, base, basechar)
	let l:prefix = ''
	if a:base != 10
		let l:prefix = l:prefix.'0'
		if a:base != 8
			let l:prefix = l:prefix.a:basechar
		endif
	endif

	let l:digits = s:digits
	if a:basechar == 'X'
		let l:digits = s:upper_digits
	endif

	let l:str = ''
	let l:value = a:value
	while l:value
		let l:digit = l:value % a:base
		let l:str   = l:digits[l:digit].l:str
		let l:value = (l:value - l:digit) / a:base
	endwhile

	if empty(l:str)
		let l:str = '0'
	endif

	return l:prefix.l:str
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

"""""""""""""""""""""""""""""""""""""""
"""" Entrypoint """""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""
function! vimul#apply(function, modifier)
	let l:bnum = vimul#gotonum()
	if l:bnum == 0
		return
	endif

	let l:pos       = vimul#numpos(l:bnum)

	let l:size      = l:pos[1] - l:pos[0] + 1
	let l:valstr    = vimul#getnumstr(l:pos)
	let l:base      = vimul#base(l:valstr)
	let l:value     = str2nr(l:valstr, l:base)
	let l:newvalue  = call(a:function, [l:value, a:modifier])
	let l:append    = vimul#erase(l:size)

	let l:newstr    = vimul#nr2str(l:newvalue, l:base, l:base==10? '':l:valstr[1])

	call vimul#insert(l:newstr, l:append)
endfunction

"""""""""""""""""""""""""""""""""""""""
"""" Math functions """""""""""""""""""
"""""""""""""""""""""""""""""""""""""""
function! vimul#multiply(v, n)
	let l:n = a:n? a:n:2
	return a:v * l:n
endfunction

function! vimul#divide(v, n)
	let l:n = a:n? a:n:2
	return a:v / l:n
endfunction

function! vimul#power2(v, n)
	let l:n   = a:n? a:n:1
	let l:res = a:v
	while l:n
		let l:res = l:res * 2
		let l:n   = l:n - 1
	endwhile
	return l:res
endfunction

function! vimul#nextfibo(p0, p1)
	return [a:p1, a:p0+a:p1]
endfunction

function! vimul#fibo(v, n)
	let l:n   = a:n? a:n:1
	let l:p0  = 1
	let l:p1  = 1

	while l:p1 < a:v
		let [l:p0, l:p1] = vimul#nextfibo(l:p0, l:p1)
	endwhile

	if l:p1 != a:v
		" not a fibonacci number
		return a:v
	endif

	while l:n
		let [l:p0, l:p1]  = vimul#nextfibo(l:p0, l:p1)
		let l:n           = l:n - 1
	endwhile

	return l:p1
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
