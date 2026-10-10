Output "docs/demo/08-review-accept.gif"
Output "docs/demo/08-review-accept.mp4"
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
Type "W=$(mktemp -d) && cp -R docs $W/ && cp -R docs $W/before && cd $W && clear"
Enter
Sleep 500ms
Show
Type "# A throwaway copy of docs/, never the pushed main"
Enter
Type "adr approve 0009 --by @mbeacom"
Enter
Sleep 2s
Type "adr accept 0009 --by @mbeacom"
Enter
Sleep 2.5s
Type "adr resolve 0009 --objection 1 --by @hubot"
Enter
Sleep 2s
Type "clear"
Enter
Sleep 300ms
Type "adr queue --format terminal"
Enter
Sleep 3s
Type "adr accept 0009 --by @mbeacom"
Enter
Sleep 2.5s
Type "git diff --no-index -U0 before/adr/0009-*.md docs/adr/0009-*.md"
Enter
Sleep 6s
