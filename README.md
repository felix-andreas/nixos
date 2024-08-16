# NixOS

## Update the System Configuration

Run:

```
sudo nixos-rebuild switch --flake ~/.machines#<name>
```

## Update the `home-manager` Configuration

Run:

```
home-manager switch --flake ~/.machines#<name>
```
