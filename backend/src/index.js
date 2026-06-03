export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // 1. OAuthログイン開始エンドポイント
    if (url.pathname === '/login') {
      const redirectUri = `https://flowscout-oauth.tadanobutubutu.workers.dev/callback`;
      const githubAuthUrl = `https://github.com/login/oauth/authorize?client_id=${env.GITHUB_CLIENT_ID}&scope=repo,read:org&redirect_uri=${encodeURIComponent(redirectUri)}`;
      return Response.redirect(githubAuthUrl, 302);
    }

    // 2. OAuthコールバック（スマート・ルーティング搭載）
    if (url.pathname === '/callback') {
      const code = url.searchParams.get('code');
      if (!code) {
        return new Response('Missing code parameter', { status: 400 });
      }

      try {
        // 認可コードをアクセストークンと交換
        const tokenResponse = await fetch('https://github.com/login/oauth/access_token', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: JSON.stringify({
            client_id: env.GITHUB_CLIENT_ID,
            client_secret: env.GITHUB_CLIENT_SECRET,
            code: code,
          }),
        });

        const tokenData = await tokenResponse.json();
        const accessToken = tokenData.access_token;

        if (!accessToken) {
          return new Response('Failed to retrieve access token from GitHub', { status: 400 });
        }

        // 【スマート・ルーティング】
        // ユーザーがすでにGitHub Appをインストールしているかをチェック
        const installationsResponse = await fetch('https://api.github.com/user/installations', {
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'User-Agent': 'Flowscout-OAuth-仲介API',
            'Accept': 'application/vnd.github.v3+json',
          },
        });

        const installationsData = await installationsResponse.json();
        const installations = installationsData.installations || [];

        // Appのインストール情報があるか確認
        const hasInstallation = installations.some(
          inst => inst.app_slug === env.GITHUB_APP_NAME || inst.app_id.toString() === env.GITHUB_APP_ID
        );

        if (hasInstallation) {
          // すでにインストール済みの場合は、そのままアプリにディープリンクで復帰
          const appRedirectUrl = `flowscout://oauth-callback?token=${accessToken}`;
          return Response.redirect(appRedirectUrl, 302);
        } else {
          // 未インストールの場合は、GitHub AppインストールURLにスマートリダイレクト！
          // インストール後にアプリにディープリンクさせるため、state等を使って遷移させることができます
          const installUrl = `https://github.com/apps/${env.GITHUB_APP_NAME}/installations/new`;
          return Response.redirect(installUrl, 302);
        }
      } catch (error) {
        return new Response(`OAuth Error: ${error.message}`, { status: 500 });
      }
    }

    // 3. GitHub App Manifest作成成功時のリダイレクト先
    if (url.pathname === '/setup-success') {
      const code = url.searchParams.get('code');
      const installationId = url.searchParams.get('installation_id');

      if (!code) {
        if (installationId) {
          // GitHub Appのインストール完了後のリダイレクトの場合、アプリに戻す
          return Response.redirect(`flowscout://setup-success?installation_id=${installationId}`, 302);
        }
        return new Response('Setup code missing', { status: 400 });
      }

      // マニフェストコードをApp Credentialと交換
      const manifestResponse = await fetch(`https://api.github.com/app-manifests/${code}/conversions`, {
        method: 'POST',
        headers: {
          'User-Agent': 'Flowscout-Setup',
          'Accept': 'application/vnd.github.v3+json',
        },
      });

      const appCredentials = await manifestResponse.json();

      // 超簡単な美しいセットアップ成功画面を表示し、ユーザーにClient IDとSecretを表示
      const html = `
        <!DOCTYPE html>
        <html>
        <head>
          <title>Flowscout Setup Success</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #090d16; color: #f1f5f9; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; padding: 20px; }
            .card { background: #131b2e; border: 1px solid #1e293b; border-radius: 24px; padding: 32px; max-width: 500px; width: 100%; box-shadow: 0 10px 30px rgba(0,0,0,0.5); text-align: center; }
            h1 { background: linear-gradient(135deg, #6366F1, #0EA5E9); -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin-bottom: 8px; }
            p { color: #94a3b8; line-height: 1.6; }
            .secret-box { background: #090d16; border: 1px solid #334155; border-radius: 12px; padding: 16px; text-align: left; font-family: monospace; margin: 20px 0; word-break: break-all; }
            .btn { background: #6366F1; color: white; border: none; padding: 12px 24px; border-radius: 12px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-block; transition: background 0.2s; }
            .btn:hover { background: #4f46e5; }
          </style>
        </head>
        <body>
          <div class="card">
            <h1>Flowscout App 作成完了！</h1>
            <p>GitHub Appが自動生成されました。以下の情報をCloudflare Workersのwrangler.json（または環境変数）に設定してください。</p>
            <div class="secret-box">
              <strong>App ID:</strong> ${appCredentials.id}<br><br>
              <strong>Client ID:</strong> ${appCredentials.client_id}<br><br>
              <strong>Client Secret:</strong> ${appCredentials.client_secret}
            </div>
            <p>設定が完了したら、スマートな連携機能がフルパワーで動き出します！</p>
            <a href="https://tadanobutubutu.github.io/flowscout/" class="btn">ホームページへ戻る</a>
          </div>
        </body>
        </html>
      `;

      return new Response(html, {
        headers: { 'Content-Type': 'text/html; charset=utf-8' },
      });
    }

    return new Response('Flowscout OAuth API is running.', { status: 200 });
  }
}
