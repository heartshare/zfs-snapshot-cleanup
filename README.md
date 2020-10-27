# zfs-snapshot-cleanup
Removes ZFS Snapshots

Usage:
  ./zfs-snapshot-cleanup.bash --dataset=volsata01 --keepdays=7
  
  ./zfs-snapshot-cleanup.bash --dataset=volsata01/nas --keepdays=7 --include='backup' --exclude='2d|2w|8w'
  
  ./zfs-snapshot-cleanup.bash --dataset=volsata01 --keepdays=0 --exclude='\.system' --force
