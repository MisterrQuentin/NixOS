# modules/shell-script.sh
export ZDOTDIR=$PWD/.nix-shell-config
export EDITOR=nvim
mkdir -p $ZDOTDIR
cat > $ZDOTDIR/.zshrc << 'EOF'
# Nice prompt with directory and git info
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%F{yellow}(%b)%f '
setopt PROMPT_SUBST
PS1='%F{blue}[nix-shell]%f %F{green}%~%f $vcs_info_msg_0_%# '
alias ll='ls -la'
alias v=nvim
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
export EDITOR=nvim
EOF

