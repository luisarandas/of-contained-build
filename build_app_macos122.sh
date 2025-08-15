#!/usr/bin/env bash
set -euo pipefail

# Color codes for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo -e "${BLUE}Usage: $0 --app_name APP_NAME [OPTIONS]${NC}"
    echo ""
    echo "Options:"
    echo "  --app_name NAME    Name of the app to create (required)"
    echo "  --of_libs LIBS     Comma-separated list of openFrameworks addons (optional)"
    echo "  --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --app_name my_sketch"
    echo "  $0 --app_name my_sketch --of_libs ofxGui,ofxOsc"
    echo ""
    echo "Common addons:"
    echo "  ofxGui, ofxOsc, ofxAudio, ofxVideo, ofxKinect, ofxOpenCV, ofxParticles"
    echo ""
    echo "Note: This script generates a new openFrameworks app with full event handling. Use the app's own build.sh to compile."
}

# Function to validate addons
validate_addons() {
    local addons="$1"
    local valid_addons=""
    
    # Split comma-separated addons
    IFS=',' read -ra ADDON_ARRAY <<< "$addons"
    
    for addon in "${ADDON_ARRAY[@]}"; do
        addon=$(echo "$addon" | xargs) # trim whitespace
        if [ -n "$addon" ]; then
            # Check if addon exists in openFrameworks
            if [ -d "${OF_DIR}/addons/${addon}" ]; then
                valid_addons="${valid_addons}${addon}\n"
                echo -e "${GREEN}✓ Addon '${addon}' found${NC}" >&2
            else
                echo -e "${YELLOW}⚠ Addon '${addon}' not found in openFrameworks${NC}" >&2
                echo -e "${BLUE}Available addons:${NC}" >&2
                ls -1 "${OF_DIR}/addons/" 2>/dev/null | head -10 | sed 's/^/  - /' >&2
                echo -e "${YELLOW}Continuing without '${addon}'...${NC}" >&2
            fi
        fi
    done
    
    # Return valid addons (without trailing newline)
    echo -e "$valid_addons" | tr '\n' ',' | sed 's/,$//'
}

# Parse command line arguments
APP_NAME=""
OF_LIBS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --app_name)
            APP_NAME="$2"
            shift 2
            ;;
        --of_libs)
            OF_LIBS="$2"
            shift 2
            ;;

        --help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Check if app_name is provided
if [ -z "$APP_NAME" ]; then
    echo -e "${RED}Error: --app_name is required${NC}"
    show_usage
    exit 1
fi



# Get script directory and set paths
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${HERE}"
LIBS_DIR="${ROOT_DIR}/libs"
OF_DIR="${LIBS_DIR}/openFrameworks"
APP_DIR="${ROOT_DIR}/projects/${APP_NAME}"

# Check if openFrameworks is available
if [ ! -d "${OF_DIR}" ]; then
    echo -e "${RED}Error: openFrameworks not found at ${OF_DIR}${NC}"
    echo -e "${YELLOW}Please run ./build_project_macos122.sh first to set up openFrameworks${NC}"
    exit 1
fi

# Check if app already exists
if [ -d "${APP_DIR}" ]; then
    echo -e "${RED}Error: App directory already exists: ${APP_DIR}${NC}"
    echo -e "${YELLOW}Please choose a different name or remove the existing directory${NC}"
    exit 1
fi

echo -e "${GREEN}Generating new openFrameworks app: ${APP_NAME}${NC}"
echo -e "${BLUE}Template: Advanced (full event handling)${NC}"

# Validate and process addons
if [ -n "$OF_LIBS" ]; then
    echo -e "${BLUE}Processing addons: ${OF_LIBS}${NC}"
    VALID_ADDONS=$(validate_addons "$OF_LIBS")
    if [ -n "$VALID_ADDONS" ]; then
        OF_LIBS="$VALID_ADDONS"
        echo -e "${GREEN}Valid addons: ${OF_LIBS}${NC}"
    else
        echo -e "${YELLOW}No valid addons found, continuing without addons${NC}"
        OF_LIBS=""
    fi
fi

# Create app directory structure
echo -e "${BLUE}Creating app directory structure...${NC}"
mkdir -p "${APP_DIR}/src"

# Create Makefile
echo -e "${BLUE}Creating Makefile...${NC}"
cat > "${APP_DIR}/Makefile" << 'EOF'
# Makefile for $(APP_NAME) (no IDE). Uses openFrameworks' make system.
# You can override OF_ROOT from environment; default points to ../../libs/openFrameworks
OF_ROOT ?= $(abspath $(CURDIR)/../../libs/openFrameworks)

PROJECT_NAME = $(APP_NAME)
PROJECT_ROOT = .

include $(OF_ROOT)/libs/openFrameworksCompiled/project/makefileCommon/compile.project.mk
EOF

# Create config.make
echo -e "${BLUE}Creating config.make...${NC}"
cat > "${APP_DIR}/config.make" << 'EOF'
################################################################################
# Project-specific config
################################################################################

# Hard-pin OF_ROOT relative to this project (can be overridden by env var)
OF_ROOT = ../../libs/openFrameworks

# Suppress TARGET_OS_VISION warning (harmless openFrameworks warning)
PROJECT_CFLAGS += -Wno-undef-prefix

