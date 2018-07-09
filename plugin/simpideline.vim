let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_simpideline') || v:version < 700
  finish
endif
let g:loaded_simpideline = 1


let g:currentmode={
    \ 'n'  : 'NORMAL',
    \ 'no' : 'N·Operator Pending',
    \ 'v'  : 'VISUAL',
    \ 'V'  : 'V·Line',
    \ '' : 'V·Block',
    \ 's'  : 'Select',
    \ 'S'  : 'S·Line',
    \ '' : 'S·Block',
    \ 'i'  : 'INSERT',
    \ 'R'  : 'Replace',
    \ 'Rv' : 'V·Replace',
    \ 'c'  : 'Command',
    \ 'cv' : 'Vim Ex',
    \ 'ce' : 'Ex',
    \ 'r'  : 'Prompt',
    \ 'rm' : 'More',
    \ 'r?' : 'Confirm',
    \ '!'  : 'Shell',
    \ 't'  : 'Terminal'
    \}

function! FileSize(f)
	let l:size = getfsize(expand(a:f))
	if l:size == 0 || l:size == -1 || l:size == -2
		return ''
	endif
	if l:size < 1024
		return l:size.'B'
	elseif l:size < 1024*1024
		return printf('%.1f', l:size/1024.0).'K'
	elseif l:size < 1024*1024*1024
		return printf('%.1f', l:size/1024.0/1024.0).'M'
	else 
		return printf('%.1f', l:size/1024.0/1024.0/1024.0).'G'
	endif
endfunction

function! FilePath()
	if &filetype ==# 'startify'
		return ''
	else
		return expand('%:p:t')
	endif
endfunction

function! AleError()
	if exists('g:loaded_ale')
		let l:counts = ale#statusline#Count(bufnr(''))
			return l:counts[0] == 0 ? '' : '•'.l:counts[0]
	endif
	return ''
endfunction

function! AleWarning()
	if exists('g:loaded_ale')
    let l:counts = ale#statusline#Count(bufnr(''))
    return l:counts[1] == 0 ? '' : '•'.l:counts[1]
  endif
  return ''
endfunction

function! Fugitive()
	if exists('g:loaded_fugitive')
		let l:head = fugitive#head()
		let l:symbol = s:font ? " \ue0a0 " : ' ⎇ '
		return empty(l:head) ? '' : l:symbol.l:head . ' '
	endif
	return ''
endfunction

function! Gitgutter()
	if exists('b:gitgutter')
		let l:summary = get(b:gitgutter, 'summary', [0, 0, 0])
		if l:summary[0] != 0 || l:summary[1] != 0 || l:summary[2] != 0
			return ' +'.l:summary[0].' ~'.l:summary[1].' -'.l:summary[2].' '
		endif
	endif
	return ''
endfunction

function! s:MyStatusLine()
	let l:mode = "%1* %{g:currentmode[mode()]} %*"
	let l:envs = '%#envs_name#%{virtualenv#statusline()}'
	let l:fs = '%3* %{FileSize(@%)} %*'
	let l:fp = '%4* %{FilePath()} %*'
	let l:branch = '%6*%{Fugitive()}%*'
	let l:gutter = '%{Gitgutter()}'
	let l:ale_e = '%#ale_error#%{AleError()}%*'
	let l:ale_w = '%#ale_warning#%{AleWarning()}%*'
	let l:m_r_f = '%7* %m%r%y %*'
	let l:pos = '%8* %l/%L:%c |'
	let l:enc = " %{''.(&fenc!=''?&fenc:&enc).''} | %{(&bomb?\",BOM\":\"\")}"
	let l:ff = '%{&ff} | %*'
	let l:pct = '%9*%p%% %*'

	return l:mode.l:envs.'%<'.l:fp.l:fs.l:branch.l:gutter.l:ale_e.l:ale_w.
        \ '%='.l:m_r_f.l:pos.l:enc.l:ff.l:pct
endfunction

