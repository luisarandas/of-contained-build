# Projects

This folder contains all your openFrameworks applications.

## Structure

Each app is a self-contained project with its own:
- `src/` - Source code files
- `Makefile` - Build configuration
- `config.make` - Project settings
- `addons.make` - openFrameworks addons
- `build.sh` - Individual build script
- `README.md` - App documentation

## Workflow

1. **Generate new app**: `../build_app.sh --app_name my_app`
2. **Work on app**: Edit files in `src/`
3. **Build app**: `./build.sh` or `make`
4. **Run app**: `make RunRelease`

## Notes

- Each app has its own `build.sh` for independent compilation
- openFrameworks is compiled once and shared across all apps
- Source files are tracked in git, build artifacts are ignored
- Use `../build_app.sh` to create new projects from the root directory
