#!/bin/bash
SUB="c5494177-1a20-4382-8f2e-8f79c4c72f48"
RG="BLRS-COM"
TYPE="azurerm_virtual_network"
echo $SUB
echo $RG
echo $TYPE
/vagrant/az2tf/az2tf.sh -s "/subscriptions/c5494177-1a20-4382-8f2e-8f79c4c72f48" -g "BLRS-COM"