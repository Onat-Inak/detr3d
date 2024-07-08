#!/bin/bash

# export PYTHONPATH=$PYTHONPATH:/workspace/:/workspace/projects
# python ./tools/train.py projects/configs/StreamPETR/stream_petr_vov_flash_800_bs2_seq_24e.py --work-dir work_dirs/stream_petr_vov_flash_800_bs2_seq_24e

# set -ex

# proxy to be used inside the docker, leave blank if you are not using
# a proxy server
# : "${INSIDE_DOCKER_PROXY:=172.17.0.1:3128}"

source $(dirname "$0")/set_project_env.sh
DATADIR="$HOME/data/datasets/nuscenes/v1.0-mini"
WORKDIR="$HOME/workspace/detr3d" 
# MODELDIR="$HOME/data/models"
# INFERENCE_MODELDIR="$HOME/data/inference_models"

# BACKBONEDIR="$HOME/data/backbones"

docker run \
    --user $USER \
    --shm-size=8gb \
    --gpus all \
    --mount type=bind,source=$WORKDIR,target=/workspace \
    --mount type=bind,source=$DATADIR,target=/workspace/data/nuscenes \
    -e PROJECT_NAME=$PROJECT_NAME \
    -e WANDB_BASE_URL=$WANDB_BASE_URL \
    -e WANDB_API_KEY=$WANDB_API_KEY \
    -e WANDB_USERNAME=$WANDB_USERNAME \
    -e IS_LOCAL_RUN=1 \
    -it \
    --name=detr3d \
    detr3d:v1.0