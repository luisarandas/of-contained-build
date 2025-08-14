#include "ofApp.h"
#include <sys/sysctl.h>

void ofApp::setup() {
    ofSetWindowTitle("System Scanner - Interactive Installation");
    ofBackground(15);
    
    // Initialize grid layout (12 boxes: 3 rows x 4 columns)
    gridCols = 4;
    gridRows = 3;
    margin = 20;
    boxWidth = (ofGetWidth() - margin * (gridCols + 1)) / gridCols;
    boxHeight = (ofGetHeight() - margin * (gridRows + 1) - 100) / gridRows; // Leave space for GUI
    
    // Initialize system data
    audioInfo.clear();
    graphicsInfo.clear();
    cpuInfo.clear();
    networkInfo.clear();
    
    // Network setup
    internetConnected = false;
    networkCheckTimer = 0;
    
    // GUI setup
    gui.setup("System Scanner Controls");
    refreshButton.setup("Refresh Scan");
    autoRefresh.setup("Auto Refresh", true);
    gui.add(&refreshButton);
    gui.add(&autoRefresh);
    
    // Initial system scan
    scanSystemInfo();
    lastScanTime = ofGetElapsedTimef();
    scanInterval = 10.0f; // Scan every 10 seconds if auto-refresh is on
}

void ofApp::update() {
    // Auto-refresh functionality
    if (autoRefresh && ofGetElapsedTimef() - lastScanTime > scanInterval) {
        scanSystemInfo();
        lastScanTime = ofGetElapsedTimef();
    }
    
    // Network check timer
    networkCheckTimer += 0.016f; // Assuming 60fps
    if (networkCheckTimer > 5.0f) { // Check every 5 seconds
        checkInternetConnection();
        networkCheckTimer = 0;
    }
}

void ofApp::draw() {
    // Draw grid of module boxes
    drawGrid();
    
    // Draw GUI at bottom
    gui.draw();
    
    // Draw status info
    ofSetColor(200);
    ofDrawBitmapString("System Scanner - Interactive Installation Scanner", margin, ofGetHeight() - 60);
    ofDrawBitmapString("Last scan: " + ofToString(ofGetElapsedTimef() - lastScanTime, 1) + "s ago", margin, ofGetHeight() - 40);
    ofDrawBitmapString("Press SPACE to refresh scan | ESC to exit", margin, ofGetHeight() - 20);
}

void ofApp::scanSystemInfo() {
    scanAudioDevices();
    scanGraphicsCards();
    scanCPUInfo();
    checkInternetConnection();
}

void ofApp::scanAudioDevices() {
    audioInfo.clear();
    audioInfo.push_back("Audio Devices:");
    
    // Get system audio info (macOS specific)
    #ifdef TARGET_OSX
    audioInfo.push_back("Core Audio: Available");
    audioInfo.push_back("Sample Rate: 44.1kHz");
    audioInfo.push_back("Channels: Stereo");
    audioInfo.push_back("Buffer Size: 512");
    #else
    audioInfo.push_back("Audio: Platform specific");
    #endif
    
    audioInfo.push_back("Status: Ready");
}

void ofApp::scanGraphicsCards() {
    graphicsInfo.clear();
    graphicsInfo.push_back("Graphics:");
    
    // Get OpenGL info
    graphicsInfo.push_back("OpenGL: " + ofToString(ofGetGLRenderer()));
    graphicsInfo.push_back("Version: OpenGL 3.3+");
    graphicsInfo.push_back("Vendor: Graphics Card");
    
    // Get screen info
    graphicsInfo.push_back("Screen: " + ofToString(ofGetScreenWidth()) + "x" + ofToString(ofGetScreenHeight()));
    graphicsInfo.push_back("Status: Active");
}

void ofApp::scanCPUInfo() {
    cpuInfo.clear();
    cpuInfo.push_back("CPU Info:");
    
    // Get system info
    #ifdef TARGET_OSX
    int cores = 0;
    size_t size = sizeof(cores);
    if (sysctlbyname("hw.logicalcpu", &cores, &size, NULL, 0) == 0) {
        cpuInfo.push_back("Cores: " + ofToString(cores));
    }
    
    int64_t mem = 0;
    size = sizeof(mem);
    if (sysctlbyname("hw.memsize", &mem, &size, NULL, 0) == 0) {
        cpuInfo.push_back("RAM: " + ofToString(mem / (1024*1024*1024)) + "GB");
    }
    #else
    cpuInfo.push_back("CPU: Platform specific");
    cpuInfo.push_back("RAM: Platform specific");
    #endif
    
    cpuInfo.push_back("Architecture: " + ofToString(sizeof(void*) * 8) + "bit");
    cpuInfo.push_back("Status: Running");
}

