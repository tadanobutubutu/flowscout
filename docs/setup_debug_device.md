# 📱 Flowscout 実機デバッグ & インストール手順書

ユーザー様がお持ちの **iOS端末** および **Android端末** の実機に Flowscout をインストールし、動作テスト（デバッグ）を行うための完全手順書です。

---

## 🤖 1. Android 実機へのデプロイ & テスト

Androidは開発者モードを有効にすることで、PCからUSB経由で直接アプリを転送してデバッグできます。

### 🔌 A. USBデバッグによる直接転送 (開発用)
1.  **端末の開発者オプションを有効にする:**
    *   端末の「設定」➔「デバイス情報」➔「ビルド番号」を **7回連続タップ** します。
    *   「これで開発者になりました」と表示されます。
2.  **USBデバッグをオンにする:**
    *   「設定」➔「システム」➔「開発者向けオプション」を開き、**「USBデバッグ」** をオンにします。
3.  **PCと接続して実行:**
    *   USBケーブルでPCに接続します（接続時に端末画面で「USBデバッグを許可しますか？」と出たら「許可」を選択）。
    *   PCのターミナルで以下を実行し、端末が認識されているか確認します。
        ```bash
        adb devices
        ```
    *   認識されていたら、プロジェクトルートで以下を実行し、実機でデバッグ起動します。
        ```bash
        flutter run -d <あなたのデバイスID>
        ```

### 📦 B. GitHub Releases (APK直接インストール)
1.  ビルド完了後、リポジトリの [Releases](https://github.com/tadanobutubutu/flowscout/releases) ページへスマホのブラウザからアクセスします。
2.  `app-release.apk` をダウンロードします。
3.  タップしてインストールします（「不明なアプリのインストール」の許可を求められた場合は、ブラウザからのインストールを許可してください）。

---

## 🍏 2. iOS 実機へのデプロイ & サイドロード (AltStore)

iOSはAppleのセキュリティ制限が厳しいため、有料デベロッパーアカウント（年99ドル）を使わずに「完全0円」でインストールするには **AltStore** を使用したサイドロードが最強のアプローチになります。

### 🚀 AltStore を用いたサイドロード手順 (完全0円)
1.  **PCに AltServer をインストール:**
    *   [AltStore公式サイト](https://altstore.io/) から、お使いのPC（macOS）用 `AltServer` をダウンロードして起動します。
2.  **iPhoneをMacに接続:**
    *   USBケーブルで接続し、Finderで「Wi-Fi経由でこのiPhoneを表示」をオンにします。
3.  **AltStoreをiPhoneにインストール:**
    *   Macのメニューバーから AltServer アイコンをクリック ➔ **「Install AltStore」** ➔ あなたのiPhoneを選択。
    *   ご自身のApple IDとパスワードを入力します（Appleの公式サーバーにのみ安全に送信されます）。
4.  **iPhone側でプロファイルを信頼する:**
    *   iPhoneの「設定」➔「一般」➔「VPNとデバイス管理」を開き、ご自身のApple IDのデベロッパーアプリを **「信頼」** にします。
5.  **Flowscout IPAファイルのインポート:**
    *   GitHub Releases等からビルド済みの `Runner.ipa`（または `flowscout.ipa`）をiPhone上にダウンロードします。
    *   AltStoreアプリを開き、「My Apps」タブの左上の「＋」ボタンを押し、ダウンロードしたIPAファイルを選択します。
    *   自動で個人署名が行われ、ホーム画面にFlowscoutがインストールされます！

### 🔌 C. Xcodeを用いた無料の個人アカウントによる直接有線デプロイ (最も一般的)
1.  **iPhoneをMacに有線接続し「信頼」する:**
    *   USB/Lightning/USB-C ケーブルでiPhoneをMacに繋ぎ、iPhone画面上で「このコンピュータを信頼しますか？」と出たら「信頼」をタップしてパスコードを入力します。
2.  **iOSの「デベロッパモード」を有効にする (iOS 16以降):**
    *   iPhoneの「設定」➔「プライバシーとセキュリティ」➔ 最下部にある「デベロッパモード」をオンにして再起動します。
    *   再起動後、画面に確認ダイアログが出るので「オンにする」をタップしてパスコードを入力します。
3.  **Xcodeでプロジェクトを開き、アカウントを登録する:**
    *   Macで Xcode を開き、`ios/Runner.xcworkspace` を開きます。
    *   Xcodeの「Settings...」➔「Accounts」タブを開き、左下の「＋」ボタンでご自身のApple IDを追加します。
4.  **プロビジョニング設定 (Signing & Capabilities):**
    *   Xcodeの左側ツリー最上部にある「Runner」ターゲットを選択します。
    *   「Signing & Capabilities」タブを選択し、「Automatically manage signing」にチェックを入れます。
    *   「Team」ドロップダウンから、先ほど登録したご自身のApple ID（Personal Team）を選択します。
    *   「Bundle Identifier」が重複エラーになる場合、末尾に適当な文字列を追加（例: `com.tadanobutubutu.flowscout.dev`）して一意にします。
5.  **実機を指定してビルド・インストール:**
    *   Xcodeの画面上部、またはターミナルから接続中のiPhoneをデプロイ先デバイスとして選択します。
    *   ターミナルからは以下を実行します。
        ```bash
        flutter run -d <あなたのiPhoneの名前またはUUID>
        ```
    *   ※初回実行時に「信頼されていないデベロッパ」とエラーが出た場合は、「設定」➔「一般」➔「VPNとデバイス管理」からご自身のApple IDを「信頼」してください。

---

## 🤖 3. エミュレータ / シミュレータの操作と自動化 (macOS / Xcode 環境)

macOSの開発環境を活かし、iOSシミュレータおよびAndroidエミュレータをコマンドラインやスクリプトから自動起動・制御できます。

### 🍏 iOS シミュレータの起動・操作 (Xcode Simctl)
Mac上でiOSシミュレータを起動してテストを実行するために必要なステップです。

1.  **利用可能なiOSデバイス（シミュレータ）の確認:**
    ```bash
    xcrun simctl list devices
    ```
2.  **特定のシミュレータを起動 (例: iPhone 15 Pro):**
    *   エージェントが提供する自動スクリプトを実行：
        ```bash
        ./scripts/start-ios-simulator.sh
        ```
    *   または手動で直接起動：
        ```bash
        open -a Simulator
        # 特定のUUIDの端末をブート
        xcrun simctl boot <DEVICE_UUID>
        ```
3.  **シミュレータへアプリをインストールして起動:**
    ```bash
    flutter run -d iphonesimulator
    ```

### 🤖 Android エミュレータ (AVD) の起動・操作
Android SDKおよび `adb` (Android Debug Bridge) がセットアップされているため、バックグラウンドでのヘッドレス起動やテストが可能です。

1.  **エミュレータのバックグラウンド（ヘッドレス）起動:**
    ```bash
    ./scripts/start-android-emulator.sh --headless
    ```
2.  **ADBを通じたエミュレータ操作 (タップ・入力・キャプチャ):**
    *   **スクリーンショット取得:**
        ```bash
        adb shell screencap -p /sdcard/screen.png
        adb pull /sdcard/screen.png ./scratch/
        ```
    *   **キーイベント送信 (Homeボタンなど):**
        ```bash
        adb shell input keyevent 3
        ```
    *   **タップ操作:**
        ```bash
        adb shell input tap 500 1000
        ```

