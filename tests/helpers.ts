import { Page } from "@playwright/test";

/**
 * Since the opinions section is based on comments that are randomized, that
 * is causing some issues and flakey tests. If a long comment is chosen in one
 * test run and not the other, then the overall view will change and cause
 * a test to fail.
 */
export async function stabilizeStoriesSection(page: Page) {
  await page.evaluate(() => {
    // Find the section containing "Folkets meninger"
    const headings = document.querySelectorAll("h2");
    for (const h2 of headings) {
      if (h2.textContent?.includes("Folkets meninger")) {
        const section = h2.closest("section");
        if (section) {
          section.style.height = "400px";
          section.style.overflow = "hidden";
          section.innerHTML =
            '<div style="height:400px;background:#e5e7eb;display:flex;align-items:center;justify-content:center;color:#6b7280;font-size:14px;">Stories section (masked - non-deterministic)</div>';
        }
        break;
      }
    }
  });
}

/**
 * The delay notice is dynamic, and we need to remove it to avoid flakey
 * tests.
 */
export async function removeDelayNotice(page: Page) {
  await page.evaluate(() => {
    const notice = document.querySelector(".bg-yellow-100");
    if (notice) notice.remove();
  });
}

/**
 * Images are lazy loaded, and therefore they can quickly make tests flakey.
 * Here we are simply "graying" them out to make things simpler.
 */
export async function stabilizeNewsImages(page: Page) {
  await page.evaluate(() => {
    document.querySelectorAll('img[loading="lazy"]').forEach((img) => {
      const el = img as HTMLImageElement;
      // Prevent any further loading or error-driven swaps
      el.removeAttribute("onerror");
      el.removeAttribute("src");
      el.removeAttribute("srcset");
      el.style.background = "#d1d5db";
      el.style.display = "block";
      // Preserve the container's intended dimensions
      if (!el.style.width) el.style.width = "100%";
      if (!el.style.height) el.style.height = "12rem"; // h-48
    });
  });
}

/**
 * Wait for D3 charts to render and fonts to load.
 */
export async function waitForChartsAndFonts(page: Page) {
  await page.waitForFunction(
    () => {
      const charts = document.querySelectorAll("[data-chartdata] svg");
      return charts.length > 0;
    },
    { timeout: 10_000 },
  );
  await page.waitForFunction(() => document.fonts.ready);
}
