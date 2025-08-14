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