let s:colors = {
            \   33:'#0087ff', 140 : '#af87d7', 149 : '#99cc66', 160 : '#d70000',
            \   171 : '#d75fd7', 178 : '#ffbb7d', 184 : '#ffe920',
            \   208 : '#ff8700', 232 : '#333300', 197 : '#cc0033',
            \   214 : '#ffff66',
            \
            \   235 : '#262626', 236 : '#303030', 237 : '#3a3a3a',
            \   238 : '#444444', 239 : '#4e4e4e', 240 : '#585858',
            \   241 : '#606060', 242 : '#666666', 243 : '#767676',
            \   244 : '#808080', 245 : '#8a8a8a', 246 : '#949494',
            \   247 : '#9e9e9e', 248 : '#a8a8a8', 249 : '#b2b2b2',
            \   250 : '#bcbcbc', 251 : '#c6c6c6', 252 : '#d0d0d0',
            \   253 : '#dadada', 254 : '#e4e4e4', 255 : '#eeeeee',
            \ }

function! s:hi(group, fg, bg, ...)
  execute printf('hi %s ctermfg=%d guifg=%s ctermbg=%d guibg=%s',
                \ a:group, a:fg, s:colors[a:fg], a:bg, s:colors[a:bg])
  if a:0 == 1
    execute printf('hi %s cterm=%s gui=%s', a:group, a:1, a:1)
  endif
endfunction

if !exists('g:simpideline_background')
  let s:normal_bg = synIDattr(synIDtrans(hlID('Normal')), "bg", 'cterm')
  if s:normal_bg >= 233 && s:normal_bg <= 243
    let s:bg = s:normal_bg
  else
    let s:bg = 235
  endif
else
  let s:bg = g:simpideline_background
endif

" Don't change in gui mode
if has('termguicolors') && &termguicolors
  let s:bg = 235
endif

function! s:hi_statusline()
  call s:hi('User1'      , 232 , 178  )
  call s:hi('envs_name'      , 232 , 33 )
  call s:hi('User2'      , 178 , s:bg+8 )
  call s:hi('User3'      , 250 , s:bg+6 )
  call s:hi('User4'      , 171 , s:bg+4 , 'bold' )
  call s:hi('User5'      , 208 , s:bg+3 )
  call s:hi('User6'      , 184 , s:bg+2 , 'bold' )

  call s:hi('gutter'      , 184 , s:bg+2)
  call s:hi('ale_error'   , 197 , s:bg+2)
  call s:hi('ale_warning' , 214 , s:bg+2)

  call s:hi('StatusLine' , 140 , s:bg+2 , 'none')

  call s:hi('User7'      , 249 , s:bg+3 )
  call s:hi('User8'      , 250 , s:bg+4 )
  call s:hi('User9'      , 251 , s:bg+5 )
endfunction

function! InsertStatuslineColor(mode)
  if a:mode == 'i'
    call s:hi('User1' , 251 , s:bg+8 )
  elseif a:mode == 'r'
    call s:hi('User1' , 232 ,  160 )
  else
    call s:hi('User1' , 232 , 178  )
  endif
endfunction

" Note that the "%!" expression is evaluated in the context of the
" current window and buffer, while %{} items are evaluated in the
" context of the window that the statusline belongs to.
function! SetMyStatusline(timer) abort
  let &statusline = s:MyStatusLine()
  " User-defined highlightings shoule be put after colorscheme command.
  call s:hi_statusline()
endfunction

if exists('*timer_start')
  call timer_start(100, 'SetMyStatusline')
else
  call SetMyStatusline('')
endif

augroup simpideline
  autocmd!
  autocmd ColorScheme * call s:hi_statusline()
  " Change colors for insert mode
  autocmd InsertEnter * call InsertStatuslineColor(v:insertmode)
  autocmd InsertChange * call InsertStatuslineColor(v:insertmode)
  autocmd InsertLeave * call s:hi('User1' , 232 , 178  )
augroup END

let &cpoptions = s:save_cpo
unlet s:save_cpo


