# of-contained-build

Self-contained [openFrameworks](https://openframeworks.cc/) setup for VSCode/Cursor with CMake divided in **three scripts**: 1) Setup once at the dev, 2) generate apps with specific addons, 3) build independently. These should be developed in one shot, and 1st script named according to OS.

### Tests for Development

`./build_project_macos122.sh`  
MacOS Monterey 12.2  

### Quick Start (Dev: MacOS 12.2)
```bash
# Setup OpenFrameworks
./build_project_macos122.sh
./build_app.sh --app_name app_test_1 --of_libs ofxGui,ofxOsc
./build_app.sh --app_name app_test_2 --of_libs ofxNetwork,ofxGui
# Change code in the app, build it:
cd projects/app_test_1
./build.sh
# make RunRelease
```

- No IDE required. Uses openFrameworks Makefile toolchain on VSCode/Cursor.
- openFrameworks compiled once, shared across all apps.

Roadmap todo
