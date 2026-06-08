export interface Env {
  GITHUB_PAT: string;
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
    if (env.GITHUB_PAT) {
      headers.set("Authorization", `Bearer ${env.GITHUB_PAT}`);
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
