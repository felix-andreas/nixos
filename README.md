# NixOS

## Update the System Configuration

Run:

```
sudo nixos-rebuild switch --flake ~/.nixos#<name>
```

## Update the `home-manager` Configuration

Run:

```
home-manager switch --flake ~/.nixos#<name>
```
