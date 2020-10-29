set noclobber

if [[ -z "$PS1" ]] ; then
  return
fi

function gf
{
  case $# in
    1) find .  -name "$1";;
    2) find .  -name "$1" | xargs grep $2;;
    3) find $1 -name "$2" | xargs grep $3;;
    *)
  esac
}

function gfl
{
  case $# in
    1) find .  -name "$1";;
    2) find .  -name "$1" | xargs grep -l $2;;
    3) find $1 -name "$2" | xargs grep -l $3;;
    *)
  esac
}

function gfi
{
  case $# in
    1) find .  -name "$1";;
    2) find .  -name "$1" | xargs grep -i $2;;
    3) find $1 -name "$2" | xargs grep -i $3;;
    *)
  esac
}

#export ENV=~/.kshenv
#HISTIGNORE="[   ]*:&:bg:fg"
export EDITOR="vim"

psgrep()
{
  ps -aux | grep $1 | egrep -iv "grep|xterm|fvwm"
}

# like `zap' from Kernighan and Pike
pskill()
{
  local pid

  pid=$(ps -ax | grep $1 | grep -v grep | awk '{ print $1 }')
  echo -n "killing $1 (process $pid)..."
  kill -9 $pid
  echo "slaughtered."
}

xtitle()
{
  echo -n -e "\033]0;$*\007"
}

#function cd()
#{
#  if [[ $# == 0 ]]  ; then
#    builtin cd "$@" && xtitle $HOST: $PWD
#  elif [[ $# == 1 ]]  ; then
#    if [[ -f $1 ]]  ; then
#      x=`dirname $1`
#      builtin cd $x && xtitle $HOST: $PWD
#      unset x
#    else
#      builtin cd "$@" && xtitle $HOST: $PWD
#    fi
#  else
#    builtin cd "$@" && xtitle $HOST: $PWD
#  fi
#}

