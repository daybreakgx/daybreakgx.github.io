#!/bin/bash

remove_atom(){
    echo "remove atom"
    sudo apt-get remove atom
    sudo add-apt-repository --remove ppa:webupd8team/atom
    sudo apt-get autoremove
}

main(){
    case $1 in
    "atom")
        remove_atom
        ;;
    *)
        echo "not support"
        ;;
	esac
    return 
}

main
