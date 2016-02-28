# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
source ~/.git-completion.bash

export PATH="/home/pat/blackbox/bin:/home/pat/.local/bin:$PATH"
. ~/.private.bash
