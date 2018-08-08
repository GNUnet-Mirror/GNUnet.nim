#!/bin/bash
CONFIG1=gnunet1.conf
CONFIG2=gnunet2.conf
CONFIG3=gnunet3.conf

gnunet-arm -c $CONFIG1 -s
echo "peer 1: $(gnunet-peerinfo -c ${CONFIG1} -sq)"
gnunet-arm -c $CONFIG2 -s
echo "peer 2: $(gnunet-peerinfo -c ${CONFIG2} -sq)"
gnunet-arm -c $CONFIG3 -s
echo "peer 3: $(gnunet-peerinfo -c ${CONFIG3} -sq)"
gnunet-peerinfo -c $CONFIG1 -p $(gnunet-peerinfo -c $CONFIG2 -g)
gnunet-peerinfo -c $CONFIG1 -p $(gnunet-peerinfo -c $CONFIG3 -g)
gnunet-peerinfo -c $CONFIG2 -p $(gnunet-peerinfo -c $CONFIG1 -g)
gnunet-peerinfo -c $CONFIG2 -p $(gnunet-peerinfo -c $CONFIG3 -g)
gnunet-peerinfo -c $CONFIG3 -p $(gnunet-peerinfo -c $CONFIG1 -g)
gnunet-peerinfo -c $CONFIG3 -p $(gnunet-peerinfo -c $CONFIG2 -g)
