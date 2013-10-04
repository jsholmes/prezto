if [[ -e ~/Documents/HRTCryptVol ]]; then
    #eval `~/remote.py --script ~/Documents/HRTCryptVol --at /Volumes/hrtsrc`

    #add /abin to path for git cl
    PATH=$PATH:~/hrtsrc/.remote/bin:~/hrtsrc/.remote/versioned/bin:/abin:~/bin

    alias hrtmount="~/remote.py --mount ~/Documents/HRTCryptVol --at /Volumes/hrtsrc"
    alias hrtunmount="~/remote.py --unmount ~/Documents/HRTCryptVol --at /Volumes/hrtsrc"
fi

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

# find only visible files:
alias findvis="find . \( ! -regex '.*/\..*' \)"

# vim is my editor of choice
export EDITOR=vim

# use 256 colors in tmux
if [[ -x `which tmux` ]]; then
    alias tmux='TERM=screen-256color tmux'
    [[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator
fi

alias grep='egrep'
alias g='egrep'
alias cawk='awk -F ,'
