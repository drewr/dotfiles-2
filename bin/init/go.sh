#! /usr/bin/env bash
#
# (re-)bootstrap an environment
# init a new machine with "bash <(curl -fsSL https://raw.github.com/dcreemer/dotfiles/master/bin/init/go.sh)"
# can be safely re-run
# on FreeBSD assumes pkg, sudo and bash are installed

set -o nounset
set -o errexit

TARGETS=$@
OS=`uname`
DF=$HOME/.dotfiles

# list of target -> repository URL; functions as a map
REPOS=( "base __ git://github.com/dcreemer/dotfiles.git"
        "private __ gcrypt::rsync:///Users/dcreemer/Dropbox/Git/dotfiles-private.git"
        "work __ gcrypt::rsync:///Users/dcreemer/Dropbox/Git/dotfiles-work.git" )

set_targets()
{
    # set the targets to be fetched and installed. The list of all targets are the keys of the
    # "REPOS" 'map'. Defaults to only "base"; use '--all' to run all targets
    if [[ $TARGETS == "" ]]; then
        TARGETS="base"
    elif [[ $TARGETS == "--all" ]]; then
        TARGETS=" "
        for pair in "${REPOS[@]}" ; do
            TARGETS="$TARGETS ${pair%% __ *}"
        done
    fi
}

bootstrap()
{
    # ensure base and bin dirs
    if [[ ! -d $DF ]]; then
        mkdir -p $DF
    fi
    if [ ! -d $HOME/bin ]; then
        mkdir $HOME/bin
    fi
    # check to see if git is installed, and if not, install it.
    if [[ ! -x `which git` ]]; then
        echo "[INSTALL] installing git"
        case $OS in
            "Linux")
                sudo apt-get -y install git
                ;;
            "Darwin")
                # install homebrew if needed
                if [ ! -x /usr/local/bin/brew ]; then
                    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
                fi
                brew install git
                ;;
            "FreeBSD")
                sudo pkg install -y git
                ;;
        esac
    fi
}

get_repo_url()
{
    # given a target name, fetch the repo URL
    local target=$1
    REPO=""
    for pair in "${REPOS[@]}" ; do
        if [[ $target == "${pair%% __ *}" ]]; then
            REPO="${pair##* __ }"
        fi
    done
}

fetch_repo()
{
    # given a target name, fetch the repository 
    local target=$1
    local target_dir=${DF}/$target
    if [ ! -r $target ]; then
        get_repo_url $target
        echo "[CLONE] $REPO -> $target"
        git clone $REPO $target
    fi
}

do_install()
{
    # run pre-install hook, install files, and then run post-install hook
    # for the given target
    local target=$1
    local target_dir=${DF}/${target}
    local target_os_dir=${DF}/${target}/${OS}
    if [ -d $target_dir ]; then
        # run pre-install hook
        if [ -r ${target_os_dir}/pre-install.sh ]; then
            ${target_os_dir}/pre-install.sh
        fi
        # install
        $DF/base/bin/link-dotfiles $target
        # run post-install hook
        if [ -r ${target_os_dir}/post-install.sh ]; then
            ${target_os_dir}}/post-install.sh
        fi
    fi
}

execute_targets()
{
    for t in $TARGETS ; do
        echo "[TARGET] $t"
        fetch_repo $t
        do_install $t
    done
}

# main program
echo "[START]"
bootstrap
set_targets
execute_targets
echo "[DONE]"
