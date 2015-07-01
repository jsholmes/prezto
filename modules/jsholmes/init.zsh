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

# set up go path
if [[ $platform == 'macos' ]]; then
    export GOPATH=$HOME/go
elif [[ $platform == 'linux' ]]; then
    export GOPATH=$HOME/go-linux
elif [[ $platform == 'freebsd' ]]; then
    export GOPATH=$HOME/go-bsd
else
    export GOPATH=$HOME/go
fi
path+=$GOPATH/bin

alias johnmac='mosh johnmac -- tmux a'

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# use Ctrl-r for incremental backsearch for the bash folks
bindkey '^r' history-incremental-search-backward

# pygmentizing version of less -- pless
pless() {
    # note less arguments:
    # -F -- quit if less than 1 screen
    # -i ignore case in searche
    # -X disables sending termcap init/deinit to avoid clearing screen, etc.
    # -R ANSI colors output in raw form
    # -M verbose less prompt
    # -x4 sets tab stops to 4
    if (($# == 0)) then
        pygmentize -f terminal256 -g -P style=monokai /dev/stdin | less -FiXRM -x4
    else
        pygmentize -f terminal256 -g -P style=monokai $* | less -FiXRM -x4
    fi
}

# function to get the short version of the current path
# requires PWD_LENGTH variable to be set
# defaults to 30, if not set
function get_short_path() {
  HOME_TIDLE="\/Users\/guy"
    LONG_PATH=`pwd | sed -e "s/$HOME_TIDLE/\~/"`

    # check to see if the prompt path length has been specified
    if [ ! -n "$PWD_LENGTH" ]; then
        export PWD_LENGTH=15
    fi

    if [ ${#LONG_PATH} -gt $PWD_LENGTH ]; then
            echo "...${LONG_PATH: -$PWD_LENGTH}"
    else
            echo $LONG_PATH
    fi
}


# HH config
# todo: maybe put this into its own plugin?
# add this configuration to ~/.zshrc
export HH_CONFIG=hicolor        # get more colors
bindkey -s "\C-r" "\eqhh\n"     # bind hh to Ctrl-r (for Vi mode check doc)


