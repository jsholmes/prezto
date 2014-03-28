# check for whether we're in an HRT environment or not

if [[ -w /hrt/home/john ]]; then
    echo "HRT live environment -- /hrt/home writable"
    export AT_HRT='yes'
    export SCRATCH_DIR='/hrt/home/john'
    export ZDOTDIR='/hrt/home/john'
    export HRT_ENV='live'
elif [[ -w /home/john ]]; then
    echo "HRT dev environment -- /home writable"
    export AT_HRT='yes'
    export SCRATCH_DIR='/home/john'
    export HRT_ENV='dev-user'
elif [[ -w /scratch/john ]]; then
    echo "HRT sched environment -- dev network - homeless -- using /scratch/john"
    export AT_HRT='yes'
    export SCRATCH_DIR='/scratch/john'
    export HRT_ENV='dev'
else
    echo "NON-HRT environment -- using $HOME for scratch dir"
    export SCRATCH_DIR='$HOME'
    export HRT_ENV='non'
fi

# check for remote development scripts
if [[ -e ~/Documents/HRTCryptVol ]]; then
    alias hrtmount="~/remote.py --mount ~/Documents/HRTCryptVol --at /Volumes/hrtsrc"
    alias hrtunmount="~/remote.py --unmount ~/Documents/HRTCryptVol --at /Volumes/hrtsrc"
fi

if [[ -e ~/hrtsrc/.remote  ]]; then
    PATH=$PATH:~/hrtsrc/.remote/bin:~/hrtsrc/.remote/versioned/bin:/abin:~/bin
fi

alias setupvtune="source /opt/intel/vtune_amplifier_xe_2013/amplxe-vars.sh"

