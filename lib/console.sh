#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RESET="\033[0m"

log() {
  echo "[$(date '+%F %T')] $1"
}

info() {
  echo -e "${CYAN}[INFO]${RESET} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${RESET} $1"
}

error() {
  echo -e "${RED}[ERROR]${RESET} $1"
}