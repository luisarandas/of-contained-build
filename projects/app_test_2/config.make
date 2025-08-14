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
