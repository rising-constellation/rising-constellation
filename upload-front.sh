#!/bin/bash

source ./nodes.sh

for node in "${NODES[@]}"
do
  scp ./build/vue.tar.gz $node:/home/rc/
  ssh $node "chown -R rc: /home/rc/vue.tar.gz"
done

