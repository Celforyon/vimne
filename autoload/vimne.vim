"{{{"""""""""""" Variables """"""""""""""""""""""""""""
" TODO handle less than 1 numbers (negative powers)

let s:num_regex     = '[0-9A-Fa-fx+-]'
let s:notnum_regex  = '[^0-9+-]'
let s:digits        = '0123456789abcdef'
let s:upper_digits  = '0123456789ABCDEF'

let s:unit_seps     = ' ./'
"{{{
" \ ['Y', 10, 24], ['Z', 10, 21], too big
" \ ['Yi', 2, 80], ['Zi', 2, 70], too big
let s:si_prefixes   = [
			\ ['E', 10, 18], ['P', 10, 15],
			\ ['T', 10, 12], ['G', 10, 9],
			\ ['M', 10, 6], ['k', 10, 3],
			\ ['h', 10, 2], ['da', 10, 1],
			\ ['', 10, 0],
			\ ['d', 10, -1], ['c', 10, -2],
			\ ['m', 10, -3], ['µ', 10, -6],
			\ ['n', 10, -9], ['p', 10, -12],
			\ ['f', 10, -15], ['a', 10, -18],
			\ ['z', 10, -21], ['y', 10, -24],
			\ ['Ei', 2, 60], ['Pi', 2, 50],
			\ ['Ti', 2, 40], ['Gi', 2, 30],
			\ ['Mi', 2, 20], ['Ki', 2, 10]
			\ ]
"}}}
"{{{
let s:units         = [
			\ 'm', 'g', 's', 'A', 'K', 'mol', 'cd',
			\ 'o', 'B', 'bit',
			\ 'rad', 'sr', 'Hz', 'N', 'Pa', 'J', 'W', 'C', 'V',
			\ 'F', 'Ohm', 'S', 'Wb', 'T', 'H', '°C', 'lm', 'lx',
			\ 'Bq', 'Gy', 'Sv', 'kat'
			\ ]
"}}}

