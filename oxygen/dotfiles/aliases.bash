# edit files
alias machines='code $HOME/.machines'
alias dotfiles='code $HOME/.machines/oxygen/dotfiles'
notes() { vi "$HOME/Projects/notes/$1.md"; }
work() { vi "$HOME/Projects/felix/$1.md"; }

# file management
alias open='xdg-open'
alias trash='gio trash'

# nix
alias system='sudo nixos-rebuild switch --flake ~/.machines#oxygen'
alias home='home-manager switch --flake ~/.machines#oxygen'
alias set-interpreter='patchelf --set-interpreter $(nix eval --raw nixpkgs#stdenv.cc)/nix-support/dynamic-linker'
,() { NIXPKGS_ALLOW_UNFREE=1 nix run --impure nixpkgs#"$1" -- "${@:2}"; }
shell() { NIXPKGS_ALLOW_UNFREE=1 nix shell --impure $(printf "nixpkgs#%s " "$@"); }
pywith() { nix shell --impure --expr "(builtins.getFlake \"nixpkgs\").legacyPackages.x86_64-linux.python3.withPackages (p: with p; [ ipython black $* ])"; }
flakify() {
  if [ ! -e flake.nix ]; then
    nix flake new -t github:nix-community/nix-direnv .
  elif [ ! -e .envrc ]; then
    echo "use flake" > .envrc
    direnv allow
  fi
  ${EDITOR:-vim} flake.nix
}

# roc local
alias rocl="nix develop ~/Projects/roc/ -c ~/Projects/roc/target/release/roc"

# mojo local
alias mojo="distrobox enter --name ubuntu -- ~/.modular/pkg/packages.modular.com_mojo/bin/mojo"

# python
alias py="python"
alias ipython="ipython --TerminalInteractiveShell.editing_mode=vi"
alias pytime="python -m timeit"
pydis() { echo "$@" | python -m dis; }

# docker
alias docker-remove-container='docker rm $(docker ps -aq)'
alias docker-remove-images='docker rmi $(docker images -aq)'
alias docker-remove-untagged-images='docker rmi $(docker images -q --filter "dangling=true")'

# misc
belta() { delta <(hexyl "$1") <(hexyl "$2"); }
alias ubuntu='distrobox enter ubuntu'
alias path='echo $PATH | tr : \\n'
alias record-gif='ffmpeg -video_size 1920x1080 -f x11grab -i :0.0+0,420 -y video.gif -vf "fps=10,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0'
alias start-qemu='qemu-system-x86_64 -enable-kvm -cpu host -smp 4 -m 6G -vga virtio -display sdl,gl=on -hda'

# power management
alias freq='cat /proc/cpuinfo | grep MHz'
alias performance='sudo cpupower frequency-set -g performance'
alias powersave='sudo cpupower frequency-set -g powersave'
power-usage() {
    while true
    do
        echo - | awk "{printf \"%.1f\", \
        $(( \
          $(cat /sys/class/power_supply/BATT/current_now) * \
          $(cat /sys/class/power_supply/BATT/voltage_now) \
        )) / 1000000000000 }"
        echo " W"
        sleep 1
    done
}
watch-cpu() { watch -n 0.5 $'mpstat 1 1 | awk \'/^Average/ {print 100-$NF,"%"}\''; }
