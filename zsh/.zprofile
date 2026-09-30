# zsh de login não lê ~/.profile, que é quem põe ~/.local/bin no PATH.
if [[ -f "$HOME/.profile" ]]; then
  emulate sh -c '. "$HOME/.profile"'
fi
