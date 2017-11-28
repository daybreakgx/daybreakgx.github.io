#!/bin/bash

change_sh_to_bash(){
    output=$(which sh)
    ret=$(ls -l ${output} |cut -f2 -d '>')
    if [ "bash" != $ret ];then
        echo "[NOTICE][IMPORTANT] Please confirm [NO] in the next step"
        echo "[cmd]===>sudo dpkg-reconfigure dash"
        sleep 5
        sudo dpkg-reconfigure dash
    fi
    return 0
}

install_expect(){
    #check if expect had installed.
    echo "[TOOL]-----------install expect..."
    output=$(which expect)
    if [ 0 -eq $? ];then
        echo "[TOOL]expect had been installed in ${output}, skip install......"
        return 0
    fi

    echo "[NOTICE]Please check and confirm interaction informations."
    echo "===>cmd: apt install expect"
    apt install expect
    if [ $? -ne 0 ];then
        echo "[TOOL]----------expect install failed."
        return 1
    fi
    echo "[TOOL]----------expect install OK."
    return 0
}

install_atom(){
    echo "[TOOL]----------install atom..."

    output=$(which atom)
    if [ 0 -eq $? ];then
        echo "[TOOL]atom had been installed in ${output}, skip install......"
        return 0
    fi
    echo "===>cmd: add-apt-repository ppa:webupd8team/atom"

    output=$(which expect)
    if [ $? -ne 0 ];then
        echo "need expect tool, install expect..."
        install_expect
        if [ $? -ne 0 ];then
            return 1
        fi
    fi
    expect << EOF
set timeout -1
spawn add-apt-repository ppa:webupd8team/atom
expect {
    "* to continue*" {send "\n"}
}
expect eof
EOF

    echo "===>cmd: apt-get update"
    sudo apt-get update

    echo "===>cmd: apt install atom"
    expect << EOF
set timeout -1
spawn apt install atom
expect "*Y/n*"  {send "y\n"}
expect "*Y/n*"  {send "y\n"}
EOF
    echo "===>config: change registry"
    apm config set registry http://registry.npm.taobao.org
    echo "===>config: install plug-in"
    apm install atom-beautify
    apm install busy-signal
    apm install intentions
    apm install linter
    apm install linter-gcc
    apm install linter-ui-default
    apm install gcc-make-run
    apm install vim-mode
    apm install script
    return 0
}

install_vim(){
    echo "[TOOL]----------install vim..."
    output=$(which vim)
    if [ $? -eq 0 ];then
        echo "[TOOL] vim had been installed in ${output}, skip install......"
        return 0
    fi

    echo "[cmd]===>apt install vim"
    apt install vim
    echo "[config]===>install vundle"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    echo "set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
call vundle#end()
filetype plugin indent on" > ~/.vimrc
    echo "[TOOL]----------install vim OK"
    return 0
}

install_python_pip(){
    echo "[TOOL]----------install pip..."
    output=$(which pip)
    if [ $? -eq 0 ];then
        echo "[TOOL] pip had been installed in ${output}, skip install......"
        return 0
    fi

    echo "[cmd]===>apt install python-pip"
    apt install python-pip
    echo "[TOOL]----------install pip OK"
    return 0
}

install_go(){
    echo "[TOOL]----------install go..."
    output=$(which go)
    if [ $? == 0 ];then
        echo "[TOOL] go had been installed in ${output}, skip install......"
        return 0
    fi
    echo "[cmd]===>apt install golang-go"
    apt install golang-go

    echo "[TOOL]----------install go OK"
}

main(){

    change_sh_to_bash

    #check execute permission
    filename="temp_$(date +%Y_%m_%d_%H_%M_%S_%N)"
    touch /etc/${filename}
    if [ $? -eq 1 ];then
        echo ""
        echo "usage: sudo ./script_name"
        exit 1
    else
        rm -f /etc/${filename}
    fi

    install_vim
    install_python_pip

    install_expect
    install_atom
    install_go
}

main
