[ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)"

sudo () {
  local command=$@
  read -r "REPLY?Authorize command $(echo \"$@\") be  executed? (y/N): "
  if [[ "$REPLY" = [yY]* ]]; then
     command sudo "$@"
  else
     return $?
  fi
}

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

export PATH=$HOME/.my-setup/bin:$PATH