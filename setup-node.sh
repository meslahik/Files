#!/bin/bash

###############
# setup-node.sh
#
# Mojtaba Eslahi <eslahm@usi.ch>
# Novemeber 3, 2021
#
# Purpose: install package dependencies for Heron, set up system config
###############

# show the commands that are run for debugging in /root/setup/setup-node.log
set -x

USER_HOME=/users/meslahik

FLAG="/opt/.firstboot"
SETUPFLAG="/opt/.setup_in_process"
# FLAG will not exist on the *very* fist boot because
# it is created here!
if [ ! -f $FLAG ]; then
   sudo touch $FLAG
   sudo touch $SETUPFLAG
   REBOOT=yes
fi

# install packages
DEBIAN_FRONTEND=noninteractive sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y libibverbs-dev libmemcached-dev python3 python3-pip cmake ninja-build clang lld clang-format
sudo pip3 install --upgrade conan
sudo ln -s -f /users/meslahik/.local/bin/conan /usr/bin
sudo conan profile new default --detect
sudo conan profile update settings.compiler.libcxx=libstdc++11 default
DEBIAN_FRONTEND=noninteractive sudo apt-get update && sudo apt-get -y install vim tmux git memcached libevent-dev libhugetlbfs-dev libgtest-dev libnuma-dev numactl libgflags-dev ibverbs-utils rdmacm-utils
cd /usr/src/gtest && sudo cmake CMakeLists.txt && sudo make && sudo make install

# install oh-my-zsh
ZSH="$USER_HOME/.oh-my-zsh" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sudo sed -i 's/auth       required   pam_shells.so//g' /etc/pam.d/chsh
sudo groupadd chsh
sudo usermod -a -G chsh meslahik
sudo chsh -s $(which zsh)

NOBODY_USR_GRP="nobody:nogroup"
sudo locale-gen en_US

for module in ib_umad ib_uverbs rdma_cm rdma_ucm ib_qib mlx4_core mlx4_en mlx4_ib; do
  echo $module | sudo tee -a /etc/modules
done

cat <<EOF | sudo tee $USER_HOME/.ssh/id_rsa
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAYEAzlSlqG9fm/TfU05wiiP976o0U9EcIifq9LiugcTEQ5Y0n+OnQAlT
B6+59SWgFpv8LNu2Nfkv8RyCXkMD+pB2NQbnM0pPb4PRGSc5N8/d/Q7MpCpNbBKvobUieJ
3Cv9H97kaYbx6ePDQvgVt4xE9VsrrHsGJzncTo7Esw8ynOlqkfHKOOLq4J9JDt9JjJkGT/
xGQfkTo4mgadMsCXHdLk2Xq8CitSoVFmWN70HNE4yAt/HS1hZ8oh2K13LxcPVErDloUkX7
kADxriyyNq2P7j3EcuNyiTIf/4TCv0daqzuj/vCVKDfcJGseGAq7VI6zJ5sCzzMn1JiNbG
UMckm6p/lmmvd5pYVYhUiIqG2oeuarEt42XHYFKThqc8nb/TxRRXCsjkQOOPHCzjbVZAvS
99T9HymYPcSLrgzT8YzkyF4FljKa9CwC5cvV4hEh28ouu82l3pEsEG43LEc74UhK0arWQb
6eAR4GT1Bi7ozpaE+lHj0uXcrcDpKXZL6TWyr54jAAAFmCtgUXwrYFF8AAAAB3NzaC1yc2
EAAAGBAM5UpahvX5v031NOcIoj/e+qNFPRHCIn6vS4roHExEOWNJ/jp0AJUwevufUloBab
/CzbtjX5L/Ecgl5DA/qQdjUG5zNKT2+D0RknOTfP3f0OzKQqTWwSr6G1Inidwr/R/e5GmG
8enjw0L4FbeMRPVbK6x7Bic53E6OxLMPMpzpapHxyjji6uCfSQ7fSYyZBk/8RkH5E6OJoG
nTLAlx3S5Nl6vAorUqFRZlje9BzROMgLfx0tYWfKIditdy8XD1RKw5aFJF+5AA8a4ssjat
j+49xHLjcokyH/+Ewr9HWqs7o/7wlSg33CRrHhgKu1SOsyebAs8zJ9SYjWxlDHJJuqf5Zp
r3eaWFWIVIiKhtqHrmqxLeNlx2BSk4anPJ2/08UUVwrI5EDjjxws421WQL0vfU/R8pmD3E
i64M0/GM5MheBZYymvQsAuXL1eIRIdvKLrvNpd6RLBBuNyxHO+FIStGq1kG+ngEeBk9QYu
6M6WhPpR49Ll3K3A6Sl2S+k1sq+eIwAAAAMBAAEAAAGAERoDAQr6KbsKJ6WAvnJtQcghvj
C+3DXiy5XjIO5mNhPlGLuNyUj8kM6H40HTGwyiwjUTzTVyO9HZHGcBlWsT4SFJWH74Ro3u
bt9JZs7b33WykIjREfwagpS43rZ0xeFp4q4HRG6NPwA0T8x9HghVWhMRKhV+77y6cZtp2z
3D2cj6wyzrRAM44ASDNJrVWhqE+Ioz852Xw2x46xP7coVgYoZBv7YHi0dr7EHOifTtd+c8
CfcQ88FVPNhj4ItQwfPQTDBBJ8tBvCyTC4K/wuqSoNaZJ0pU38N2lQtd7VrPumVlYkLbdI
eNBBVUBi1TMNas6ixTFBKp1LgmyGzslhpZY5JLikC4dRrJKEPW+hf9zYUyM0OaKvthBB02
wkyP6bQ6PxU63xpd+SK4vIitIagIEeNmRFt6FEW8NzrvScvNlTe0XZtlW/iX6QFdlfhRns
VViLn2rLM7HHNn1VGFmqlpFmidzFU+OFCIKeu12IBfXD8q4uXgnDPz/PhV3heEkxGBAAAA
wQCNvJ25M10SsC5zlnA3M+M1og30HWAFdq0OY/rIunHEjIJ2yWwfFhNVeAgQjknQiXaG8v
rDRCfdEgldTSTp6aWPx2IVD9GZZA06Tikz3YfnQIrWGBuKV6eOse8E5kSyBOirb5eRry9g
iwP4l+XET2NzS+4Gn58Vhfaqc5CCr+FbM7mAORpcRpUwPpuohm7/6brFaf6ZOE5Zg/eVpV
ihNsss8JYfafkXofWrzkdkhf3ZrhUFy5DtE85oY36i//C+sucAAADBAO9St8qACBRNF7Ev
ZxrTDi+yi1iypRvUlBnpmesSyAzJ83jNTvd81wLyy3CufbeNSeQmAV4OY5j7eYFwTk4uex
xO8B2/sJZX4O5Y5HOzzI/TcVKjibGT0jSawQkkV7ZWhZ/1YA9meRpAbF4NP+0lSEiLO3uA
f93X5HkuASycDqxxrHbl9g8C9rp/yP20D4Tk8szZtd9jpGZcdiF7XVM003EF9BjDHGVUIs
Ylxhz5vlM34otp1IEy5ePqH7C9tu5ZywAAAMEA3LVghAxoXCfwbD+kdy42aKiGUIj2OExF
QaAXxiDrDh1kZMYpPh4nH41uL0ZyT3UIi9/dEyAy4Q8qGK8zqYdaKN7XpK5qZO1sS4mEVk
mE2Nb2mwrAMzJQPKRJ1g2ectXC7y/Ln7XHC1EK43vStKaXV2tHh3951lj4s35/2DZWuwIH
4q4DlDwug1+65ECZjg1fcjStCu7s3y782Yx5in6C0HVVNCCb3SaqjAMdN4pO6wkUaQD02Q
Rjvx90rvpO9KIJAAAAH21lc2xhaGlrQE1vanRhYmFzLU1CUC51c2lsdS5uZXQBAgM=
-----END OPENSSH PRIVATE KEY-----
EOF
sudo chmod 400 $USER_HOME/.ssh/id_rsa

