" Vim syntax file
" Language:	SQL
" Maintainer:	dungtd10

if !exists("main_syntax")
   if exists("b:current_syntax")
      finish
   endif

   let main_syntax = 'sql'
elseif exists("b:current_syntax") && b:current_syntax == "sql"
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn match      sqlKeyword    "\(ADD\|CONSTRAINT\|ALTER\|COLUMN\|TABLE\|ALL\|AND\|ANY\|AS\|ASC\|BACKUP\|DATABASE\|BETWEEN\|CASE\|CHECK\|CREATE\|INDEX\|OR\|REPLACE\|VIEW\|PROCEDURE\|UNIQUE\|DEFAULT\|DROP\|EXEC\|EXISTS\|KEY\|FOREIGN\|FROM\|FULL\|OUTER\|JOIN\|GROUP\|BY\|HAVING\|IN\|INNER\|INTO\|IS\|NULL\|NOT\|LEFT\|LIKE\|LIMIT\|ORDER\|PRIMARY\|RIGHT\|ROWNUM\|DISTINCT\|TOP\|TRUNCATE\|UPDATE\|VALUES\|WHERE\|MIN\|MAX\|AVG\|COUNT\|SELECT\)"
syn match      sqlStr        "[a-zA-Z0-9_]\+"
syn match      sqlOperator   "[\.;\=><\(\)\*]"

hi def         sqlKeyword    guifg   =#d38aea  gui=bold,italic
hi def         sqlOperator   guifg   =#deb974  gui=italic
hi def link    sqlStr        String

let b:current_syntax = "sql"

if main_syntax == 'sql'
  unlet main_syntax
endif

let &cpo = s:cpo_save
unlet s:cpo_save
