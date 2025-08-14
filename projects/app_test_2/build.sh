#!/usr/bin/env bash
set -euo pipefail

# Color codes for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and set paths
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${HERE}/../.." && pwd)"
OF_DIR="${ROOT_DIR}/libs/openFrameworks"

# Check if openFrameworks is available
if [ ! -d "${OF_DIR}" ]; then
    echo -e "${RED}Error: openFrameworks not found at ${OF_DIR}${NC}"
    echo -e "${YELLOW}Please run ./build_project_macos122.sh first to set up openFrameworks${NC}"
    exit 1
fi

# Set environment variables
export OF_ROOT="${OF_DIR}"

# Auto-detect optimal number of cores
CORES="$( (sysctl -n hw.logicalcpu) 2>/dev/null || nproc || echo 4 )"
echo -e "${BLUE}Using $CORES cores for parallel build...${NC}"

# Build the project
echo -e "${BLUE}Building $(basename ${HERE})...${NC}"
if ! make -j"${CORES}"; then
    echo -e "${RED}Build failed. Check the error messages above.${NC}"
    exit 1
fi

echo -e "${GREEN}Build successful!${NC}"
echo -e "${BLUE}To run the app:${NC}"
echo "  make RunRelease"
echo "  make RunDebug"
