# Define space for new SSD partitions
ssd_boot_start_mb=1 \
ssd_boot_end_mb=512 \
\
ssd_swap_start_mb=$(($ssd_boot_end_mb + 1)) \
ssd_swap_end_mb=$(($ssd_swap_start_mb + 8 * 1024)) \
\
ssd_data_start_mb=$(($ssd_swap_end_mb + 1)) \
ssd_data_end_mb="100%"

# Make SSD partitions, saving their names
# First, gpt partition table
sudo parted -s /dev/nvme0n1 mklabel gpt

# Then, data
sudo parted -s /dev/nvme0n1 mkpart primary ext4 ${ssd_data_start_mb}MiB ${ssd_data_end_mb}
ssd_data_partition=/dev/nvme0n1p1
sudo mkfs.ext4 -F -L data $ssd_data_partition

# Then, boot
sudo parted -s /dev/nvme0n1 mkpart primary ext4 ${ssd_boot_start_mb}MiB ${ssd_boot_end_mb}MiB
ssd_boot_partition=/dev/nvme0n1p2
sudo parted /dev/nvme0n1 set 2 boot on
sudo mkfs.fat -F 32 -n boot $ssd_boot_partition

# Then, swap
sudo parted -s /dev/nvme0n1 mkpart primary linux-swap ${ssd_swap_start_mb}MiB ${ssd_swap_end_mb}MiB
ssd_swap_partition=/dev/nvme0n1p3
sudo mkswap -L swap $ssd_swap_partition

zfs_pool="rootpool"

# Mount ZFS datasets
sudo mkdir -p /mnt
sudo mount -t zfs $ssd_data_partition /mnt

# Mount boot partition
sudo mkdir -p /mnt/boot
sudo mount $ssd_boot_partition /mnt/boot
