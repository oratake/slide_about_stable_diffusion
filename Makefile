dev:
	npx @marp-team/marp-cli@latest --html -p slide-deck.md
watch:
	npx @marp-team/marp-cli@latest --html -w slide-deck.md
build:
	npx @marp-team/marp-cli@latest --html slide-deck.md -o output.html
serve:
	npx @marp-team/marp-cli@latest --html -s .
