#!/bin/env ksh
# v0.2.1  2023  mountaineerbr  GPLv3+
# Generate man pages from a pandoc markdown file.

set -f -x

OUT=${1%%.[Mm][Dd]} OUT=${OUT%%.[0-9]}

[[ ${1:?markdown file required} = *[Mm][Dd] ]] || return

pandoc --standalone --to man "$1" -o "$OUT".1

pandoc --standalone --to plain "$1" -o "$OUT".txt

pandoc --standalone --to html "$1" -o "$OUT".html

pandoc --standalone --to gfm "$1" -o "$(dirname "$1")"/README.md


#https://eddieantonio.ca/blog/2015/12/18/authoring-manpages-in-markdown-with-pandoc/
#https://jeromebelleman.gitlab.io/posts/publishing/manpages/
