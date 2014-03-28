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

#use zsh online help
#unalias run-help
#autoload -U run-help
#autoload run-help-git
#autoload run-help-svn
#autoload run-help-svk
#HELPDIR=/usr/local/share/zsh/helpfiles

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
alias t='task'

# I want to have sbin stuff in my path
path+=/usr/local/sbin
path+=/usr/sbin
path+=/sbin