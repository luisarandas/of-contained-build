#pragma once
#include "ofMain.h"
#include "ofxNetwork.h"
#include "ofxGui.h"

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
    // System scanning functions
    void scanSystemInfo();
    void scanAudioDevices();
    void scanGraphicsCards();
    void scanCPUInfo();
    void checkInternetConnection();
    
    // Display functions
    void drawModuleBox(int x, int y, int w, int h, const string& title, const vector<string>& info, bool isActive);
    void drawGrid();
    
    // System data
    vector<string> audioInfo;
    vector<string> graphicsInfo;
    vector<string> cpuInfo;
    vector<string> networkInfo;
    
    // Network testing
    ofxTCPClient tcpClient;
    bool internetConnected;
    float networkCheckTimer;
    
    // GUI controls
    ofxPanel gui;
    ofxButton refreshButton;
    ofxToggle autoRefresh;
    
    // Grid layout (12 boxes: 3 rows x 4 columns)
    int gridCols;
    int gridRows;
    int boxWidth;
    int boxHeight;
    int margin;
    
    // Timing
    float lastScanTime;
    float scanInterval;
};
