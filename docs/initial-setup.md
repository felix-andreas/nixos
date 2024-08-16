# Initial Setup

## Start from the template

Pick an element from the [periodic table of elements](https://ptable.com/) and copy
the `template` folder to the appropriate location:

```
cp template element
```

Then, you need to make some adjustments:

1. Update the `README.md` file
2. Change the `user`-name in `system.nix`
3. Set Git's `name` and `email` fields in `home.nix`

## Clone the repository

During the initial setup, we need to access the files of the `machines` repository. Furthermore, we will generate an additional `hardware.nix` file, which must be committed back to GitHub. Therefore, we need a way to push and pull to the `machines` repository from the setup machine.

1.  You could either create a temporary SSH key,

    ```sh
    ssh-keygen -t ed25519
    ```

    add it to GitHub, and do the setup directly on the setup machine.

2.  Or, you could do the whole setup remotely by mounting the hard drive via SSH on another computer with push access to our `machines repo`.

    Therefore, you need to start the SSH server and set a password:

    ```sh
    systemctl start sshd
    passwd
    ```
    >**Note**
    > GNOME Files provides a convenient way to mount a directory via SSH. Just click on *Other Locations*.

    After you log in from another another computer, you should be able to clone the `machines` repo:

    ```sh
    git clone git@github.com/felix-andreas/nixos .machines
    ```

## Partitioning

We need to create three partitions:

- `nvme0n1p1` EFI partition (unencrypted)
- `nvme0n1p2` root filesystem (encrypted)
- `nvme0n1p3` SWAP with same size as RAM (encrypted)

Use the tool of your choice (e.g. `fdisk`, `gdisk`, `parted`, or `gparted`). For example, here are the `parted` commands:

```
sudo su -
parted /dev/nvme0n1 -- mklabel gpt

parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- mkpart primary 512MiB -16GiB
parted /dev/nvme0n1 -- mkpart primary -16GiB 100%
parted /dev/nvme0n1 -- set 1 esp on
```

> if parted throws alignment error use % instead.
  e.g. assuming harddisk size is 512GiB and RAM is 16GiB -> 16 / 512 = 0.03125 -> `512MiB -3.125%`

## Encryption

Encrypt the `nvme0n1p2` and `nvme0n1p3` partitions with LUKS and map them to `/dev/mapper/cryptroot` and `/dev/mapper/cryptswap`. If passwords are the same, luks will ask for it only once and will try to open all devices with the same password.

```
cryptsetup luksFormat --label cryptroot /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 cryptroot
cryptsetup luksFormat --label cryptswap /dev/nvme0n1p3
cryptsetup luksOpen /dev/nvme0n1p3 cryptswap
```

Format the `boot`, `root`, and `swap` partitions:

```
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.ext4 -L root /dev/mapper/cryptroot
mkswap -L swap /dev/mapper/cryptswap
```

Enable the swap and mount the partitions:

```
swapon /dev/mapper/cryptswap
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

Now, running `lsblk`, should output something like this:

```
$ lsblk -o name,mountpoint,label,size,fstype
NAME          MOUNTPOINT LABEL       SIZE FSTYPE
nvme0n1                            476.9G 
├─nvme0n1p1   /boot      boot        512M vfat
├─nvme0n1p2              cryptroot 460.4G crypto_LUKS
│ └─cryptroot /          root      460.4G ext4
└─nvme0n1p3              cryptswap    16G crypto_LUKS
  └─cryptswap [SWAP]     swap         16G swap
```

Create the hardware configuration:

```
nixos-generate-config --root .machines/<name>
```

> :Note: TODO: we can probably just use `by-label` instead of `by-uuid`

Update the `machines/<name>/etc/nixos/hardware-configuration.nix` to like look like this:

```nix
boot.initrd.luks.devices = {
  cryptroot.device = "/dev/disk/by-label/cryptroot";
  cryptswap.device = "/dev/disk/by-label/cryptswap";
};

fileSystems = {
  "/" = {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
  };
 "/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
};

swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
```

Move it to `machines/<name>/hardware.nix` and remove the `machines/<name>/etc` folder. 

Optionally, make some final adjustments to the `system.nix`

> **Warning**
> Don't forget to push the changes back to GitHub before you restart the computer.

## Installation

Now, we can run the installation:

```
sudo nixos-install --no-root-password --root /mnt --flake .#<name>
```

After the installation completes, restart the computer and activate the `home-manager` configuration:

```
nix run ~/.machines#homeConfigurations.<name>.activationPackage
```

## References

* https://nixos.org/manual/nixos/stable/index.html#sec-installation-partitioning
* https://gist.github.com/ladinu/bfebdd90a5afd45dec811296016b2a3f
* https://nixos.wiki/wiki/Full_Disk_Encryption
* https://grahamc.com/blog/nixos-on-dell-9560
* https://unix.stackexchange.com/questions/529047/is-there-a-way-to-have-hibernate-and-encrypted-swap-on-nixos
