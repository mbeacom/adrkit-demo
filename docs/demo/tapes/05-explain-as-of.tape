Output "docs/demo/05-explain-as-of.gif"
Output "docs/demo/05-explain-as-of.mp4"
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
Type "# Which decisions governed the ledger today, and on 2025-09-01?"
Enter
Type "adr explain src/ledger/events.ts"
Enter
Sleep 2.5s
Type "clear"
Enter
Sleep 300ms
Type "adr explain src/ledger/events.ts --as-of 2025-09-01"
Enter
Sleep 6s
