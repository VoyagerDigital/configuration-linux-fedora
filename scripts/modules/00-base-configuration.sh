#!/usr/bin/env bash
set -euo pipefail

##### UPDATE SYSTEM #####
sudo dnf update \
    -y

##### ENABLE RPM FUSION REPOSITORIES #####
sudo dnf install \
    -y \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

##### SETUP DIRECTORY STRUCTURE #####
mkdir \
    -p "$HOME/repositories" \
    -p "$HOME/repositories/github" \
    -p "$HOME/repositories/github/VoyagerDigital" \

##### INSTALL BASE PACKAGES #####
sudo dnf install \
    -y \
    yq

##### CONFIGURE GIT #####
git config \
    --global \
    user.name "Michiel Van Herreweghe"

git config \
    --global \
    user.email "169037533+MichielVanHerreweghe@users.noreply.github.com"