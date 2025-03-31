#!/bin/sh
_step_counter=0
step() {
	_step_counter=$(( _step_counter + 1 ))
	printf '\n\033[1;36m%d) %s\033[0m\n' $_step_counter "$@" >&2
}

step "Setup display"
echo "vc4" >> "$ROOTFS_PATH"/etc/modules

step "Setup Wi-Fi"
mkdir -p "$DATAFS_PATH"/etc/NetworkManager/system-connections
chroot_exec apk add --no-cache wireless-tools wpa_supplicant
chroot_exec rc-update add wpa_supplicant default
echo "brcmfmac" >> "$ROOTFS_PATH"/etc/modules

cat >> "$ROOTFS_PATH"/etc/network/interfaces.alpine-builder <<EOF

auto wlan0
iface wlan0 inet dhcp
EOF

cp "$ROOTFS_PATH"/etc/network/interfaces.alpine-builder "$DATAFS_PATH"/etc/network/interfaces

WPA_PATH=/etc/wpa_supplicant
WPA_CONF=${WPA_PATH}/wpa_supplicant.conf
WPA_CONF_HOST=${ROOTFS_PATH}${WPA_PATH}/wpa_supplicant.conf
mkdir -p ${WPA_PATH}
touch ${WPA_CONF}

cat >> "${WPA_CONF_HOST}" << EOF
ap_scan=1
autoscan=periodic:10
disable_scan_offload=1
EOF

step "Setup SSH authorized_keys"
mkdir -p "$DATAFS_PATH"/root/.ssh
cp "$INPUT_PATH"/ssh/authorized_keys "$DATAFS_PATH"/root/.ssh/authorized_keys

step "Install packages"
chroot_exec apk add \
  --no-cache \
  bash \
  cage \
  chromium \
  clang \
  cmake \
  curl \
  eudev \
  gcompat \
  git \
  go \
  gstreamer-dev \
  gst-plugins-base-dev \
  gtk+3.0-dev \
  gphoto2 \
  libgphoto2-dev \
  ffmpeg \
  libinput \
  libc-dev \
  linux-firmware-brcm \
  linux-headers \
  make \
  mesa-dri-gallium \
  ninja \
  networkmanager \
  networkmanager-cli \
  networkmanager-wifi \
  openssh-sftp-server \
  rsync \
  seatd \
  shadow \
  supervisor \
  sway \
  swaybg \
  tailscale \
  wpa_supplicant \
  wlroots-dev


step "Configure OpenGL"
sed -i 's|gpu_mem=16|# gpu_mem=16|' "$BOOTFS_PATH"/config.txt
sed -i 's|gpu_mem_256=64|# gpu_mem_256=64|' "$BOOTFS_PATH"/config.txt
echo "gpu_mem=256" >> "$BOOTFS_PATH"/config.txt

step "Enable services"
chroot_exec rc-update add networkmanager default
chroot_exec rc-update add seatd default
chroot_exec rc-update add --quiet udev sysinit
chroot_exec rc-update add --quiet udev-trigger sysinit
chroot_exec rc-update add --quiet udev-settle sysinit
chroot_exec rc-update add --quiet udev-postmount default
chroot_exec rc-update add --quiet tailscale default

mkdir -p "$ROOTFS_PATH"/opt/kmodules
mkdir -p "$ROOTFS_PATH"/var/lib/tailscale


mkdir -p "$DATAFS_PATH"/home/kiosk
cp -R "$ROOTFS_PATH/etc/dropbear" "$DATAFS_PATH/etc/"

step "Setup GPIO"
chroot_exec addgroup gpio

step "Setup kiosk user"
chroot_exec adduser -D kiosk
chroot_exec addgroup kiosk gpio
chroot_exec addgroup kiosk video
chroot_exec addgroup kiosk seat
chroot_exec addgroup kiosk input
chroot_exec addgroup kiosk plugdev
chroot_exec chsh -s /bin/bash kiosk
cp "$INPUT_PATH"/home/kiosk/.bashrc "$DATAFS_PATH"/home/kiosk/.bashrc

step "Add lightd"
mkdir -p "$ROOTFS_PATH"/opt/bin
cp "$INPUT_PATH"/opt/bin/lightd "$ROOTFS_PATH"/opt/bin/lightd
cp "$INPUT_PATH"/etc/init.d/lightd "$ROOTFS_PATH"/etc/init.d/lightd
chroot_exec rc-update add lightd default

step "Setup inittab"
cp "$INPUT_PATH"/etc/inittab "$ROOTFS_PATH"/etc/inittab

step "Setup udev"
cp "$INPUT_PATH"/etc/udev/rules.d/* "$ROOTFS_PATH"/etc/udev/rules.d/

step "Add local.d scripts"
cp "$INPUT_PATH"/etc/local.d/*.start "$ROOTFS_PATH"/etc/local.d/
