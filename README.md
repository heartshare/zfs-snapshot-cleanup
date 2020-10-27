# zfs-snapshot-cleanup
Removes ZFS Snapshots based on parameters you define.

**DATASET** = ZFS Dataset/ZVOL you want to clean up  
**KEEPDAYS** = Number of days to keep (snapshots older than this will be targeted). 0 removes all snapshots  
**INCLUDE** = Regex to filter snapshots (egrep '$INCLUDE')  
**EXCLUDE** = Regex to filter snapshots (egrep -v '$EXCLUDE')  
**FORCE** = Do not ask for confirmation  

## Usage:

./zfs-snapshot-cleanup.bash --dataset=volsata01 --keepdays=7  
./zfs-snapshot-cleanup.bash --dataset=volsata01/nas --keepdays=7 --include='backup' --exclude='2d|2w|8w'  
./zfs-snapshot-cleanup.bash --dataset=volsata01 --keepdays=0 --exclude='\.system' --force  
