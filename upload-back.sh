#!/bin/bash

source ./nodes.sh

for node in "${NODES[@]}"
do
  scp ./build/rc.tar.gz $node:/home/rc/
  ssh $node "chown -R rc: /home/rc/rc.tar.gz"
done