if [[ -n $AT_HRT ]]; then
    # Store history on a scratch directory that any HRT box can reach, if we can
    # access the appropriate directory
    HISTFILE=$SCRATCH_DIR/.zsh_history
    echo "Using history file $HISTFILE"

    #
    # HRT Aliases
    #

    alias field='/home/bmorcos/perl/field.pl'
    alias cld='/home/bmorcos/perl/field.pl ,'
    alias stats='/home/bmorcos/perl/statistics.pl'
    alias total='/home/bmorcos/opsbin/total'

    alias netlog='less +F /usr/scratch/netlog/inetlog.`date "+%Y%m%d"`'

    alias contacts='/opsbin/readContacts.pl'
    alias tron=/systems/bin/tron

    ######
    # algo / sim related stuff
    ######
    # get the conf files out of laqur lines (typically grep laqur and pipe it in)
    alias laqconf='perl -pe "s/^[^,]+://" | grep "^'\''y" | awk "{print \$8}" FS=, | awk "{print \$3}" | grep home'
    alias atl='sudo -E -u atl zsh'

    # grep laqur for something
    laqgrep() {
        if (( $# != 1 )) then
            echo "usage: laqgrep regex"
            return 1
        fi
        egrep "$1" /atl/live/conf/laqur/*.conf
    }

    mktdaterange() {
        if (( $# != 2 )) then
            echo "usage: mktdaterange <start> <end>"
            return 1
        fi

        start=$1
        end=$2
        dates=`ssh shinfra5 /abin/mktdates -a -s $1 -e $2`
        echo $dates
    }

    prepperfsims() {
        if (( $# != 1 )) then
            if (( $# != 3 )) then
                echo "usage: prepsims <regex> [finalbool/test.1] [trunk]"
                return 1
            fi
        fi

        # the crazy syntax to split a command by lines into an array:
        # foo=("${(@f)$(command)}")
        lines=("${(@f)$(laqgrep $1)}")

        # we'll keep a confs --> clientid map in here
        typeset -A confs

        for l in $lines; do
            cid=`echo $l | sed "s/'//g" | awk -F, '{print $4 "." $5}'`
            conf=`echo $l | laqconf`
            confs[$conf]=$cid
        done

        local trunk="trunk"
        if (( $# >= 3 )) then
            trunk=$3
        fi

        local binary="/home/$USER/crypt/$trunk/fbsd8/bin/btrade/btrade"
        echo "using binary " $binary

        if [[ ! -x $binary ]] {
            print "No such binary " $binary
            return 4
        }

        frunname="perf.frun"
        dates=(20130925)

        # output directory:
        local projbase="/usr/scratch/john/projects/"
        local project="finalbool/test.1"
        if (( $# >= 2 )) then
            project=$2
        fi

        dir=${projbase}$project
        if [[ ! -d $dir ]] {
            print "No directory " $dir " exists -- creating"
            mkdir -p $dir
        }

        local frunfile=$dir/$frunname
        echo "Creating frun file at " $frunfile "..."

        # actually make the frun file
        echo "# test for " $dir " " $start " - " $end >! $frunfile

        # todo: copy conf files

        for date in $dates; do
            echo "  for " $date
            echo "# " $date >> $frunfile
            for conf in ${(k)confs}; do
                cid=$confs[$conf]
                #echo $conf " --> " $confs[$conf]
                printf '%s -f %s -s %s -c %s > %s/%s.%s.out\n' $binary $conf $date $cid $dir $cid $date $dir $cid $date >> $frunfile
            done
        done

        # set up the gntraday frun file
        local gntradayfrun=$dir/gntraday.$frunname
        echo "gntraday frun at " $gntradayfrun
        echo "#gntraday frun" >! $gntradayfrun
        for date in $dates; do
            echo 'cd ' $dir " &&  (cat *."$date".trades | /abin/gntraday > " $date".gntraday)" >> $gntradayfrun
        done

        echo "Done"
    }

    # prepare an frun file to run sims
    prepsims() {
        if (( $# != 1 )) then
            if (( $# != 3 )) then
                echo "usage: prepsims <regex> [finalbool/test.1] [trunk]"
                return 1
            fi
        fi

        # the crazy syntax to split a command by lines into an array:
        # foo=("${(@f)$(command)}")
        lines=("${(@f)$(laqgrep $1)}")

        # we'll keep a confs --> clientid map in here
        typeset -A confs

        for l in $lines; do
            cid=`echo $l | sed "s/'//g" | awk -F, '{print $4 "." $5}' | awk '{if (length($0) > 8) {print substr($0, 1, 2) "j" substr($0, 4,15);} else print $0}'`
            conf=`echo $l | laqconf`
            confs[$conf]=$cid
        done

        local trunk="trunk"
        if (( $# >= 3 )) then
            trunk=$3
        fi

        local binarysrc="/home/$USER/crypt/$trunk/fbsd8/bin.debug/btrade/btrade"
        echo "using binary " $binarysrc

        if [[ ! -x $binarysrc ]] {
            print "No such binary " $binarysrc
            return 4
        }

        local start=20130701
        local end=20130925
        local frunname="frun"
        dates=("${(@f)$(mktdaterange $start $end)}")

        # output directory:
        local projbase="/scratch/john/projects/"
        local project="finalbool/test.1"
        if (( $# >= 2 )) then
            project=$2
        fi

        dir=${projbase}$project
        if [[ ! -d $dir ]] {
            print "No directory " $dir " exists -- creating"
            mkdir -p $dir
        }

        local binarydest="$dir/btrade"
        echo "Copying " $binarysrc " to " $binarydest " ..."
        cp $binarysrc $binarydest

        local frunfile=$dir/$frunname
        echo "Creating frun file at " $frunfile "..."

        # actually make the frun file
        echo "# test for " $dir " " $start " - " $end >! $frunfile

        # todo: copy conf files

        for date in $dates; do
            echo "  for " $date
            echo "# " $date >> $frunfile
            for conf in ${(k)confs}; do
                cid=$confs[$conf]
                #echo $conf " --> " $confs[$conf]
                printf '%s -f %s -s %s -c %s -x %s/%s.%s.trades > %s/%s.%s.out\n' $binarydest $conf $date $cid $dir $cid $date $dir $cid $date >> $frunfile
            done
        done

        # set up the gntraday frun file
        local gntradayfrun=$dir/gntraday.$frunname
        echo "gntraday frun at " $gntradayfrun
        echo "#gntraday frun" >! $gntradayfrun
        for date in $dates; do
            echo 'cd ' $dir " &&  (cat *."$date".trades | /abin/gntraday > " $date".gntraday)" >> $gntradayfrun
        done

        echo "Done"
    }

    cmpgntraday() {
        if (( $# > 1 )) then
            if (( $# != 3 )) then
                echo "usage: cmpgntraday <projname> [control] [experiment]"
                return 1
            fi
        elif (( $# != 1 )) then
            echo "usage: cmpgntraday <projname> [control] [experiment]"
            return 1
        fi

        local control="control"
        local experiment="test.1"

        local project=$1

        if (( $# == 3 )) then
            control=$2
            experiment=$3
        fi

        local projbase="/scratch/$USER/projects/$project"

        pushd $projbase/$control
        rm totals.txt
        grep TOTAL *.gntraday > totals.txt
        cd $projbase/$experiment
        rm totals.txt
        grep TOTAL *.gntraday > totals.txt
        popd

        joined=`join -j 1 -o 0,1.3,1.4,2.4,1.7,2.7 $projbase/$control/totals.txt $projbase/$experiment/totals.txt`
        printf "%20s %20s %8s %8s %8s %8s %10s %10s %10s %10s\n" "file" "client" "a_shares" "b_shares" "a_profit" "b_profit" "delta_shares" "shares_%" "delta_profit" "profit_%"
        echo $joined | awk '{if ($3 != 0) printf "%s %10d %10.1f%%  %10.2f %10.2f\n", $0, $4-$3, ($4-$3)*100/$3, $6-$5, ($6-$5)*100/$5}'
        ksdiff $projbase/$control/totals.txt $projbase/$experiment/totals.txt
    }

    autotest() {
        variant="fbsd8.quick"
        maxlevel="2"
        if (( $# > 0 )) then
            variant=$1
        fi
        if (( $# > 1 )) then
            maxlevel=$2
        fi
        atl/src/test/autotest/autotest.py --no-build --variant $variant --max-test-level $maxlevel
    }

    orderdiff() {
        oldscratch=$1
        newscratch=$2
        ordersfile=$3
        ksdiff =(/abin/slfview -X -v $oldscratch/orders/$ordersfile) =(/abin/slfview -X -v $newscratch/orders/$ordersfile)
    }


    # add my bin dir to path
    export PATH=$PATH:/home/john/bin

    # set malloc options to make testing work better
    export MALLOC_OPTIONS=J

    # default hrt environment stuff
    . /atl/make/atl.zshrc
fi

