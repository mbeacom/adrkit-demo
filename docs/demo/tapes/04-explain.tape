Output "docs/demo/04-explain.gif"
Output "docs/demo/04-explain.mp4"
Set Shell bash
Set Width 1280
Set Height 720
Set FontSize 18
Set Padding 24
Set Theme "Catppuccin Mocha"
Set TypingSpeed 35ms
Set WindowBar Colorful
Hide
Type "export PATH=$PWD/node_modules/.bin:$PATH PS1='ledger $ ' && clear"
Enter
Sleep 500ms
Show
Type "adr explain src/money/amount.ts"
Enter
Sleep 2.5s
Type "adr explain src/handlers/transfers.ts"
Enter
Sleep 2.5s
Type "clear"
Enter
Sleep 300ms
Type "adr explain src/ledger/legacy-balance-row.ts"
Enter
Sleep 5s
