export interface Env {
  GITHUB_PATS: string;
}

export default {
  async fetch(
    request: Request,
    env: Env,
    ctx: ExecutionContext
  ): Promise<Response> {
    const url = new URL(request.url);
    const targetUrl = `https://api.github.com${url.pathname}${url.search}`;

    // CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, HEAD, POST, OPTIONS",
          "Access-Control-Allow-Headers": "*",
        },
      });
    }

    const headers = new Headers(request.headers);
    headers.set("User-Agent", "Flowscout-Proxy/1.0");

    // Add authentication if token is available
    if (env.GITHUB_PATS) {
      const tokens = env.GITHUB_PATS.split(',').map(t => t.trim()).filter(t => t.length > 0);
      if (tokens.length > 0) {
        const randomToken = tokens[Math.floor(Math.random() * tokens.length)];
        headers.set("Authorization", `Bearer ${randomToken}`);
      }
    }

    // Forward the request to GitHub, do not follow redirects
    const modifiedRequest = new Request(targetUrl, {
      method: request.method,
      headers: headers,
      body: request.body,
      redirect: "manual",
    });

    const response = await fetch(modifiedRequest);

    // Create a new response with CORS headers
    const newResponse = new Response(response.body, response);
    newResponse.headers.set("Access-Control-Allow-Origin", "*");
    
    return newResponse;
  },
};
