#!/bin/bash

EXACUTION_DIR=$(dirname $0)
FILE_URL=https://k8s-deploy.ap-host.net


# Ensure we're running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo." 
  exit 1
fi

wget -q -P "$EXACUTION_DIR" "$FILE_URL/session.sh"

echo "Starting Tmux Server"
tmux start-server

# Run tmux session if not already running
if [ -z "$TMUX" ]; then
  echo "\n Launching inside tmux session: deploy_session \n"

  if tmux has-session -t deploy_session 2>/dev/null; then
    tmux attach -t deploy_session
  else
    tmux new-session -s deploy_session "sudo sh $EXACUTION_DIR/session.sh"
  fi
fi