#!/bin/bash
CONFIG_OUR_PEER=gnunet.conf
CONFIG_OTHER_PEER=otherpeer.conf

gnunet-arm -c $CONFIG_OUR_PEER -s
echo "our peer: $(gnunet-peerinfo -c ${CONFIG_OUR_PEER} -sq)"
gnunet-arm -c $CONFIG_OTHER_PEER -s
echo "other peer: $(gnunet-peerinfo -c ${CONFIG_OTHER_PEER} -sq)"
gnunet-peerinfo -c $CONFIG_OUR_PEER -p $(gnunet-peerinfo -c $CONFIG_OTHER_PEER -g)
gnunet-peerinfo -c $CONFIG_OTHER_PEER -p $(gnunet-peerinfo -c $CONFIG_OUR_PEER -g)
