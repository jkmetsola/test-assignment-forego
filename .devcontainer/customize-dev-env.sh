#!/bin/bash
# shellcheck disable=SC1091
source .env
set -u
{
# shellcheck disable=SC2016
printf '
parse_git_branch() {
  if [ -n "$(git rev-parse --git-dir 2> /dev/null)" ]; then
    echo "($(git rev-parse --abbrev-ref HEAD)) "
  fi
}

export LS_OPTIONS="--color=auto"
eval "$(dircolors)"
alias ls="ls $LS_OPTIONS"
alias ll="ls $LS_OPTIONS -l"
alias l="ls $LS_OPTIONS -lA"


PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
PS1="${PS1}\[\033[01;33m\]\$(parse_git_branch)\[\033[00m\]"
export PS1

'
echo "
git config --global user.email \"$GIT_EMAIL\"
git config --global user.name \"$GIT_USER\"
git config --global pager.diff true
"
} >> ~/.bashrc


cp .git/hooks/pre-commit.sample .git/hooks/pre-commit
# shellcheck disable=SC2016
sed -i 's|exec git diff-index --check --cached $against --|git diff-index --check --cached $against --|' .git/hooks/pre-commit
{
  echo ""
  # echo "robotidy --diff --check hsl-api/tests/robot"
  # echo "robocop hsl-api/tests/robot"
  echo "ruff check --exclude .vscode-server"
  echo "ruff format --exclude .vscode-server --diff"
  echo "shellcheck \$(find . -type f -name '*.sh')"
  echo "hadolint Dockerfile"
  echo "actionlint -ignore 'workflow is empty'"
} >> .git/hooks/pre-commit
