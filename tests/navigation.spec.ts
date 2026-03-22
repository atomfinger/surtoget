import { test, expect } from "@playwright/test";

const NAV_LINKS = [
  { text: "Hjem", path: "/" },
  { text: "Nyheter", path: "/news" },
  { text: "Om Surtoget", path: "/om-surtoget" },
  { text: "Ofte stilte spørsmål", path: "/faq" },
];

test.describe("Navigation links", () => {
  for (const link of NAV_LINKS) {
    test(`"${link.text}" navigates to ${link.path}`, async ({
      page,
    }, testInfo) => {
      await page.goto("/");

      const isMobile = testInfo.project.name === "mobile";

      if (isMobile) {
        await page.click("#menu-button");
        await expect(page.locator("nav#menu")).toBeVisible();
      }

      await page.click(`nav#menu a:has-text("${link.text}")`);
      await expect(page).toHaveURL(link.path);
    });
  }
});
