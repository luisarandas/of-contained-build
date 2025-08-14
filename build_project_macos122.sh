#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${HERE}/common.sh"

# Color codes for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Checking for Apple Command Line Tools (clang, make)...${NC}"
if ! xcode-select -p >/dev/null 2>&1; then
  echo -e "${RED}Xcode Command Line Tools not detected. Installing prompt will appear...${NC}"
  xcode-select --install || true
  echo -e "${YELLOW}Re-run this script after the CLT install completes.${NC}"
  exit 1
fi

need_cmd clang
need_cmd make
need_cmd git

# Auto-detect best openFrameworks version if not specified
if [ -z "${OF_GIT_REF:-}" ]; then
  echo -e "${BLUE}Auto-detecting best openFrameworks version...${NC}"
  
  # Get all available version tags and find the latest stable
  echo -e "${BLUE}Fetching available versions from openFrameworks repository...${NC}"
  AVAILABLE_VERSIONS=$(git ls-remote --tags https://github.com/openframeworks/openFrameworks 2>/dev/null | \
    grep -E "refs/tags/[0-9]+\.[0-9]+\.[0-9]+$" | \
    sed 's|.*refs/tags/||' | \
    sort -V)
  
  if [ -n "$AVAILABLE_VERSIONS" ]; then
    # Get the latest version
    LATEST_VERSION=$(echo "$AVAILABLE_VERSIONS" | tail -1)
    export OF_GIT_REF="$LATEST_VERSION"
    echo -e "${GREEN}Auto-selected latest stable version: $OF_GIT_REF${NC}"
    echo -e "${BLUE}Available versions (last 10):${NC}"
    echo "$AVAILABLE_VERSIONS" | tail -10 | sed 's/^/  - /'
  else
    # Fallback to master if tag detection fails
    export OF_GIT_REF="master"
    echo -e "${YELLOW}Could not detect version tags, using master branch${NC}"
  fi
else
  echo -e "${GREEN}Using specified openFrameworks version: $OF_GIT_REF${NC}"
fi

# Validate the version exists before proceeding
echo -e "${BLUE}Validating openFrameworks version availability...${NC}"
AVAILABLE_VERSIONS=$(git ls-remote --heads --tags https://github.com/openframeworks/openFrameworks 2>/dev/null | \
  grep -E "refs/tags/[0-9]+\.[0-9]+\.[0-9]+$" | \
  sed 's|.*refs/tags/||' | \
  sort -V)

if ! echo "$AVAILABLE_VERSIONS" | grep -q "^${OF_GIT_REF}$"; then
  echo -e "${RED}Error: Version '$OF_GIT_REF' not found in openFrameworks repository${NC}"
  echo -e "${BLUE}Available stable versions:${NC}"
  echo "$AVAILABLE_VERSIONS" | tail -10 | sed 's/^/  - /'
  echo ""
  echo -e "${YELLOW}You can specify a different version with: export OF_GIT_REF=<version>${NC}"
  echo -e "${YELLOW}Or let the script auto-detect by removing the OF_GIT_REF environment variable${NC}"
  exit 1
fi

echo -e "${GREEN}Starting build process with openFrameworks $OF_GIT_REF...${NC}"

clone_of
download_of_libs_macos

echo -e "${GREEN}openFrameworks setup completed successfully!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "   1. Generate a new app: ./build_app.sh --app_name my_app"
echo "   2. Build your app: cd projects/my_app && ./build.sh"
echo "   3. Run your app: make RunRelease"
echo ""
echo -e "${BLUE}Note: openFrameworks is now ready. Use build_app.sh to create new projects.${NC}"
