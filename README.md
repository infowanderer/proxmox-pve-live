# Proxmox VE 9 Live Boot ISO Image

* Build a fully customizable Proxmox VE 9 live boot image.
* Supports persistent filesystems across reboots (if configured).
* Use it to test Proxmox VE without installing it.
* Or create a portable USB to run a live Proxmox VE system.
* Can serve as an Unraid replacement if you manually configure Samba, accounts, and shared folders.

---

## Download
- Get the latest PVE-9 Live ISO here: [Release page](https://github.com/LongQT-sea/pve-live/releases)
- Or build your own: [How to build](#how-to-build)

> [!Important]
> **Password:** `live` (for both `user` and `root` accounts)

---

## Create a bootable PVE-9 live USB with a persistent volume

### Windows

- **Lazy method:** Use [Rufus](https://github.com/pbatard/rufus/releases). After selecting the ISO file, adjust the **Persistent partition size** slider.

- **Manual method:** Open **Windows Terminal** or **PowerShell** as Administrator.
    > Replace `X` with your USB disk number:
    ```
    diskpart
    list disk
    sel disk X
    clean
    con mbr
    cre par pri size=2000
    format fs=fat32 quick label=pve-live
    active
    assign
    cre par pri
    exit
    ```
> [!Note]
> After running these commands, it will create **2 partitions**:
> - Partition 1: Stores all ISO content.
> - Partition 2: Will be formatted in Linux for persistent storage (see **4. Format** in [Linux](#linux) section).

---

### Linux

> [!Note]
> Replace `/dev/sdX` with your actual USB drive identifier.

1. Create partitions with fdisk:
   ```
   fdisk /dev/sdX
   o          # new MBR table
   n          # new partition
   p          # primary
   <enter>    # partition 1
   <enter>    # default start
   +2000M     # 2GB size
   t          # change type
   c          # W95 FAT32 (LBA)
   a          # make bootable
   n          # new partition
   p          # primary
   2          # partition 2
   <enter>    # default start
   <enter>    # use rest of disk
   w          # write changes
   ```

2. Format `/dev/sdX1` as FAT32 and label it `PVE-LIVE`:
   ```
   mkfs.vfat -F 32 -n "PVE-LIVE" /dev/sdX1
   ```

3. Mount `/dev/sdX1` and copy ISO content to it:
   ```
   mkdir /tmp/partition1 && mkdir /tmp/iso_mount
   mount /dev/sdX1 /tmp/partition1
   mount /path/to/pve-live-iso /tmp/iso_mount
   cp -r /tmp/iso_mount/* /tmp/partition1/ && sync
   ```

4. Format `/dev/sdX2` with ext4 and label it `persistence`:
   ```
   mkfs.ext4 -L persistence /dev/sdX2
   ```

5. Mount `/dev/sdX2` and create `persistence.conf`:
   ```
   mkdir /tmp/partition2
   mount /dev/sdX2 /tmp/partition2
   echo "/ union" > /tmp/partition2/persistence.conf
   umount /tmp/partition1 /tmp/iso_mount /tmp/partition2
   ```

---

### macOS

> [!Note]
> Replace `diskX` with your actual USB drive identifier.

1. Create partitions with `diskutil`:
   ```
   diskutil list
   diskutil partitionDisk diskX 2 MBR FAT32 "PVE-LIVE" 2g ExFAT "persistent" 0
   diskutil unmountDisk /dev/diskX
   sudo fdisk -e /dev/diskX <<< $'flag 1\nwrite\nexit\n'
   diskutil mount diskXs1
   ```

2. Copy ISO contents to the USB:
   - Download and extract 7-zip: https://www.7-zip.org/a/7z2501-mac.tar.xz
   ```
   cd ~/Downloads/7z2501-mac
   ./7zz x ~/Downloads/pve-9_live_lxde.iso -o/Volumes/PVE-LIVE && sync
   diskutil unmountDisk /dev/diskX
   ```

4. Boot from the USB and create the persistence partition:
   - See **Step 4: Format `/dev/sdX2`** in the [Linux](#linux) section.

---

## How to build

**Requirements:**
- Host: Debian 13
- Packages:
   ```
   apt update && apt install -y live-build git
   ```

**Steps:**
1. Clone the repository:
   ```
   git clone https://github.com/LongQT-sea/pve-live.git
   cd pve-live
   ```
2. Customization (optional)
   - Hook scripts: `config/hooks/normal/`
   - Add files to the root filesystem: `config/includes.chroot/`

3. Start the build:
   ```
   lb config && lb build
   ```
4. After building, rename the ISO:
   ```
   mv live-image-amd64.hybrid.iso proxmox-ve_9.0_lxde_live.iso
   ```
5. Cleanup before the next build:
   ```
   lb clean
   ```

## License

This project redistributes **Proxmox VE** (Copyright © 2008–2026 Proxmox Server Solutions GmbH) under the **AGPL-3.0** license.