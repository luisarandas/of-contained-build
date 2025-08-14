#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}"
LIBS_DIR="${ROOT_DIR}/libs"
OF_DIR="${LIBS_DIR}/openFrameworks"
# OF_GIT_REF is now set by the main script after auto-detection

# Color codes for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo -e "${RED}Missing required tool: $1${NC}"; exit 1; }
}

clone_of() {
  if [ -d "${OF_DIR}" ]; then
    echo -e "${GREEN}openFrameworks already present at ${OF_DIR}${NC}"
    echo -e "${BLUE}Checking if update is needed...${NC}"
    cd "${OF_DIR}"
    CURRENT_REF=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
    REMOTE_REF=$(git ls-remote origin "${OF_GIT_REF}" | cut -f1)
    
    if [ "$CURRENT_REF" != "$REMOTE_REF" ]; then
      echo -e "${BLUE}Updating openFrameworks to ${OF_GIT_REF}...${NC}"
      git fetch origin "${OF_GIT_REF}" || { echo -e "${RED}Failed to fetch ${OF_GIT_REF}${NC}"; exit 1; }
      git reset --hard "origin/${OF_GIT_REF}" || { echo -e "${RED}Failed to reset to ${OF_GIT_REF}${NC}"; exit 1; }
      echo -e "${GREEN}Updated to ${OF_GIT_REF}${NC}"
    else
      echo -e "${GREEN}Already at correct version ${OF_GIT_REF}${NC}"
    fi
    cd - >/dev/null
    return
  fi
  
  need_cmd git
  mkdir -p "${LIBS_DIR}"
  echo -e "${BLUE}Cloning openFrameworks (${OF_GIT_REF}) into ${OF_DIR}...${NC}"
  if ! git clone --depth 1 --branch "${OF_GIT_REF}" https://github.com/openframeworks/openFrameworks "${OF_DIR}"; then
    echo -e "${RED}Failed to clone openFrameworks ${OF_GIT_REF}${NC}"
    echo -e "${YELLOW}Trying to clone master branch instead...${NC}"
    if ! git clone --depth 1 https://github.com/openframeworks/openFrameworks "${OF_DIR}"; then
      echo -e "${RED}Failed to clone openFrameworks repository${NC}"
      exit 1
    fi
    echo -e "${GREEN}Cloned master branch successfully${NC}"
  else
    echo -e "${GREEN}Cloned ${OF_GIT_REF} successfully${NC}"
  fi
}

download_of_libs_macos() {
  echo -e "${BLUE}Ensuring macOS platform libraries are present...${NC}"
  if [ -x "${OF_DIR}/scripts/osx/download_libs.sh" ]; then
    echo -e "${BLUE}Running macOS library download script...${NC}"
    (cd "${OF_DIR}" && ./scripts/osx/download_libs.sh) || {
      echo -e "${YELLOW}Library download script failed, but continuing...${NC}"
    }
  else
    echo -e "${YELLOW}scripts/osx/download_libs.sh not found. If you used a source release that bundles libs, this is OK.${NC}"
  fi
  
  # Verify essential directories exist
  if [ ! -d "${OF_DIR}/libs/openFrameworksCompiled" ]; then
    echo -e "${RED}Error: openFrameworksCompiled directory not found. Build may fail.${NC}"
    echo -e "${YELLOW}This usually means the libraries weren't downloaded properly.${NC}"
    exit 1
  fi
}

build_app_with_make() {
  APP_DIR="${ROOT_DIR}/projects/my_new_app1"
  
  # Verify project structure
  if [ ! -f "${APP_DIR}/Makefile" ]; then
    echo -e "${RED}Error: Makefile not found in ${APP_DIR}${NC}"
    exit 1
  fi
  
  if [ ! -d "${APP_DIR}/src" ]; then
    echo -e "${RED}Error: src directory not found in ${APP_DIR}${NC}"
    exit 1
  fi
  
  echo -e "${BLUE}Building my_new_app1...${NC}"
  export OF_ROOT="${OF_DIR}"
  
  # Auto-detect optimal number of cores
  CORES="$( (sysctl -n hw.logicalcpu) 2>/dev/null || nproc || echo 4 )"
  echo -e "${BLUE}Using $CORES cores for parallel build...${NC}"
  
  # Clean previous build artifacts
  echo -e "${BLUE}Cleaning previous build...${NC}"
  make -C "${APP_DIR}" clean || true
  
  # Build the project
  if ! make -C "${APP_DIR}" -j"${CORES}"; then
    echo -e "${RED}Build failed. Check the error messages above.${NC}"
    echo -e "${YELLOW}Common issues:${NC}"
    echo "   - Missing dependencies"
    echo "   - openFrameworks not properly cloned"
    echo "   - Platform libraries not downloaded"
    exit 1
  fi
  
  echo -e "${GREEN}Build successful!${NC}"
  
  # Try to run the app
  echo -e "${BLUE}Running my_new_app1...${NC}"
  if make -C "${APP_DIR}" RunRelease; then
    echo -e "${GREEN}App ran successfully!${NC}"
  else
    echo -e "${YELLOW}App run failed, but build was successful${NC}"
    echo -e "${YELLOW}You can run it manually with: make -C ${APP_DIR} RunRelease${NC}"
  fi
}
