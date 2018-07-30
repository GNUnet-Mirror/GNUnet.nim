#!/bin/bash
CONFIG_OUR_PEER=gnunet.conf
CONFIG_OTHER_PEER=otherpeer.conf

gnunet-arm -c $CONFIG_OUR_PEER -e
gnunet-arm -c $CONFIG_OTHER_PEER -e
