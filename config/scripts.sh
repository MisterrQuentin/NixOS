#!/bin/bash

cd() {
  case "$1" in
    ...) builtin cd ../.. ;;
    ....) builtin cd ../../.. ;;
    .....) builtin cd ../../../.. ;;
    ......) builtin cd ../../../../.. ;;
    *) builtin cd "$@" ;;
  esac
}

function main(){
  cmd="$(grep '^function' "$0"|grep -v "function main"|awk '{print $2}'|cut -d\( -f1|fzf --prompt "Please Make a Selection")"
  $cmd
  exit 0
}
#
# # ex - archive extractor
# # usage: ex <file>
function ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.tar.xz)    tar xJf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

function compress() {
    tar cvzf $1.tar.gz $1
}

function ftmuxp() {
    if [[ -n $TMUX ]]; then
        return
    fi
    
    # get the IDs
    ID="$(ls $XDG_CONFIG_HOME/tmuxp | sed -e 's/\.yml$//')"
    if [[ -z "$ID" ]]; then
        tmuxp load chris
    fi

    create_new_session="Attach to or create last session"

    ID="${create_new_session}\n$ID"
    ID="$(echo $ID | fzf | cut -d: -f1)"

    if [[ "$ID" = "${create_new_session}" ]]; then
        tmuxp load chris
    elif [[ -n "$ID" ]]; then
        # Rename the current urxvt tab to session name
        printf '\033]777;tabbedx;set_tab_name;%s\007' "$ID"
        tmuxp load "$ID"
    fi
}

function sel_files() {
  dir=$1
  prog=$2
  cd $dir
	choice="$(fd . | fzf)"
	[ -f "$dir$choice" ] && $prog "$dir$choice" &
  echo "You just viewed: $dir$choice"
}

show_alias() {
  alias "$1" | cut -d= -f 2- | sed "s/'//g"
}

function proxy_on() {
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"

    if (( $# > 0 )); then
        valid=$(echo $@ | sed -n 's/\([0-9]\{1,3\}.\?\)\{4\}:\([0-9]\+\)/&/p')
        if [[ $valid != $@ ]]; then
            >&2 echo "Invalid address"
            return 1
        fi
        local proxy=$1
        export http_proxy="$proxy" \
               https_proxy=$proxy \
               ftp_proxy=$proxy \
               rsync_proxy=$proxy
        echo "Proxy environment variable set."
        return 0
    fi

    local pre="socks5://"
    local server="127.0.0.1"
    local port="20170"
    local proxy=$pre$server:$port
    export http_proxy="$proxy" \
           https_proxy=$proxy \
           ftp_proxy=$proxy \
           rsync_proxy=$proxy \
           HTTP_PROXY=$proxy \
           HTTPS_PROXY=$proxy \
           FTP_PROXY=$proxy \
           RSYNC_PROXY=$proxy
}

function proxy_off(){
    unset http_proxy https_proxy ftp_proxy rsync_proxy \
          HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY
    echo -e "Proxy environment variable removed."
}

##md() { pandoc "$1" | lynx -stdin; }
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
# open man page in vim
function vman() {
    nvim -c "SuperMan $*"

    if [ "$?" != "0" ]; then
        echo "No manual entry for $*"
    fi
}

function urlencode()
{
  local args="$@"
  jq -nr --arg v "$args" '$v|@uri'; 
}

function duckduckgo() {
    lynx -vikeys -accept_all_cookies "https://lite.duckduckgo.com/lite/?q=$(urlencode "$@")"
}

function wikipedia() {
    lynx -vikeys -accept_all_cookies "https://en.wikipedia.org/wiki?search=$(urlencode "$@")"
}
localip() {
  ifconfig wlan0 |grep 'inet '| awk '{print $2}'
}
myip() {
    ip -f inet address | grep inet | grep -v 'lo$' | awk '{print $2, $NF}' | sort | cut -d ' ' -f 1,2
    external_ip=$(curl -s ifconfig.me)
    location=$(curl -s -f "https://ipinfo.io/$external_ip/city" || echo "Unknown")
    country=$(curl -s -f "https://ipinfo.io/$external_ip/country" || echo "Unknown")
    echo "$external_ip external ip ($location, $country)"
}
function space() {
  du -h -d 1 $1 | sort -rh
}
