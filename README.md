# Marp cli Usage

## Convert slide deck into HTML
npx @marp-team/marp-cli@latest slide-deck.md
npx @marp-team/marp-cli@latest slide-deck.md -o output.html

## Convert slide deck into PDF
npx @marp-team/marp-cli@latest slide-deck.md --pdf
npx @marp-team/marp-cli@latest slide-deck.md -o output.pdf

## Convert slide deck into PowerPoint document (PPTX)
npx @marp-team/marp-cli@latest slide-deck.md --pptx
npx @marp-team/marp-cli@latest slide-deck.md -o output.pptx

## Watch mode
npx @marp-team/marp-cli@latest --html -w slide-deck.md

## preview
npx @marp-team/marp-cli@latest --html -p slide-deck.md

## Server mode (Pass directory to serve)
npx @marp-team/marp-cli@latest --html -s ./slides
