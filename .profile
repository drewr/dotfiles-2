#
# profile for dcreemer
# should work with Mac OS X, FreeBSD, and Linux
#

test "$OS" || export OS="$(uname)"
if [ "$OS" == "Linux" ] && [ -r /etc/os-release ]; then
    export DIST=$(grep -e '^NAME=' /etc/os-release |sed -r 's/NAME="([a-zA-Z ]+)"/\1/')
else
    export DIST="NA"
fi

export LANG=en_US.UTF-8

if [ "$ANDROID_ROOT" != "" ]; then
    # inside termux, need busybox and user
    export PATH=$HOME/bin:$HOME/.local/bin:$PREFIX/bin:$PREFIX/bin/applets
    export USER=$(whoami)
    eval `ssh-agent -s`
else
    export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
fi

if [ "$BASH" ] && [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
