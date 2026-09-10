#!/usr/bin/env bash

defaultLang=fr
mainLang=${1:-${defaultLang}}

TMP_DIR=$(mktemp -d XXXXXXXXXX --tmpdir)
TMP_ID=$(basename "${TMP_DIR}")

buildDir=$(realpath build)

# Variables to make it easily parametric later with ${2:-content} or such and maybe better arguments handling
content=content
private=private


function wt() {
  ## shorthand for adding a worktree in the tmp dir
  # wt <commit-ish> [<path>]
  # if no <path> is supplied then the <commit-ish>'ll be used in it's stead
  # ⚠⚠⚠ resorting to that default is a BAD IDEA ⚠⚠⚠
  # most <commit-ish> will be <remote>/<branch-name> witch will result in harder nested worktree paths to remove
  # I know I'll end up slapping together something to circumvent that problem with git worktree list | awk '/'"${TMP_DIR}"'/{print $0}' but that's a hassle nonetheless
    git worktree add -f --detach "${TMP_DIR}/${2:-${1}}" "${1}"
}

### Langs
if git branch --list --remotes | grep "${content}/i18n_${mainLang}" >/dev/null 2>&1
then
  echo -e "\e[1;93m----------------
⚠️ ⚠️ ⚠️  Something's off "'!!'" ⚠️ ⚠️ ⚠️\e[0m

    As per this run's config \e[1;97m${content}/main\e[0m branch's is supposed to contain lang:\e[1;97m${mainLang}\e[0m

  🍑 BUT 🍑

    a branch \e[1;97m${content}/i18n_${mainLang}\e[0m was found

    That could indicate inconsistencies so make sure that your main language is the one you set when running this script.
      \e[2m(if you haven't set one, be advised that the default language is \e[0;1;97m${defaultLang}\e[0m\e[0;2m)
\e[1;93m----------------
\e[0m" >&2
  exit 1
fi

wt "${content}/main" "i18n_${mainLang}"

for i18n_branch in $(git branch --list  --remotes | grep -v '\->' | grep "${content}/i18n_");
do
  lang=${i18n_branch##*/}
  wt "${i18n_branch}" "${lang}"
done

### Personal infos
wt "${private}/main" info-perso

### Themes
wt "${content}/themes" themes

(
  cd "${TMP_DIR}/themes" && npm install && ./dirtyPatchThemes.sh
)

### Actual Generation
mkdir -p "${buildDir}"
rm -fr "${buildDir:?}/"*

for langFolder in "${TMP_DIR}/i18n_"*
do
  lang=${langFolder##*_}
  (
    cd "${TMP_DIR}/info-perso" || { echo "${TMP_DIR}/info-perso does not exist" >&2; exit 1 ; }
    ./merge.sh "${langFolder:?}/resume.json" > "${langFolder:?}/resume-personalized.json"
  ) || { echo "Failed at unredacting ${lang}" >&2; exit 1 ; }

  (
    cd "${TMP_DIR}/themes" && \
      ./generate.sh \
          "${lang}" \
          "${langFolder:?}/resume-personalized.json" \
          "${buildDir:?}/resume-${lang}.pdf"
  )
done

for worktree in "${TMP_DIR}/"*
do
  git worktree remove --force "${worktree}"
done
