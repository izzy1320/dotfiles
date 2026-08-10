#!/bin/bash
uid=$(id -u )
if [ $(id -u) -ne 0 ]
then
   echo "You must be root.  Aborting."
   exit 1
fi

set -o nounset

games_grp='user.slice/cache_hungry'

vcache_cores='0-7,16-23'
regular_cores='8-15,24-31'

echo "Gaming/Lutris cgroup: /sys/fs/cgroup/$games_grp"

[ -d /sys/fs/cgroup/$games_grp ] && echo "Found existing lutris cgroup" || mkdir /sys/fs/cgroup/$games_grp
[ -d /sys/fs/cgroup/$games_grp ] || exit

echo Enabling CPU-Set Controller
echo "+cpuset" > /sys/fs/cgroup/cgroup.subtree_control || exit
echo "+cpuset" > /sys/fs/cgroup/user.slice/cgroup.subtree_control || exit
echo "+cpuset" > /sys/fs/cgroup/$games_grp/cgroup.subtree_control || exit
more /sys/fs/cgroup/user.slice/cgroup.controllers /sys/fs/cgroup/$games_grp/cgroup.controllers |cat

echo Assigning CPUs
echo "$vcache_cores" > /sys/fs/cgroup/$games_grp/cpuset.cpus || exit

echo Restricing other cgroups
for slice in /sys/fs/cgroup/user.slice/user-*.slice 
do
#/sys/fs/cgroup/user.slice/user@*.service; do
    echo " - '$slice'"
    echo "+cpuset" > $slice/cgroup.subtree_control || exit
    echo "$regular_cores" > $slice/cpuset.cpus
done
