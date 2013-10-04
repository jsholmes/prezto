if [[ -e ~/Documents/HRTCryptVol ]]; then
    #eval `~/remote.py --script ~/Documents/HRTCryptVol --at /Volumes/hrtsrc`

    #add /abin to path for git cl
    PATH=$PATH:~/hrtsrc/.remote/bin:~/hrtsrc/.remote/versioned/bin:/abin:~/bin

    alias hrtmount="~/remote.py --mount ~/Documents/HRTCryptVol --at /Volumes/hrtsrc"
    alias hrtunmount="~/remote.py --unmount ~/Documents/HRTCryptVol --at /Volumes/hrtsrc"
fi

# add /usr/local/sbin to path
PATH=/usr/local/sbin:$PATH

alias setupvtune="source /opt/intel/vtune_amplifier_xe_2013/amplxe-vars.sh"

if [[ -e ~/vimwiki ]]; then
    if [[ -x ack ]]; then
        vws () { ack -r -i -a $* ~/vimwiki }
    else
        vws () { grep -r -i $* ~/vimwiki } ;
    fi
    if [[ -x gitup ]]; then
        gitup ~/vimwiki
    fi
    alias vw='vim ~/vimwiki/index.wiki'
fi

if [[ -x gitup ]]; then
    gitup ~/.dotfiles
fi

# find only visible files:
alias findvis="find . \( ! -regex '.*/\..*' \)"

export EDITOR=vim

# use 256 colors in tmux
if [[ -x `which tmux` ]]; then
    alias tmux='TERM=screen-256color tmux'
    [[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
fi

if [[ -x `which colorsvn` ]]; then
    alias svn=colorsvn
fi

if [[ -x `which colordiff` ]]; then
    alias diff=colordiff
fi

# =============================================
# z plugin stuff
#
# Maintains a frequently used directory list for fast directory changes.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

if [[ -f /etc/profile.d/z.zsh ]]; then
  source /etc/profile.d/z.zsh
elif [[ -f /opt/local/etc/profile.d/z.zsh ]]; then
  source /opt/local/etc/profile.d/z.zsh
elif [[ -f "$(brew --prefix 2> /dev/null)/etc/profile.d/z.sh" ]]; then
  source "$(brew --prefix 2> /dev/null)/etc/profile.d/z.sh"
fi

if (( $+functions[_z] )); then
  alias z='nocorrect _z 2>&1'
  alias j='z'
  function z-precmd () {
    z --add "$(pwd -P)"
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd z-precmd
fi

# =============================================