# set the amount of locked memory. will require a reboot
sudo cat <<EOF  | sudo tee /etc/security/limits.d/90-rmda.conf
* soft memlock unlimited
* hard memlock unlimited
EOF

# setting up required library
sudo mkdir $USER_HOME/apps
sudo mkdir $USER_HOME/apps/SharedMemorySSMR

# # set default java 8
# sudo  update-java-alternatives --set /usr/lib/jvm/java-1.8.0-openjdk-amd64

# install java
sudo mkdir java
cd java
wget https://www.dropbox.com/s/qrgb17l734b3whn/OpenJDK11U-jdk_x64_linux_hotspot_11.0.11_9.tar.gz
export JAVA_HOME=$USER_HOME/java/jdk-11.0.11+9

cd $USER_HOME/apps/SharedMemorySSMR
sudo git clone https://github.com/zrlio/disni
cd disni
# JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 sudo mvn -DskipTests install
sudo mvn -DskipTests install
cd libdisni
sudo ./autoprepare.sh
sudo ./configure --with-jdk=$USER_HOME/java/jdk-11.0.11+9
sudo make
sudo make install

# cd $USER_HOME/apps
# sudo git clone https://github.com/osdi2020-no-152/dory
# cd dory
# sudo git checkout crash-consensus-gcc-only
# sudo ./build.py crash-consensus
# sudo crash-consensus/libgen/export.sh gcc-release
# sudo crash-consensus/demo/using_conan_fully/build.sh gcc-release
# sudo crash-consensus/experiments/build.sh
# sudo crash-consensus/experiments/liquibook/build.sh
# export LD_LIBRARY_PATH=$HOME/apps/dory/crash-consensus/experiments/exported:$LD_LIBRARY_PATH
# echo "export LD_LIBRARY_PATH=$HOME/apps/dory/crash-consensus/experiments/exported:$LD_LIBRARY_PATH" >> ~/.bashrc

sudo chown -R meslahik:scalingsmr-PG0 $USER_HOME

if [[ "$REBOOT" == "yes" ]]; then
  # enact the change to the locked memory limits
  sudo reboot
fi