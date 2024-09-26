#!/bin/bash

curr_dir=`dirname $0`
cd $curr_dir
curr_dir=`pwd`


export TOOLKIT_IMAGE="ibm-concert-toolkit:v1"

export HOST_DIR_SRC_CODE=$(dirname $(dirname $(readlink -f "${BASH_SOURCE[0]}")))

export HOST_DIR_MNT=$(basename $HOST_DIR_SRC_CODE)
export HOST_DIR_TOOLKIT_DATA="${curr_dir}/generated"
mkdir -p ${HOST_DIR_TOOLKIT_DATA}
export TOOLKIT_RUN="docker run \
  -v ${HOST_DIR_SRC_CODE}:/${HOST_DIR_MNT} \
  -v ${HOST_DIR_TOOLKIT_DATA}:/toolkit-data \
  --rm \
  ${TOOLKIT_IMAGE}"


${DRY_RUN} ${TOOLKIT_RUN} $*
