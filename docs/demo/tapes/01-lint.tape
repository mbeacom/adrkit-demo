Output "docs/demo/01-lint.gif"
Output "docs/demo/01-lint.mp4"
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
Type "# Nine decision records, validated against adrkit's schema"
Enter
Type "ls docs/adr"
Enter
Sleep 1.5s
Type "adr lint"
Enter
Sleep 3s
