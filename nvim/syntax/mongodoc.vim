" Vim syntax file
" Language:	MONGODB DOCUMENT
" Maintainer:	dungtd10

if !exists("main_syntax")
   if exists("b:current_syntax")
      finish
   endif

   let main_syntax = "mongodoc"
elseif exists("b:current_syntax") && b:current_syntax == "mongodoc"
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn match      mongodocString     "\".*\""
syn match      mongodocKey        "\('\|\"\)[a-zA-Z0-9_]\+\('\|\"\)\s:"
syn match      mongodocNumber     "\s\{1}-*\d\+\.*\d*"
syn match      mongodocBoolean    "\s\{1}\(true\|false\|null\|ISODate\|ObjectId\)"
syn match      mongodocOperator   "[;\=><\(\)\{\}\*\[\],]"
syn region     mongodocComment    start="================" end="================"

hi def link    mongodocString     String
hi def link    mongodocComment    Comment
hi def         mongodocKey        guifg   =#5dbbc1
hi def         mongodocBoolean    guifg   =#d38aea
hi def         mongodocNumber     guifg   =#d38aea
hi def         mongodocOperator   guifg   =#deb974  gui=italic

let b:current_syntax = "mongodoc"

if main_syntax == "mongodoc"
  unlet main_syntax
endif

let &cpo = s:cpo_save
unlet s:cpo_save
