#!/usr/bin/env bash

lang=${1:?}
src=${2}
out=${3}

#Faire un truc mieux un jour avec un dictionnaire externalisé mais là jais la fucking flemme
declare -A themesByLang=(\
  [fr]=jdambron-fr \
  [default]=jdambron \
)

resume export -r "${src}" "${out}" --theme "${themesByLang["${lang:?}"]:-${themesByLang[default]}}"
