Output "docs/demo/03-graph-focus.gif"
Output "docs/demo/03-graph-focus.mp4"
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
Type "# One record and its direct neighborhood"
Enter
Type "adr graph --focus 0006"
Enter
Sleep 4s
