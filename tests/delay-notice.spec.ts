import { test, expect, Page } from "@playwright/test";
import { stabilizeStoriesSection, stabilizeNewsImages } from "./helpers";

const DELAY_NOTICE_HTML = `
<div class="my-10 p-4 bg-yellow-100 rounded-lg shadow-md" data-testid="delay-notice">
  <p class="text-lg font-semibold text-yellow-800 flex items-center">
    <span class="relative flex h-3 w-3 mr-3">
      <span class="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
    </span>
    Akkurat nå: Sørlandsbanen er forsinket... Igjen 🙄
  </p>
</div>
`;

async function ensureDelayNoticePresent(page: Page) {
  const exists = await page.locator(".bg-yellow-100").count();
  if (exists === 0) {
    await page.evaluate((html: string) => {
      const main = document.querySelector("main");
      if (!main) return;
      const blurb = main.children[0];
      if (!blurb) return;
      const wrapper = document.createElement("div");
      wrapper.innerHTML = html.trim();
      blurb.after(wrapper.firstElementChild!);
    }, DELAY_NOTICE_HTML);
  }
}

async function ensureDelayNoticeRemoved(page: Page) {
  await page.evaluate(() => {
    const notice = document.querySelector(".bg-yellow-100");
    if (notice) notice.remove();
  });
}

test.describe("Delay notice", () => {
  test("index page with delay notice", async ({ page }, testInfo) => {
    const prefix = testInfo.project.name;
    await page.goto("/");
    await page.waitForFunction(() => document.fonts.ready);
    await ensureDelayNoticePresent(page);
    await stabilizeStoriesSection(page);
    await stabilizeNewsImages(page);

    await expect(page).toHaveScreenshot(`${prefix}-index-with-delay.png`, {
      fullPage: true,
    });
  });

  test("index page without delay notice", async ({ page }, testInfo) => {
    const prefix = testInfo.project.name;
    await page.goto("/");
    await page.waitForFunction(() => document.fonts.ready);
    await ensureDelayNoticeRemoved(page);
    await stabilizeStoriesSection(page);
    await stabilizeNewsImages(page);

    await expect(page).toHaveScreenshot(`${prefix}-index-without-delay.png`, {
      fullPage: true,
    });
  });
});
