#
# Default user .cshrc file
#
# Usage:  Copy this file to a user's home directory and edit it to
# customize it to taste.  It is run by csh each time it starts up.
#
# Modified 981209 jsin
# Modified 981001 djo based on originals from dhynson
#

setenv EDITOR vi
setenv PAGER less
setenv LPDEST lp
setenv TERM xterm
#stty erase 

#######################################
#PERSONAL CUSTOMIZATION BELOW THIS LINE
#######################################

##do this only if interactive shell
#if ($?prompt) then
#        set hostname = `hostname | awk -F. '{print $1}'`
#        #alias set_prompt 'set prompt="[%c/]@${hostname} [%h]-> "'
#        #alias cd 'cd \!*; set_prompt'
#        #if (-o ~/.aliases) then
#        #   source ~/.aliases
#        #endif
#endif
##export PS1="\[$(tput bold)\]\[\033[38;5;31m\]\h:\w > \[$(tput sgr0)\]"
#
#set hostname = `hostname | awk -F. '{print $1}'`
if ($?prompt ) then
    set filec
    set history=200
    set savehist=100
    #set prompt="${hostname}:t[\!] "
endif


# to get rid of duplicate lines in the $PATH
#set npath
#foreach elem ( $path )
#        if ( ! -d $elem ) continue
#        set needed
#        foreach nelem ( $npath )
#                if ( $nelem == $elem ) then
#                        unset needed
#                        break
#                endif
#        end
#        if ( $?needed ) set npath = ( $npath $elem )
#end
#set path = ( $npath )
#unset npath nelem elem needed

setenv WORK /project/users/erics

#####################
# Old
#####################

set prompt = "\n%{\033[0;32;1m%}%n@%m:%~ >%{\033[0m%} "
#set prompt = "\n%B%{\033[38;5;31m%}`hostname -s`:$PWD >%{\033[0m%}%b "

setenv GREP_OPTIONS "--exclude=*entries --exclude=*.svn-base --exclude=*.pyc --exclude=*.tmp --exclude=.nfs*"

source /home/erics/.alias_csh
source /project/tools/Modules/mod_csh

setenv VISUAL vim
set autolist

#set path = ($path $HOME/bin)

umask 022

