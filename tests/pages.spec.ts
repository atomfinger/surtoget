import { test, expect } from "@playwright/test";
import {
  waitForChartsAndFonts,
  stabilizeStoriesSection,
  removeDelayNotice,
  stabilizeNewsImages,
} from "./helpers";

test.describe("Index page", () => {
  test("full page snapshot", async ({ page }, testInfo) => {
    const prefix = testInfo.project.name;
    await page.goto("/");
    await waitForChartsAndFonts(page);
    await stabilizeStoriesSection(page);
    await removeDelayNotice(page);
    await stabilizeNewsImages(page);

    await expect(page).toHaveScreenshot(`${prefix}-index.png`, {
      fullPage: true,
    });
  });
});

test.describe("About page", () => {
  test("full page snapshot", async ({ page }, testInfo) => {
    const prefix = testInfo.project.name;
    await page.goto("/om-surtoget");
    await page.waitForFunction(() => document.fonts.ready);

    await expect(page).toHaveScreenshot(`${prefix}-about.png`, {
      fullPage: true,
    });
  });
});

test.describe("News page", () => {
  test("full page snapshot", async ({ page }, testInfo) => {
    const prefix = testInfo.project.name;
    await page.goto("/news");
    await page.waitForFunction(() => document.fonts.ready);
    await stabilizeNewsImages(page);

    await expect(page).toHaveScreenshot(`${prefix}-news.png`, {
      fullPage: true,
    });
  });
});

test.describe("FAQ page", () => {
  test("full page snapshot", async ({ page }, testInfo) => {
    const prefix = testInfo.project.name;
    await page.goto("/faq");
    await page.waitForFunction(() => document.fonts.ready);

    await expect(page).toHaveScreenshot(`${prefix}-faq.png`, {
      fullPage: true,
    });
  });
});
