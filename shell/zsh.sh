sudo () {
  local command=$@
  read -r "REPLY?Authorize command $(echo \"$@\") be  executed? (y/N): "
  if [[ "$REPLY" = [yY]* ]]; then
     command sudo "$@"
  else
     return $?
  fi
}
