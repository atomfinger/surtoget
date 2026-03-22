import { test, expect, Page } from "@playwright/test";

const TAB_IDS = ["last_month", "this_year", "punctuality_over_time"] as const;

async function waitForChartInTab(page: Page, tabId: string) {
  await page.waitForFunction(
    (id: string) => {
      const container = document.getElementById(`${id}-content`);
      if (!container) return false;
      return container.querySelectorAll("svg").length > 0;
    },
    tabId,
    { timeout: 10_000 },
  );
}

for (const tabId of TAB_IDS) {
  test.describe(`Statistics tab: ${tabId}`, () => {
    test(`snapshot`, async ({ page }, testInfo) => {
      const prefix = testInfo.project.name;
      await page.goto("/");

      const isMobile = testInfo.project.name === "mobile";
      if (isMobile) {
        const tabsToggle = page.locator("#tabs-toggle");
        if (await tabsToggle.isVisible()) {
          await tabsToggle.click();
          await expect(page.locator("#tabs-menu")).toBeVisible();
        }
      }

      if (tabId !== "last_month") {
        await page.click(`[data-tab="${tabId}"]`);
      }

      if (isMobile) {
        const tabsToggle = page.locator("#tabs-toggle");
        if (await tabsToggle.isVisible()) {
          await tabsToggle.click();
        }
      }

      await waitForChartInTab(page, tabId);
      // Allow D3 transitions to settle
      await page.waitForTimeout(500);

      const tabContent = page.locator(`#${tabId}-content`);
      await expect(tabContent).toHaveScreenshot(`${prefix}-stats-${tabId}.png`);
    });
  });
}