# Example: Uncomment to add extra compiler flags
# PROJECT_CFLAGS += -Wall

# Example: Target release as default
# PROJECT_OPTIMIZATION = -O3
EOF

# Create addons.make
echo -e "${BLUE}Creating addons.make...${NC}"
if [ -n "$OF_LIBS" ]; then
    echo "$OF_LIBS" | tr ',' '\n' > "${APP_DIR}/addons.make"
else
    touch "${APP_DIR}/addons.make"
fi

# Create main.cpp
echo -e "${BLUE}Creating main.cpp...${NC}"
cat > "${APP_DIR}/src/main.cpp" << 'EOF'
#include "ofMain.h"
#include "ofApp.h"

int main(){
    ofSetupOpenGL(1024, 768, OF_WINDOW);
    ofRunApp(std::make_shared<ofApp>());
    return 0;
}
EOF

# Create ofApp.h
echo -e "${BLUE}Creating ofApp.h...${NC}"
cat > "${APP_DIR}/src/ofApp.h" << 'EOF'
#pragma once
#include "ofMain.h"

class ofApp : public ofBaseApp {
public:
    void setup() override;
    void update() override;
    void draw() override;
    
    void keyPressed(int key) override;
    void keyReleased(int key) override;
    void mouseMoved(int x, int y) override;
    void mouseDragged(int x, int y, int button) override;
    void mousePressed(int x, int y, int button) override;
    void mouseReleased(int x, int y, int button) override;
    void mouseEntered(int x, int y) override;
    void mouseExited(int x, int y) override;
    void windowResized(int w, int h) override;
    void dragEvent(ofDragInfo dragInfo) override;
    void gotMessage(ofMessage msg) override;

private:
    float time;
    ofVec2f mousePos;
    bool isMousePressed;
};
EOF

# Create ofApp.cpp
echo -e "${BLUE}Creating ofApp.cpp...${NC}"
cat > "${APP_DIR}/src/ofApp.cpp" << 'EOF'
#include "ofApp.h"

void ofApp::setup() {
    ofSetWindowTitle("$(APP_NAME)");
    ofBackground(10);
    time = 0;
    isMousePressed = false;
}

void ofApp::update() {
    time += 0.016f; // Assuming 60fps
}

void ofApp::draw() {
    ofSetColor(240);
    ofDrawBitmapString("Hello $(APP_NAME)!", 20, 30);
    ofDrawBitmapString("Time: " + ofToString(time, 2), 20, 50);
    ofDrawBitmapString("Mouse: " + ofToString(mousePos.x) + ", " + ofToString(mousePos.y), 20, 70);
    
    // Draw a moving circle
    float r = 100.0f + 50.0f * sinf(time * 2.0f);
    ofPushMatrix();
    ofTranslate(ofGetWidth()/2, ofGetHeight()/2);
    ofNoFill();
    ofSetCircleResolution(120);
    ofDrawCircle(0, 0, r);
    ofPopMatrix();
}

void ofApp::keyPressed(int key) {
    if (key == ' ') {
        ofBackground(ofRandom(255), ofRandom(255), ofRandom(255));
    }
}

void ofApp::keyReleased(int key) {}
void ofApp::mouseMoved(int x, int y) { mousePos.set(x, y); }
void ofApp::mouseDragged(int x, int y, int button) { mousePos.set(x, y); }
void ofApp::mousePressed(int x, int y, int button) { isMousePressed = true; }
void ofApp::mouseReleased(int x, int y, int button) { isMousePressed = false; }
void ofApp::mouseEntered(int x, int y) {}
void ofApp::mouseExited(int x, int y) {}
void ofApp::windowResized(int w, int h) {}
void ofApp::dragEvent(ofDragInfo dragInfo) {}
void ofApp::gotMessage(ofMessage msg) {}
EOF

# Create the app's own build script
echo -e "${BLUE}Creating app build script...${NC}"
cat > "${APP_DIR}/build.sh" << 'EOF'
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
EOF

# Make the build script executable
chmod +x "${APP_DIR}/build.sh"

# Create a README for the app
echo -e "${BLUE}Creating app README...${NC}"
cat > "${APP_DIR}/README.md" << EOF
# ${APP_NAME}

Generated openFrameworks application.

## Building

\`\`\`bash
./build.sh
\`\`\`

## Running

\`\`\`bash
make RunRelease
# or
make RunDebug
\`\`\`

## Addons

$(if [ -n "$OF_LIBS" ]; then echo "$OF_LIBS" | tr ',' '\n' | sed 's/^/- /'; else echo "- None specified"; fi)

## Project Structure

- \`src/\` - Source code
- \`Makefile\` - Build configuration
- \`config.make\` - Project-specific settings
- \`addons.make\` - openFrameworks addons
- \`build.sh\` - App-specific build script
EOF

echo -e "${GREEN}App '${APP_NAME}' generated successfully!${NC}"
echo -e "${BLUE}Location: ${APP_DIR}${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. cd projects/${APP_NAME}"
echo "  2. ./build.sh"
echo "  3. make RunRelease"
echo ""
echo -e "${BLUE}Note: Each app has its own build.sh script for independent compilation${NC}"
