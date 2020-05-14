#!/bin/bash

# TODO:
#   - add Go completer for vim
#   - idk, probably bug fixes

echo "[*] Updating things and installing things through apt"
if [ ! -f "/tmp/.init-done" ]; then
	sudo apt update && sudo apt upgrade -qq
	sudo apt install -y python3 curl git vim build-essential cmake python3-dev -qq
	touch /tmp/.init-done
fi

echo "[*] Installing nodejs"
if [ ! $(command -v nodejs) ]; then
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs -qq
fi

echo "[*] Installing rust"
if [ ! $(command -v rustup) ]; then
    # install rustup, and base things
    curl -sSf https://sh.rustup.rs | sh -s -- -y
    # install rust-analyzer
    source $HOME/.cargo/env
    rustup component add rust-src
    #curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux -o ~/.cargo/bin/rust-analyzer
    #chmod +x ~/.cargo/bin/rust-analyzer
fi

echo "[*] Installing rust-analyzer"
if [ ! $(command -v rust-analyzer) ]; then
    git clone https://github.com/rust-analyzer/rust-analyzer.git
    cd rust-analyzer
    cargo xtask install --server
    cd ..
    rm -rf rust-analyzer
    echo -e '\n#### cargo path ####' >> ~/.bashrc
    echo 'source $HOME/.cargo/env' >> ~/.bashrc
fi

echo "[*] Preparing VundleVim"
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
	mkdir -p ~/.vim/bundle
	git clone https://github.com/VundleVim/Vundle.vim.git  ~/.vim/bundle/Vundle.vim
fi

echo "[*] Preparing youcompleteme"
if [ ! -d ~/.vim/bundle/YouCompleteMe ]; then
	git clone https://github.com/ycm-core/YouCompleteMe.git ~/.vim/bundle/YouCompleteMe
	cd ~/.vim/bundle/YouCompleteMe
	git submodule update --init --recursive
	python3 install.py --ts-completer
	cd -
fi

echo "[*] Preparing vimrc"
if [ $(cmp --quiet vim/vimrc-full ~/.vimrc; echo $?) -ne 0 ]; then
	cp vim/vimrc-init ~/.vimrc
	vim +PluginInstall +qall
	cp vim/vimrc-full ~/.vimrc
fi

echo "[*] Adding bashrc stuff - be warned: I'm a noob, and don't know how to check if this stuff has already been added"
cat bashrc/bashrc >> ~/.bashrc

echo "[+] Everything *should* be set up?"
