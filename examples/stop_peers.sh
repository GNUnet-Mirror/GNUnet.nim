#!/bin/sh
CONFIG1=gnunet1.conf
CONFIG2=gnunet2.conf
CONFIG3=gnunet3.conf

gnunet-arm -c $CONFIG1 -e
gnunet-arm -c $CONFIG2 -e
gnunet-arm -c $CONFIG3 -e
