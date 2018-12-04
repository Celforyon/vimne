"{{{"""""""""""" Variables """"""""""""""""""""""""""""

let s:num_regex     = '[0-9A-Fa-fx+-]'
let s:notnum_regex  = '[^0-9+-]'
let s:digits        = '0123456789abcdef'
let s:upper_digits  = '0123456789ABCDEF'

"}}}"""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{"""""""""""" Functions """"""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""
"{{{ Text edition utilities """""""""""
"""""""""""""""""""""""""""""""""""""""
"{{{
function! vimne#erase(n)
	let l:col = col('.')
	let l:i   = 0
	while l:i != a:n
		execute 'normal x'
		let l:i = l:i + 1
	endwhile

	return l:col != col('.')
endfunction
"}}}
"{{{
function! vimne#insert(text, append)
	if a:append
		let l:method = 'a'
	else
		let l:method = 'i'
	endif
	execute 'normal '.l:method.a:text
endfunction
"}}}
"}}}

"""""""""""""""""""""""""""""""""""""""
"{{{ Cursor utilities """""""""""""""""
"""""""""""""""""""""""""""""""""""""""
"{{{
function! vimne#setcursor(col)
	let l:pos     = getpos('.')
	let l:pos[2]  = a:col

	call setpos('.', l:pos)
endfunction
"}}}
"{{{
function! vimne#getnumstr(range)
	return getline('.')[a:range[0]-1:a:range[1]-1]
endfunction
"}}}
"}}}

"""""""""""""""""""""""""""""""""""""""
"{{{ Basic number utilities """""""""""
"""""""""""""""""""""""""""""""""""""""
"{{{
function! vimne#sign(str)
	let l:sign = ''
	if a:str[0] =~ '[+-]'
		let l:sign = a:str[0]
	endif

	return l:sign
endfunction
"}}}
"{{{
function! vimne#base(str)
	let l:base    = 10
	let l:offset  = 0

	if vimne#sign(a:str) != ''
		let l:offset = 1
	endif

	if a:str[0+l:offset] == '0'
		let l:b = a:str[1+l:offset]
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
"}}}
"{{{
function! vimne#validdigits(str)
	let l:digit_regex = '[0-9]'
	if a:str[0] == '0' && len(a:str) > 1
		let basechar = a:str[1]
		if l:basechar ==? 'x'
			let l:digit_regex = '[0-9A-Fa-f]'
		elseif l:basechar ==? 'b'
			let l:digit_regex = '[01]'
		elseif l:basechar =~ '[0-7]'
			let l:digit_regex = '[0-7]'
		endif
	endif

	return l:digit_regex
endfunction
"}}}
"}}}

"""""""""""""""""""""""""""""""""""""""
"{{{ Number utilities """""""""""""""""
"""""""""""""""""""""""""""""""""""""""
"{{{
function! vimne#gotonum()
	let l:pos   = getpos('.')
	let l:lnum  = l:pos[1]
	let l:cnum  = l:pos[2]

	let l:line  = getline(l:lnum)

	" if already in the number
	while l:cnum != 0 && l:line[l:cnum-1] =~ s:num_regex
		let l:cnum = l:cnum - 1
	endwhile

	" go forward to find a number
	while l:cnum < len(l:line) && l:line[l:cnum] =~ s:notnum_regex
		let l:cnum = l:cnum + 1
	endwhile

	if l:cnum < len(l:line)
		let l:cnum = l:cnum + 1
		call vimne#setcursor(l:cnum)
		return l:cnum
	endif
	return 0
endfunction
"}}}
"{{{
function! vimne#numpos(bnum)
	let l:line = getline('.')
	let l:enum = a:bnum

	" accept sign
	let l:enum = l:enum + ((l:line[l:enum-1] =~ '[+-]')?1:0)
	" find valid digits
	let l:digit_regex = vimne#validdigits(l:line[l:enum-1:])
	" skip format char
	let l:enum = l:enum + ((l:line[l:enum] =~ '[xXbB]')?1:0)

	" accept valid digits
	while l:enum < len(l:line) && l:line[l:enum] =~ l:digit_regex
		let l:enum = l:enum + 1
	endwhile

	let l:bprefix = l:enum + 1

	return [a:bnum, l:enum]
endfunction
"}}}
"{{{
function! vimne#nr2str(value, base, ...)
	let l:signchar            = (a:0 >= 1? a:1:0)? '+':''
	let l:basechar            = a:0 >= 2? a:2:(a:base==2?'b':(a:base==16?'x':''))

	let l:prefix = ''
	if a:base != 10
		let l:prefix = l:prefix.'0'
		if a:base != 8
			let l:prefix = l:prefix.l:basechar
		endif
	endif

	let l:digits = s:digits
	if l:basechar == 'X'
		let l:digits = s:upper_digits
	endif

	let l:str = ''
	let l:value = abs(a:value)
	if l:value != a:value
		let l:signchar = '-'
	endif

	while l:value
		let l:digit = l:value % a:base
		let l:str   = l:digits[l:digit].l:str
		let l:value = (l:value - l:digit) / a:base
	endwhile

	if empty(l:str)
		let l:str = '0'
	endif

	return l:signchar.l:prefix.l:str
endfunction
"}}}
"}}}

"""""""""""""""""""""""""""""""""""""""
"{{{ Entrypoint """""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""
"{{{
function! vimne#apply(function, modifier)
	let l:bnum = vimne#gotonum()
	if l:bnum == 0
		return
	endif

	let l:pos       = vimne#numpos(l:bnum)

	let l:size      = l:pos[1] - l:pos[0] + 1
	let l:valstr    = vimne#getnumstr(l:pos)
	let l:sign      = vimne#sign(l:valstr)
	let l:base      = vimne#base(l:valstr)
	let l:value     = str2nr(l:valstr, l:base)
	let l:newvalue  = call(a:function, [l:value, a:modifier])
	let l:append    = vimne#erase(l:size)

	let l:basechar  = l:base==10? '':l:valstr[1+(l:sign != ''?1:0)]

	let l:newstr    = vimne#nr2str(l:newvalue, l:base, !empty(l:sign), l:basechar)

	call vimne#insert(l:newstr, l:append)
endfunction
"}}}
"}}}

"""""""""""""""""""""""""""""""""""""""
"{{{ Math functions """""""""""""""""""
"""""""""""""""""""""""""""""""""""""""
"{{{
function! vimne#multiply(v, n)
	let l:n = a:n? a:n:2
	return a:v * l:n
endfunction
"}}}
"{{{
function! vimne#divide(v, n)
	let l:n = a:n? a:n:2
	return a:v / l:n
endfunction
"}}}
"{{{
function! vimne#multbypowerof2(v, n)
	let l:n   = a:n? a:n:1
	let l:res = a:v
	while l:n
		let l:res = l:res * 2
		let l:n   = l:n - 1
	endwhile
	return l:res
endfunction
"}}}
"{{{
function! vimne#divbypowerof2(v, n)
	let l:n   = a:n? a:n:1
	let l:res = a:v
	while l:n
		let l:res = l:res / 2
		let l:n   = l:n - 1
	endwhile
	return l:res
endfunction
"}}}
"{{{
function! vimne#fibo(p0, p1)
	return [a:p1, a:p0+a:p1]
endfunction
"}}}
"{{{
function! vimne#nextfibonacci(v, n)
	let l:n   = a:n? a:n:1
	let l:p0  = 1
	let l:p1  = 1

	while l:p1 < a:v
		let [l:p0, l:p1] = vimne#fibo(l:p0, l:p1)
	endwhile

	if l:p1 != a:v
		" not a fibonacci number
		return a:v
	endif

	while l:n
		let [l:p0, l:p1]  = vimne#fibo(l:p0, l:p1)
		let l:n           = l:n - 1
	endwhile

	return l:p1
endfunction
"}}}
"{{{
function! vimne#prevfibonacci(v, n)
	let l:n = a:n? a:n:1
	let l:p = [1, 1]

	while l:p[-1] < a:v
		let [l:ignore, l:next]  = vimne#fibo(l:p[-2], l:p[-1])
		let l:p                 = l:p+[l:next]
	endwhile

	if l:p[-1] != a:v
		" not a fibonacci number
		return a:v
	endif

	if l:n >= len(l:p)
		return 1
	endif
	return l:p[-l:n-1]
endfunction
"}}}
"}}}

"}}}"""""""""""""""""""""""""""""""""""""""""""""""""""
