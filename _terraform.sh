#!/bin/bash

# Populates dot-config and vim files
# run it with `-full` to overwrite all files

SRC_ROOT=$(readlink -f $(dirname $0))
VIM_DIR=${VIM_DIR:-~/.vim}
SCREEN_RC=${SCREEN_RC:-~/.screenrc}
BASH_RC=${BASH_RC:-~/.bashrc}
VIM_RC=${VIM_RC:-~/.vimrc}
ZSH_RC=${ZSH_RC:-~/.zshrc}
GITCONFIG=${GITCONFIG:-~/.gitconfig}
GIT_TEMPLATE_DIR=${GIT_TEMPLATE_DIR:-~/.git_template}
FULL=0

YUM="$(which yum 2>/dev/null)"
APTGET="$(which apt-get 2>/dev/null)"
PACMAN="$(which pacman 2>/dev/null)"

GIT="$(which git 2>/dev/null)"
SCREEN="$(which screen 2>/dev/null)"
CTAGS="$(which ctags 2>/dev/null)"
VIM="$(which vim 2>/dev/null)"
ZSH="$(which zsh 2>/dev/null)"

if [ ! -x $GIT ]; then
    # you manually downloaded _terraform.sh ...
    echo >&2 "I don't know how you managed to get here" \
            " without git, but I can't find it, not continuing"
    exit 1
fi
if [ "x$1" = "x-full" ]; then
    FULL=1 # scorched earth policy (replace all config files/dirs)
fi

declare -A YUM_OVERRIDES APT_OVERRIDES PACMAN_OVERRIDES
YUM_OVERRIDES["vim"]="vim-enhanced"

function install_os_package() {
    local pkg=$1
    if [ -x $YUM ]; then
        # CentOS/RHEL/SL
        sudo $YUM install ${YUM_OVERRIDES[$pkg]:-$pkg}
    elif [ -x $APTGET ]; then
        # Ubuntu/Debian
        # TODO: do Ubuntu and Debian have different package names?
        sudo $APTGET install ${APT_OVERRIDES[$pkg]:-$pkg}
    elif [ -x $PACMAN ]; then
        # Archlinux
        sudo $PACMAN -S ${PACMAN_OVERRIDES[$pkg]:-$pkg}
    else
        # most likely OSX. you're on your own.
        echo >&2 "Unfamiliar distribution, dropping into shell"
        echo >&2 "Please install the $pkg package then type 'exit'"
        PS1="install $pkg please> " bash -i
    fi
}

function populate_rc() {
    local src_rc=$1
    local dest_rc=$2
    echo "Populating $dest_rc..."
    if [ -f ${dest_rc} -a $FULL -eq 1 ]; then
        echo "" >>${dest_rc}
        cat ${src_rc} >>${dest_rc}
    else
        cp ${src_rc} ${dest_rc}
    fi
}

function clone_vim_bundle() {
    local remote=$1

    pushd ${VIM_DIR}/bundle
    git clone --depth 1 ${remote}
    popd
}

function prompt_install_pkg() {
    local pkg=$1
    local install="y"

    echo -n "$pkg not found, install $pkg (Y/n)? "
    read install
    if [ "x${install}" != "xn" ]; then
        install_os_package screen
    fi
}

populate_rc ${SRC_ROOT}/.bashrc ${BASH_RC}

# tools
if [ ! -x "$SCREEN" ]; then
    prompt_install_pkg screen
fi
populate_rc ${SRC_ROOT}/.screenrc ${SCREEN_RC}
if [ ! -x "$CTAGS" ]; then
    prompt_install_pkg ctags
fi

# zsh
if [ ! -x "$ZSH" ]; then
    prompt_install_pkg zsh
fi
git clone https://github.com/zsh-users/antigen.git ~/antigen
populate_rc ${SRC_ROOT}/.zshrc ${ZSH_RC}

# vim + pathogen
if [ ! -x "$VIM" ]; then
    prompt_install_pkg vim
fi
if [ $FULL -eq 1 ]; then
    mv ${VIM_DIR} ${VIM_DIR}.old
fi
mkdir -p ${VIM_DIR}/autoload ${VIM_DIR}/.pathogen ${VIM_DIR}/bundle
git clone https://github.com/tpope/vim-pathogen.git ${VIM_DIR}/.pathogen
ln -s ${VIM_DIR}/.pathogen/autoload/pathogen.vim ${VIM_DIR}/autoload/

# vim plugins
clone_vim_bundle https://github.com/tpope/vim-fugitive.git
clone_vim_bundle https://github.com/vim-airline/vim-airline.git
clone_vim_bundle https://github.com/davidhalter/jedi-vim.git

populate_rc ${SRC_ROOT}/.vimrc ${VIM_RC}


# tpope is love tpope is life
# http://tbaggery.com/2011/08/08/effortless-ctags-with-git.html
if [ ! -d ${GIT_TEMPLATE_DIR} ]; then
    git config --global init.templatedir '~/.git_template'
    mkdir -p ${GIT_TEMPLATE_DIR}/hooks
    cp ${SRC_ROOT}/.git_template/hooks/ctags ${GIT_TEMPLATE_DIR}/hooks/
    pushd ${GIT_TEMPLATE_DIR}/hooks
    ln -s ./ctags post-checkout
    ln -s ./ctags post-commit
    ln -s ./ctags post-merge
    cp ${SRC_ROOT}/.git_template/hooks/post-rewrite \
                ${GIT_TEMPLATE_DIR}/hooks
    popd
fi
populate_rc ${SRC_ROOT}/.gitconfig ${GITCONFIG}

echo "Home dir configured. Happy hacking."
