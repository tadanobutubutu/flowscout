#!/bin/bash

# start-ios-simulator.sh
# macOSの xcrun simctl を使用して、iOSシミュレータを自動検出・作成・起動する。

DEVICE_NAME="Flowscout_iPhone_15"
DEVICE_TYPE="com.apple.CoreSimulator.SimDeviceType.iPhone-15"
RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-17-0" # バージョンは環境に合わせてフォールバックします

echo "🍏 iOS Simulator Manager Initializing..."

# 1. Xcodeコマンドラインツールのチェック
if ! command -v xcrun &> /dev/null; then
  echo "❌ Error: 'xcrun' command not found. Xcode is required for iOS simulation."
  exit 1
fi

# 2. 利用可能な最新のiOSランタイムの自動検出
echo "Detecting available iOS runtimes..."
AVAILABLE_RUNTIMES=$(xcrun simctl list runtimes)
LATEST_RUNTIME=$(echo "$AVAILABLE_RUNTIMES" | grep -E "iOS [0-9]+" | sort -V | tail -n 1 | awk -F' - ' '{print $1}' | sed 's/iOS /com.apple.CoreSimulator.SimRuntime.iOS-/g' | sed 's/\./-/g')

if [ -n "$LATEST_RUNTIME" ]; then
  RUNTIME="$LATEST_RUNTIME"
  echo "✅ Detected latest iOS runtime: $RUNTIME"
else
  echo "⚠️ Could not auto-detect runtime. Using default: $RUNTIME"
fi

# 3. 既存のシミュレータのチェック
echo "Checking existing iOS simulator devices..."
EXISTING_DEVICES=$(xcrun simctl list devices)

if echo "$EXISTING_DEVICES" | grep -q "$DEVICE_NAME"; then
  echo "✅ Found existing iOS simulator device: $DEVICE_NAME"
  DEVICE_UDID=$(echo "$EXISTING_DEVICES" | grep "$DEVICE_NAME" | head -n 1 | grep -oE "[-A-Z0-9]{36}")
else
  echo "🌀 Simulator not found. Creating a new simulator: $DEVICE_NAME..."
  
  # シミュレータの作成
  DEVICE_UDID=$(xcrun simctl create "$DEVICE_NAME" "$DEVICE_TYPE" "$RUNTIME")
  
  if [ -n "$DEVICE_UDID" ]; then
    echo "✨ iOS Simulator $DEVICE_NAME successfully created with UDID: $DEVICE_UDID"
  else
    echo "❌ Failed to create simulator. iOS Simulator requires manual configuration."
    exit 1
  fi
fi

# 4. シミュレータ（Simulator.app）の起動と起動確認
echo "Booting iOS Simulator (UDID: $DEVICE_UDID)..."
open -a Simulator --args -CurrentDeviceUDID "$DEVICE_UDID"

# 起動完了の待機
echo "🕒 Waiting for iOS Simulator to finish booting..."
xcrun simctl bootstatus "$DEVICE_UDID"

echo "🎉 iOS Simulator is ONLINE and ready for debug/deploy!"
