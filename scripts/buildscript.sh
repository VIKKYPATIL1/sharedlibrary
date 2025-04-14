#!/bin/bash

# --- Input Parameters ---
GIT_REPO=$1
GIT_BRANCH=$2
VERSION=$3
WORKDIR="/tmp/build_workspace"

# --- Function to log and exit on error ---
exit_on_failure() {
  echo "[ERROR] $1"
  exit 1
}

echo "Starting Build Script..."
echo "Git Repo: $GIT_REPO"
echo "Branch: $GIT_BRANCH"
echo "Version: $VERSION"

# --- Clean up previous workspace ---
echo "Cleaning up previous build directory..."
rm -rf $WORKDIR
mkdir -p $WORKDIR || exit_on_failure "Unable to create workspace directory."

cd $WORKDIR

# --- Git Check: Ping Git Server ---
echo "Checking Git server accessibility..."
ping -c 1 github.com > /dev/null 2>&1 || exit_on_failure "Git server not reachable."

# --- Clone repository with branch validation ---
echo "Cloning repository..."
git ls-remote --heads $GIT_REPO $GIT_BRANCH > /dev/null 2>&1 || exit_on_failure "Branch $GIT_BRANCH does not exist in repo."
git clone -b $GIT_BRANCH $GIT_REPO project || exit_on_failure "Git clone failed."

cd project || exit_on_failure "Cloned directory not found."

# --- Confirm correct repository ---
echo "Verifying repository content..."
if [ ! -f "pom.xml" ]; then
  exit_on_failure "Invalid repository: Maven POM file not found."
fi

# --- Run Maven Build ---
echo "Starting Maven build..."
mvn clean install -Dproject.version=$VERSION || exit_on_failure "Maven build failed."

echo "[SUCCESS] Build completed successfully."
