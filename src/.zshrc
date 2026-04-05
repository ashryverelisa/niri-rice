source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# Fix Android Emulator on Wayland (emulator does not bundle the Wayland Qt plugin)
export QT_QPA_PLATFORM=xcb

# Android SDK
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
