# Created by newuser for 5.2
source /etc/zshrc

source ~/antigen/antigen.zsh
. ~/.private.zsh

autoload -U colors && colors
setopt promptsubst

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle git 
antigen bundle pip 
antigen bundle python

antigen apply