"}}}"""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{"""""""""""" Functions """"""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""
"{{{ Math """""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""
"{{{
function! vimne#pow(x, n)
	let l:r = 1
	let l:i = 0
	while l:i < a:n
		let l:r = l:r * a:x
		let l:i = l:i+1
	endwhile
	return l:r
endfunction
"}}}
"}}}
"""""""""""""""""""""""""""""""""""""""
"{{{ String utilities """""""""""""""""
"""""""""""""""""""""""""""""""""""""""
"{{{
function! vimne#strstartswith(str, pattern)
	let l:size = len(a:pattern)

	if len(a:str) < l:size
		return 0
	endif

	let l:str = a:str[0:l:size-1]

	return l:str ==# a:pattern
endfunction
"}}}
"{{{
function! vimne#strlonger(lhs, rhs)
	return len(a:lhs) < len(a:rhs)
endfunction
"}}}
"}}}
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
function! vimne#movecursor(coloffset)
	let l:pos     = getpos('.')
	let l:pos[2] += a:coloffset

	call setpos('.', l:pos)
endfunction
"}}}
"{{{
function! vimne#getnumstr(range)
	return getline('.')[a:range[0]-1:a:range[2]-1]
endfunction
"}}}
"{{{
function! vimne#getunitprefix(range)
	let l:line  = getline('.')
	let l:range = copy(a:range)


	" possibly skip one space
	if l:line[l:range[2]-1] =~ '[ ]'
		let l:range[2] = l:range[2] + 1
	endif

	let l:sep = ''
	if a:range[2] < l:range[2]
		let l:sep = l:line[a:range[2]-1:l:range[2]-2]
	endif

	if l:range[2] > l:range[1]
		if vimne#isunit(l:line[l:range[2]-1:])
			return [l:sep, ['', 10, 0]]
		endif
		return ['', []]
	endif

	let l:unitstr = l:line[l:range[2]-1:l:range[1]-1]

	let l:prefixes  = s:si_prefixes
	let l:unit      = []
	let l:i         = 0
	while l:unit == [] && l:i < len(l:prefixes)
		if l:prefixes[l:i][0] ==# l:unitstr
			let l:unit = l:prefixes[l:i]
		endif
		let l:i = l:i+1
	endwhile

	return [l:sep, l:unit]
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
"{{{ Units utilities """"""""""""""""""
"""""""""""""""""""""""""""""""""""""""
"{{{
function! vimne#findprefix(str)
	let l:prefixes  = sort(copy(s:si_prefixes), {lhs, rhs -> len(rhs[0]) - len(lhs[0])})
	let l:prefix    = []
	let l:i         = 0
	while l:prefix == [] && l:i < len(l:prefixes)
		if vimne#strstartswith(a:str, l:prefixes[l:i][0])
			let l:prefix = l:prefixes[l:i]
		endif
		let l:i = l:i+1
	endwhile

	return l:prefix
endfunction
"}}}
"{{{
function! vimne#isunit(str)
	let l:units = sort(copy(s:units), {lhs, rhs -> len(rhs) - len(lhs)})
	let l:unit  = ''
	let l:i     = 0

	while empty(l:unit) && l:i < len(l:units)
		if vimne#strstartswith(a:str, l:units[l:i])
			let l:unit = l:units[l:i]
		endif
		let l:i = l:i+1
	endwhile

	if len(l:unit)
		let l:nextchar = a:str[len(l:unit)]
		return (empty(l:nextchar) || l:nextchar =~ '['.s:unit_seps.']')
	endif

	return 0
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
	let l:enum = l:enum + ((l:line[l:enum-1] =~ '[+-]')? 1:0)
	" find valid digits
	let l:digit_regex = vimne#validdigits(l:line[l:enum-1:])
	" skip format char
	let l:enum = l:enum + ((l:line[l:enum] =~ '[xXbB]')? 1:0)

	" accept valid digits
	while l:enum < len(l:line) && l:line[l:enum] =~ l:digit_regex
		let l:enum = l:enum + 1
	endwhile

	" accept si prefix
	let l:bprefix = l:enum + 1
	let l:enumsav = l:enum

	" skip one space
	let l:enum    = l:enum + ((l:line[l:enum] == ' ')? 1:0)
	" check si prefixes
	let l:prefix  = l:enum < len(l:line)? vimne#findprefix(l:line[l:enum:]):[]
	if l:prefix != []
		let l:enum    = l:enum + len(l:prefix[0])
	endif

	" if it does seem to be a valid prefix
	if !(l:enum >= len(l:line) || l:line[l:enum] == ' ' || vimne#isunit(l:line[l:enum:]))
		let l:enum = l:enumsav
	endif

	return [a:bnum, l:enum, l:bprefix]
endfunction
"}}}
"{{{
function! vimne#str2nr(str, base, siprefix)
	let l:value = str2nr(a:str, a:base)
	if a:siprefix == []
		return l:value
	endif
	return l:value * vimne#pow(a:siprefix[1], a:siprefix[2])
endfunction
"}}}
"{{{
function! vimne#reducenr(value, siprefix)
	if a:siprefix == []
		return [a:value, []]
	endif

	let l:siprefixes = filter(s:si_prefixes, {idx, val -> val[1] == a:siprefix[1]})
	let l:siprefixes = sort(l:siprefixes, {lhs, rhs -> rhs[2] - lhs[2]})

	let l:siprefix = []
	let l:i = 0
	while l:siprefix == [] && l:i < len(l:siprefixes)
		let l:cur = l:siprefixes[l:i]
		if a:value % vimne#pow(l:cur[1], l:cur[2]) == 0
			let l:siprefix = l:cur
		endif
		let l:i = l:i+1
	endwhile

	return [a:value / vimne#pow(l:siprefix[1], l:siprefix[2]), l:siprefix]
endfunction
"}}}
"{{{
function! vimne#nr2str(value, base, ...)
	let l:signchar            = (a:0 >= 1? a:1:0)? '+':''
	let l:basechar            = a:0 >= 2? a:2:(a:base==2?'b':(a:base==16?'x':''))
	let [l:sisep, l:siprefix] = a:0 >= 3? a:3:['', []]

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

	let l:r = l:signchar.l:prefix.l:str.l:sisep
	if l:siprefix != []
		let l:r = l:r.l:siprefix[0]
	endif

	return l:r
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

	let l:pos         = vimne#numpos(l:bnum)

	let l:size        = l:pos[1] - l:pos[0] + 1
	let l:unitsize    = l:pos[1] - l:pos[2] + 1
	let l:valstr      = vimne#getnumstr(l:pos)
	let [l:sisep, l:siprefix] = vimne#getunitprefix(l:pos)
	let l:sign        = vimne#sign(l:valstr)
	let l:base        = vimne#base(l:valstr)
	let l:value       = vimne#str2nr(l:valstr, l:base, l:siprefix)
	let l:newvalue    = call(a:function, [l:value, a:modifier])
	let l:append      = vimne#erase(l:size)

	let [l:newvalue, l:newsiprefix] = vimne#reducenr(l:newvalue, l:siprefix)

	let l:basechar    = l:base==10? '':l:valstr[1+(l:sign != ''?1:0)]

	let l:newstr      = vimne#nr2str(l:newvalue, l:base, !empty(l:sign), l:basechar, [l:sisep, l:newsiprefix])

	call vimne#insert(l:newstr, l:append)
	call vimne#movecursor(-l:unitsize)
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
