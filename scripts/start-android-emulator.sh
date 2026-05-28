#!/bin/bash

# start-android-emulator.sh
# Android SDK CLIを使用して、エミュレータ（AVD）を検出・自動作成・起動する。

AVD_NAME="Flowscout_Pixel_6"
SYSTEM_IMAGE="system-images;android-33;google_apis;x86_64"

echo "🤖 Android AVD Manager Initializing..."

# 1. SDKのパス設定 (Mac用デフォルト)
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"

# 2. エミュレータコマンドの存在確認
if ! command -v emulator &> /dev/null; then
  echo "❌ Error: 'emulator' CLI command not found. Please ensure Android SDK is installed."
  exit 1
fi

# 3. 既存のAVD一覧のチェック
echo "Checking existing AVDs..."
EXISTING_AVDS=$(emulator -list-avds)

if echo "$EXISTING_AVDS" | grep -q "$AVD_NAME"; then
  echo "✅ Found existing AVD: $AVD_NAME"
else
  echo "🌀 AVD not found. Creating a new lightweight AVD: $AVD_NAME..."
  
  # AVDの自動ダウンロードおよび作成
  sdkmanager --install "$SYSTEM_IMAGE"
  echo "no" | avdmanager create avd -n "$AVD_NAME" -k "$SYSTEM_IMAGE" --force
  
  if [ $? -eq 0 ]; then
    echo "✨ AVD $AVD_NAME successfully created!"
  else
    echo "❌ Failed to create AVD. AVD Manager requires manual configuration."
    exit 1
  fi
fi

# 4. エミュレータの起動 (ヘッドレスモードか通常GUIモードかを選択)
# エージェントが裏で自動操作する場合は、-no-window (GUIなし) で起動すると軽量で高速です。
echo "Starting Emulator $AVD_NAME..."
if [ "$1" == "--headless" ]; then
  echo "▶️ Launching in Headless Mode (no GUI)..."
  emulator -avd "$AVD_NAME" -no-window -no-audio -no-snapshot -gpu off &
else
  echo "▶️ Launching in Standard GUI Mode..."
  emulator -avd "$AVD_NAME" &
fi

echo "🕒 Waiting for device to boot..."
adb wait-for-device
echo "🎉 Android Emulator is ONLINE and ready for debug/deploy!"