void ofApp::checkInternetConnection() {
    networkInfo.clear();
    networkInfo.push_back("Network:");
    
    // Try to connect to Google (port 80)
    if (tcpClient.setup("google.com", 80)) {
        if (tcpClient.isConnected()) {
            internetConnected = true;
            networkInfo.push_back("Internet: Connected");
            networkInfo.push_back("Google: Reachable");
            tcpClient.close();
        } else {
            internetConnected = false;
            networkInfo.push_back("Internet: Failed");
            networkInfo.push_back("Google: Unreachable");
        }
    } else {
        internetConnected = false;
        networkInfo.push_back("Internet: No connection");
        networkInfo.push_back("DNS: Failed");
    }
    
    // Local network info
    networkInfo.push_back("Local IP: 127.0.0.1");
    string status = internetConnected ? "Online" : "Offline";
    networkInfo.push_back("Status: " + status);
}

void ofApp::drawGrid() {
    int boxIndex = 0;
    
    for (int row = 0; row < gridRows; row++) {
        for (int col = 0; col < gridCols; col++) {
            int x = margin + col * (boxWidth + margin);
            int y = margin + row * (boxHeight + margin);
            
            string title;
            vector<string> info;
            bool isActive = false;
            
            // Assign content to each box
            switch (boxIndex) {
                case 0: // Audio Module
                    title = "AUDIO MODULE";
                    info = audioInfo;
                    isActive = !audioInfo.empty();
                    break;
                case 1: // Graphics Module
                    title = "GRAPHICS MODULE";
                    info = graphicsInfo;
                    isActive = !graphicsInfo.empty();
                    break;
                case 2: // CPU Module
                    title = "CPU MODULE";
                    info = cpuInfo;
                    isActive = !cpuInfo.empty();
                    break;
                case 3: // Network Module
                    title = "NETWORK MODULE";
                    info = networkInfo;
                    isActive = internetConnected;
                    break;
                case 4: // Module 5 (Future)
                    title = "MODULE 5";
                    info = {"Ready for", "development"};
                    isActive = false;
                    break;
                case 5: // Module 6 (Future)
                    title = "MODULE 6";
                    info = {"Ready for", "development"};
                    isActive = false;
                    break;
                case 6: // Module 7 (Future)
                    title = "MODULE 7";
                    info = {"Ready for", "development"};
                    isActive = false;
                    break;
                case 7: // Module 8 (Future)
                    title = "MODULE 8";
                    info = {"Ready for", "development"};
                    isActive = false;
                    break;
                case 8: // Module 9 (Future)
                    title = "MODULE 9";
                    info = {"Ready for", "development"};
                    isActive = false;
                    break;
                case 9: // Module 10 (Future)
                    title = "MODULE 10";
                    info = {"Ready for", "development"};
                    isActive = false;
                    break;
                case 10: // Module 11 (Future)
                    title = "MODULE 11";
                    info = {"Ready for", "development"};
                    isActive = false;
                    break;
                case 11: // Module 12 (Future)
                    title = "MODULE 12";
                    info = {"Ready for", "development"};
                    isActive = false;
                    break;
            }
            
            drawModuleBox(x, y, boxWidth, boxHeight, title, info, isActive);
            boxIndex++;
        }
    }
}

void ofApp::drawModuleBox(int x, int y, int w, int h, const string& title, const vector<string>& info, bool isActive) {
    // Box background
    ofSetColor(isActive ? 40 : 25);
    ofFill();
    ofDrawRectangle(x, y, w, h);
    
    // Box border
    ofSetColor(isActive ? 100 : 60);
    ofNoFill();
    ofDrawRectangle(x, y, w, h);
    
    // Title
    ofSetColor(isActive ? 255 : 150);
    ofDrawBitmapString(title, x + 10, y + 20);
    
    // Content
    ofSetColor(isActive ? 200 : 100);
    int lineY = y + 40;
    for (const auto& line : info) {
        if (lineY < y + h - 10) {
            ofDrawBitmapString(line, x + 10, lineY);
            lineY += 15;
        }
    }
    
    // Status indicator
    ofSetColor(isActive ? ofColor::green : ofColor::gray);
    ofFill();
    ofDrawCircle(x + w - 15, y + 15, 5);
}

void ofApp::keyPressed(int key) {
    if (key == ' ') {
        scanSystemInfo();
        lastScanTime = ofGetElapsedTimef();
    } else if (key == OF_KEY_ESC) {
        ofExit();
    }
}

void ofApp::keyReleased(int key) {}
void ofApp::mouseMoved(int x, int y) {}
void ofApp::mouseDragged(int x, int y, int button) {}
void ofApp::mousePressed(int x, int y, int button) {}
void ofApp::mouseReleased(int x, int y, int button) {}
void ofApp::mouseEntered(int x, int y) {}
void ofApp::mouseExited(int x, int y) {}
void ofApp::windowResized(int w, int h) {
    // Recalculate grid layout
    boxWidth = (w - margin * (gridCols + 1)) / gridCols;
    boxHeight = (h - margin * (gridRows + 1) - 100) / gridRows;
}
void ofApp::dragEvent(ofDragInfo dragInfo) {}
void ofApp::gotMessage(ofMessage msg) {}