function setenv()
{
  if [[ $# -ne 2 ]]  ; then
    echo "setenv: Too few arguments"
  else
    export $1="$2"
  fi
}

#export PAGER=less

## pure bash stuff
#export PS1="\W \$ "
#export PS1="\h:\w > \[$(tput sgr0)\]"
export PS1="\[$(tput bold)\]\[\033[38;5;31m\]\h:\w > \[$(tput sgr0)\]"
#set -o vi
#set editing-mode vi
#set keymap vi
#bind -m vi
#set notify
#set history_control=ignoredups
#set command_oriented_history
#set hostname_completion_file
#set noclobber
#set horizontal-scroll-mode
#set editing-mode vi
#set mark-modified-lines
#set prefer-visible-bell

#FCEDIT=$EDITOR
#FIGNORE=CVS:.dsn:.class:.so:.o:.bak:.tab.c:.tab.h:.vim:.aux:.lof:.toc:.:%:~
#MAILCHECK=15
# unlimited core size
#ulimit -c unlimited
#ulimit -c 0
#CDPATH=.:~

function vi
{
   if [[ $# == 0 ]]  ; then
     $EDITOR
   elif [[ $# == 1 ]]  ; then
     if [[ -d $1 ]]  ; then
       echo "$1 is a dir";
     else
       $EDITOR $1
     fi
   else
     $EDITOR $*
   fi
}

function pv
{
   case $# in
     1) env | grep $1;;
     *) env | less;;
   esac
}

function tp
{
   ls -l `type -path $1`
}

function tpp
{
   type -path $1
}

function cte
{
   crontab -e
}

function cle
{
   crontab -l | grep -v "^#"
}

function add
{
    echo "$1 $2+p.q" | /usr/bin/dc
}

function mul
{
    echo "$1 $2*p.q" | /usr/bin/dc
}
function div
{
    echo "$1 $2/p.q" | /usr/bin/dc
}

function vix
{
   xx=`builtin type -path $1`
   test -f $xx && $EDITOR $xx
}

#alias sshs1='ssh erics@10.1.20.52'
#alias sshs2='ssh erics@10.1.20.53'
#alias sshnfs='ssh erics@10.1.20.54'

source /project/tools/Modules/mod_bash
source /home/erics/.alias

export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'

export GREP_OPTIONS='--directories=skip --exclude=*entries --exclude=*.svn-base --exclude=*.pyc --exclude=*.tmp --exclude=.nfs*'


export WORK='/project/users/erics'
export VISUAL='vim'
#export PATH=/home/pjoshi/bin/python27/bin:$PATH:/project/tools/python3.6/bin/
#export PATH=$PATH:/project/tools/python3.6/bin/

#bind '"\t":menu-complete'

function sb
{
  if [[ -d $1 ]]  ; then
      cd $1
      export ROOT_DIR=$PWD
  else
      export ROOT_DIR=/project/users/erics/work/$1
  fi
  module use $ROOT_DIR/mod
#  export MODULEPATH==/project/users/erics/work/$1/mod:.
  module purge
  module load ${ROOT_DIR}/mod/desmods
  cd $ROOT_DIR
}

function s1
{
  if [[ -d $1 ]]  ; then
      cd $1
      export ROOT_DIR=$PWD
  else
      export ROOT_DIR=/project/users/erics/work/$1
  fi
  module use $ROOT_DIR/mod
#  export MODULEPATH==/project/users/erics/work/$1/mod:.
  module purge
  module add chip/s1
  cd $ROOT_DIR
}

function f2
{
  if [[ -d $1 ]]  ; then
      cd $1
      export ROOT_DIR=$PWD
  else
      export ROOT_DIR=/project/users/erics/work/$1
  fi
  module use $ROOT_DIR/mod
#  export MODULEPATH==/project/users/erics/work/$1/mod:.
  module purge
  module add chip/f2
  cd $ROOT_DIR
}

function f1d1
{
  if [[ -d $1 ]]  ; then
      cd $1
      export ROOT_DIR=$PWD
  else
      export ROOT_DIR=/project/users/erics/work/$1
  fi
  module use $ROOT_DIR/mod
#  export MODULEPATH==/project/users/erics/work/$1/mod:.
  module purge
  module add chip/f1d1
  cd $ROOT_DIR
}

function f1
{
  if [[ -d $1 ]]  ; then
      cd $1
      export ROOT_DIR=$PWD
  else
      export ROOT_DIR=/project/users/erics/work/$1
  fi
  module use $ROOT_DIR/mod
#  export MODULEPATH==/project/users/erics/work/$1/mod:.
  module purge
  module add chip/f1
  cd $ROOT_DIR
}

function prune
{
    del_path=$1
    dir_cnt=$(ls -ltr $del_path | grep "^d" | wc -l)
    if [[ $dir_cnt -gt 10 ]]  ; then
        del_cnt=$(expr $dir_cnt - 10)
        del_list=$(ls -ltr $del_path | grep "^d" | head -n $del_cnt | awk '{print $NF}')
        for i in $del_list
        do
            del_dir=$(echo "$del_path/$i" | tr -s /)
            echo "rm -r $del_dir"
            $(rm -r $del_dir)
        done
    fi
}

function debug
{
   mytclfile="erics.tcl.svcf"
   if [[ $# == 1 ]]  ; then
     if [[ -e $1 ]]  ; then
         mytclfile=$1;
     fi
   fi
   if [[ -e $mytclfile ]]  ; then
       simvision -input $mytclfile &
     else
       simvision &
   fi
}

function get_timing_paths
{
  egrep "Startpoint|Endpoint|slack" $1 | grep -B 2 VIOLATED
}

function mif2bintxt
{
    infile="$1.mif"
    file_root=$1
    rom_size=$2
    rom_width=$3
    rom_size_m1=$((rom_size-1))
    addr_bits=0
    while [[ $rom_size_m1 -gt 0 ]]
    do
        rom_size_m1=$((rom_size_m1/2))
        addr_bits=$((addr_bits+1))
    done
    cnt=0
    for fn in `cat $infile`
    do
        if [[ $cnt -eq 0 ]]  ; then
            echo "start_FA $rom_inst"
            echo "CUBES:"
        fi
        fnb=$(echo "obase=2; ibase = 16; ${fn^^}" | bc )
        cntb=$(echo "obase=2; ${cnt}" | bc )
        cnt=$((cnt+1))
        echo "$cntb $fnb" | awk -v val=$addr_bits '{printf "%0*s %032s\n", val, $1, $2}'
        if [[ $cnt -eq $rom_size ]]  ; then
            echo ";"
            echo "end_FA $rom_inst"
            cnt=0
        fi
    done
    if [[ $cnt -gt 0 ]]  ; then
        echo ";"
        echo "end_FA $rom_inst"
    fi
}

function chk_last_regr
{
    if [[ $# == 1 ]]  ; then
        search_path=$1
    else
        search_path="$ROOT_DIR/build"
    fi
    regr_list=$(find $search_path -name "regr_*.list" | xargs ls -tr1 | tail -1)
    echo "regression list = $regr_list"
    fn=$(basename $regr_list)
    dn=$(dirname $regr_list)
    #ext="${fn##*.}"
    name="${fn%.*}"
    if [[ -f $dn/$name.results ]]  ; then
        pend=$(grep "Num Pending" $dn/$name.results | sed 's/^.*: *\([0-9]*\).*/\1/')
        running=$(grep "Num Running" $dn/$name.results | sed 's/^.*: *\([0-9]*\).*/\1/')
        if (( $pend == 0 )) && (( $running == 0 )) ; then
            more $dn/$name.results
        else
            $ROOT_DIR/tools/runv -regrRslt $regr_list
            more $dn/$name.results
        fi
    else
        $ROOT_DIR/tools/runv -regrRslt $regr_list
        more $dn/$name.results
    fi
}

function resim
{
    cmd=""
    rerun_path=""
    rerun_opt=""

    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
        if [[ -z "$cmd" ]]  ; then
            if [[ -f "$1" ]]  ; then
                # argument is a valid file

                # Try to get runv command
                cmd=$(grep runv $1 | grep -v \\$\\@)

                if [[ -z "$cmd" ]]  ; then
                    # No runv command found
                    # Try looking for rerun file in same dir
                    rerun_path=$(dirname "${1}")
                    rerun_path="$rerun_path/rerun"
                    if [[ -f $rerun_path ]]  ; then
                        cmd=$(grep runv $rerun_path | grep -v \\$\\@)
                    fi
                fi
            elif [[ -d "$1" ]]  ; then
                # argument is a valid directory

                # Try looking for rerun file in dir
                rerun_path="$1/rerun"
                if [[ -f $rerun_path ]]  ; then
                    cmd=$(grep runv $rerun_path | grep -v \\$\\@)
                fi
            fi


            if [[ -z "$cmd" ]]  ; then
                # Still No runv command found
                # Assume argument is option to be passed to runv command
                rerun_opt="$rerun_opt$1 "
            fi
        else
            # If runv command already found, assume argument is option to be passed to runv command
            rerun_opt="$rerun_opt$1 "
        fi
        shift

    done
    set -- "${POSITIONAL[@]}"

    if [[ -z "$cmd" ]]  ; then
        echo "ERROR: No runv command found"
        return
    fi

    # For some reason, a space gets inserted when "-covoverwrite" is in original command line
    cmd="${cmd/'" -covoverwrite"'/"-covoverwrite"}"
    #echo "cmd = $cmd"
    IFS=' ' read -r -a cmd_array <<< "$cmd"

    idx=0
    cmd=""
    while [[ $idx -lt ${#cmd_array[@]} ]]
    do
        if [[ ${cmd_array[$idx]} == "+qtdir"* ]] ; then
            idx=$((idx+0))
        elif [[ ${cmd_array[$idx]} == *"-tdir"* ]] ; then
            idx=$((idx+1))
        elif [[ ${cmd_array[$idx]} == *"-bdir"* ]] ; then
            idx=$((idx+1))
        else
            cmd="$cmd${cmd_array[$idx]} "
        fi
        idx=$((idx+1))
    done
    cmd="$cmd$rerun_opt "
    echo "Executing command: $cmd"
    $cmd
}


function lastlog
{
    if [[ $# == 1 ]]  ; then
        search_path=$1
    else
        search_path="$ROOT_DIR/build"
    fi
    log_list=$(find $search_path -name "last.log" | xargs ls -tr1 | tail -1)
    emacs $log_list
}

# Usage: lastsim <chip> <block>
#  If <chip> or <block> is missing, it will search for latest wav_dump.trn anywhere
#  in build dir.  Otherwise, it will limit to build/<chip> dir.
#  <block> is used to load signals.
#  <chip> = f1|s1|f1d1
#  <block> = sec|rgx|dfa|dfa0|dfa1|dfa2|ccp|dma_ccp|sbp|emul|rbm
function lastsim
{

    # TODO: Loop through arguments and if:
    # s1/f1 set chip
    # sec/rgx/dfa/ccp set unit
    # anything else set search_path
    # if path not found, but chip/unit are, then default to proper last dir
    default_search_path="$ROOT_DIR/build"
    search_path=""
    chip=""
    unit=""
    sigs=""
    dfa_sel=""
    emul=""
    if [[ -n $emul ]]  ; then
        echo "1. emul is defined: $emul"
    fi

    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            s1)
                chip="s1"
                default_search_path="$ROOT_DIR/build/s1"
                shift
                ;;
            f1d1)
                chip="f1d1"
                default_search_path="$ROOT_DIR/build/f1d1"
                shift
                ;;
            f1)
                chip="f1"
                default_search_path="$ROOT_DIR/build/f1"
                shift
                ;;
            sec)
                unit="sectb"
                shift
                ;;
            dfa)
                unit="dfatb"
                shift
                ;;
            rbm)
                unit="rbmtb"
                shift
                ;;
            rgx)
                unit="pc_rgx_tb"
                shift
                ;;
            dfa0)
                unit="pc_rgx_tb"
                dfa_sel="0"
                shift
                ;;
            dfa1)
                unit="pc_rgx_tb"
                dfa_sel="1"
                shift
                ;;
            dfa2)
                unit="pc_rgx_tb"
                dfa_sel="2"
                shift
                ;;
            ccp)
                unit="ccptb"
                shift
                ;;
            dma_ccp)
                unit="pc_dma_tb"
                shift
                ;;
            sbp)
                unit="cc_sbp_tb"
                shift
                ;;
            emul)
                emul="1"
                shift
                ;;
            *)  search_path=$key
                shift
                ;;
        esac
        done
    set -- "${POSITIONAL[@]}"

    if [[ -n $emul ]]  ; then
        echo "emul is defined: $emul"
    fi

    if [[ -n $chip ]] && [[ -n $unit ]]  ; then
        default_search_path="$default_search_path/$unit"
    fi

    if [[ -n $emul ]] && [[ -z $search_path ]]  ; then
        echo "Search path must be specified when emul option used."
        return
    fi

    if [[ -n $emul ]] && [[ ! -n $chip ]]  ; then
        echo "Chip (s1 or f1 or f1d1) must be specified when emul option used."
        return
    fi

    if [[ -n $emul ]] && [[ ! -n $unit ]]  ; then
        echo "Unit (rgx, ccp, or sec) must be specified when emul option used."
        return
    fi

    if [[ -z $search_path ]]  ; then
        search_path=$default_search_path
    fi

    if [[ -f $search_path ]]  ; then
        search_path=$(dirname $search_path)
    fi

    if [[ ! -e $search_path ]]  ; then
        search_path="."
        echo "Path not found.  Using current directory."
    fi

    # Find all wave files in search path
    #wav_dir=$(find $search_path -name "wav_dump.trn" | xargs ls -tr1 | tail -1 | xargs dirname)
    if [[ ! -n $emul ]] ; then
        wav_dir=$(find $search_path -name "wav_dump.trn")
    else
        echo "search_path = $search_path"
        wav_dir=$(find $search_path -name "trace_hw.trn")
    fi

    echo "wav_dir = $wav_dir"
    if [[ -z "$wav_dir" ]]  ; then
        echo "ERROR: No wave files found in $search_path"
        return
    fi

    # Choose most recent wave file
    wav_dir=$(echo $wav_dir | xargs ls -tr1 | tail -1 | xargs dirname)

    # if not specified, find unit from path to waves
    if [[ -z $unit ]]  ; then
        sim_dir=$(dirname $wav_dir)
        unit=$(grep unit $sim_dir/run | tail -1 | sed 's/.*-unit *\([a-zA-Z_]*\).*/\1/')
    fi

    # if not specified, find chip from path to waves
    if [[ -z $chip ]]  ; then
        if [[ $wav_dir == *"/s1/"* ]] ; then
            chip="s1"
        elif [[ $wav_dir == *"/f1/"* ]] ; then
            chip="s1"
        elif [[ $wav_dir == *"/f1d1/"* ]] ; then
            chip="f1d1"
        else
            chip=""
        fi
    fi

    if [[ $chip = "s1" ]] ; then
        if [[ ! -n $emul ]] ; then
            case $unit in
                pc_rgx_tb)
                    case $dfa_sel in
                        0) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx_dfa0.sv";;
                        1) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx_dfa1.sv";;
                        2) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx_dfa2.sv";;
                        *) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx.sv";;
                    esac
                    ;;
                ccptb)     sigs="$ROOT_DIR/ver/ccp/signals/erics_s1.sv";;
                pc_dma_tb) sigs="$ROOT_DIR/ver/ccp/signals/erics_s1_dma.sv";;
                sectb)     sigs="$ROOT_DIR/ver/sec/signals/erics_s1.sv";;
                dfatb)     sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_dfa.sv";;
                rbmtb)     sigs="$ROOT_DIR/ver/rbm/signals/erics_s1_rbm.sv";;
                cc_sbp_tb) sigs="$ROOT_DIR/ver/cc_sbp/signals/erics_s1.sv";;
                *)         sigs="";;
            esac
            #echo "s1: sigs = $sigs"
        else
            case $unit in
                pc_rgx_tb)
                    case $dfa_sel in
                        0) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx_dfa0_emul.sv";;
                        1) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx_dfa1_emul.sv";;
                        2) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx_dfa2_emul.sv";;
                        *) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx_emul.sv";;
                    esac
                    ;;
                *)         sigs="";;
            esac
            #echo "s1: sigs = $sigs"
        fi
    elif [[ $chip = "f1d1" ]] ; then
        if [[ ! -n $emul ]] ; then
            case $unit in
                pc_rgx_tb)
                    case $dfa_sel in
                        0) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1d1_rgx_dfa0.sv";;
                        1) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1d1_rgx_dfa1.sv";;
                        2) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1d1_rgx_dfa2.sv";;
                        *) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1d1_rgx.sv";;
                    esac
                    ;;
                ccptb)     sigs="$ROOT_DIR/ver/ccp/signals/erics_f1d1.sv";;
                pc_dma_tb) sigs="$ROOT_DIR/ver/ccp/signals/erics_f1d1_dma.sv";;
                sectb)     sigs="$ROOT_DIR/ver/sec/signals/erics_s1.sv";;
                dfatb)     sigs="$ROOT_DIR/ver/dfa/signals/erics_f1d1_dfa.sv";;
                rbmtb)     sigs="$ROOT_DIR/ver/rbm/signals/erics_f1d1_rbm.sv";;
                cc_sbp_tb) sigs="$ROOT_DIR/ver/cc_sbp/signals/erics_s1.sv";;
                *)         sigs="";;
            esac
            #echo "s1: sigs = $sigs"
        else
            case $unit in
                pc_rgx_tb)
                    case $dfa_sel in
                        0) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx_dfa0_emul.sv";;
                        1) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx_dfa1_emul.sv";;
                        2) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx_dfa2_emul.sv";;
                        *) sigs="$ROOT_DIR/ver/dfa/signals/erics_s1_rgx_emul.sv";;
                    esac
                    ;;
                *)         sigs="";;
            esac
            #echo "s1: sigs = $sigs"
        fi
    elif [[ $chip = "f1" ]] ; then
        if [[ ! -n $emul ]] ; then
            case $unit in
                pc_rgx_tb)
                    case $dfa_sel in
                        0) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1_rgx_dfa0.sv";;
                        1) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1_rgx_dfa1.sv";;
                        2) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1_rgx_dfa2.sv";;
                        *) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1_rgx.sv";;
                    esac
                    ;;
                ccptb)     sigs="$ROOT_DIR/ver/ccp/signals/erics_f1.sv";;
                pc_dma_tb) sigs="$ROOT_DIR/ver/ccp/signals/erics_f1_dma.sv";;
                sectb)     sigs="$ROOT_DIR/ver/sec/signals/erics_f1.sv";;
                dfatb)     sigs="$ROOT_DIR/ver/dfa/signals/erics_f1_dfa.sv";;
                cc_sbp_tb) sigs="$ROOT_DIR/ver/cc_sbp/signals/erics_f1.sv";;
                *)         sigs="";;
            esac
            #echo "f1: sigs = $sigs"
        else
            #case $unit in
            #    pc_rgx_tb)
            #        case $dfa_sel in
            #            0) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1_rgx_dfa0.sv";;
            #            1) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1_rgx_dfa1.sv";;
            #            2) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1_rgx_dfa2.sv";;
            #            *) sigs="$ROOT_DIR/ver/dfa/signals/erics_f1_rgx.sv";;
            #        esac
            #        ;;
            #    ccptb)     sigs="$ROOT_DIR/ver/ccp/signals/erics_f1.sv";;
            #    pc_dma_tb) sigs="$ROOT_DIR/ver/ccp/signals/erics_f1_dma.sv";;
            #    sectb)     sigs="$ROOT_DIR/ver/sec/signals/erics_f1.sv";;
            #    dfatb)     sigs="$ROOT_DIR/ver/dfa/signals/erics_f1_dfa.sv";;
            #    cc_sbp_tb) sigs="$ROOT_DIR/ver/cc_sbp/signals/erics_f1.sv";;
            #    *)         sigs="";;
            #esac
            sigs=""
            #echo "f1: sigs = $sigs"
        fi
    else
        sigs=""
        #echo "bad: sigs = $sigs"
    fi

    if [[ ! -z $sigs ]] && [[ -e $sigs ]]  ; then
        cmd="simvision -input $sigs $wav_dir"
    else
        cmd="simvision $wav_dir"
    fi
    echo "Executing command: $cmd"

    $cmd &

    # Maybe copy signal files & replace paths and/or hierarchies?

    # TODO: Warning if many simvision processes already running for this path

    # Load waves with signal file (if found)

}




# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/erics/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [[ $? -eq 0 ]] ; then
    eval "$__conda_setup"
else
    if [ -f "/home/erics/anaconda3/etc/profile.d/conda.sh" ] ; then
        . "/home/erics/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/erics/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


#export PYTHONSTARTUP=$HOME/.pythonstartup
#export PATH=$HOME/local/bin/:$PATH
#export PATH=$HOME/.local/bin/:$PATH
#export LD_LIBRARY_PATH=/home/erics/local/lib:$LD_LIBRARY_PATH
