"""""""""""""""""""""""""""""""""""""""
"{{{ Math functions """""""""""""""""""
"""""""""""""""""""""""""""""""""""""""
"{{{
function! vimne#calc#add(v, n)
	let l:n = a:n? a:n:1
	return a:v + l:n
endfunction
"}}}
"{{{
function! vimne#calc#subtract(v, n)
	let l:n = a:n? a:n:1
	return a:v - l:n
endfunction
"}}}
"{{{
function! vimne#calc#multiply(v, n)
	let l:n = a:n? a:n:2
	return a:v * l:n
endfunction
"}}}
"{{{
function! vimne#calc#divide(v, n)
	let l:n = a:n? a:n:2
	return a:v / l:n
endfunction
"}}}
"{{{
function! vimne#calc#multbypowerof2(v, n)
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
function! vimne#calc#divbypowerof2(v, n)
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
function! vimne#calc#fibo(p0, p1)
	return [a:p1, a:p0+a:p1]
endfunction
"}}}
"{{{
function! vimne#calc#nextfibonacci(v, n)
	let l:n   = a:n? a:n:1
	let l:p0  = 1
	let l:p1  = 1

	while l:p1 < a:v
		let [l:p0, l:p1] = vimne#calc#fibo(l:p0, l:p1)
	endwhile

	if l:p1 != a:v
		" not a fibonacci number
		return a:v
	endif

	while l:n
		let [l:p0, l:p1]  = vimne#calc#fibo(l:p0, l:p1)
		let l:n           = l:n - 1
	endwhile

	return l:p1
endfunction
"}}}
"{{{
function! vimne#calc#prevfibonacci(v, n)
	let l:n = a:n? a:n:1
	let l:p = [1, 1]

	while l:p[-1] < a:v
		let [l:ignore, l:next]  = vimne#calc#fibo(l:p[-2], l:p[-1])
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
"""""""""""""""""""""""""""""""""""""""
