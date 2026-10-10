Output "docs/demo/06-check-violating.gif"
Output "docs/demo/06-check-violating.mp4"
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
Hide
Type "git switch -q demo/violating-change && clear"
Enter
Sleep 500ms
Show
Type "git diff --stat main"
Enter
Sleep 1.5s
Type "git diff main -- src/money | tail -n 9"
Enter
Sleep 2.5s
Type "clear"
Enter
Sleep 300ms
Type "adr check $(git diff --name-only main); echo exit=$?"
Enter
Sleep 7s
Hide
Type "git switch -q main"
Enter
Sleep 300ms
