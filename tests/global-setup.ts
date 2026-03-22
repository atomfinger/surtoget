import { request } from "@playwright/test";

async function globalSetup() {
  const baseURL = process.env.BASE_URL ?? "http://localhost:8000";
  const ctx = await request.newContext();

  for (let i = 0; i < 60; i++) {
    try {
      const response = await ctx.get(`${baseURL}/health`);
      if (response.ok()) {
        await ctx.dispose();
        return;
      }
    } catch {
      // not ready yet
    }
    await new Promise((r) => setTimeout(r, 1000));
  }

  await ctx.dispose();
  throw new Error("App did not become healthy within 60 seconds");
}

export default globalSetup;
