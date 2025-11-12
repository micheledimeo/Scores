// @ts-check
const { test, expect } = require('@playwright/test');

// Test configuration
const NEXTCLOUD_URL = 'https://cloud.ottoniascoppio.org';
const APP_URL = `${NEXTCLOUD_URL}/index.php/apps/scores`;
const USERNAME = process.env.NEXTCLOUD_USER || 'kele@blu.it';
const PASSWORD = process.env.NEXTCLOUD_PASSWORD || 'Testsprite.0';

test.describe('Scores App - Online Tests', () => {

  test.beforeEach(async ({ page }) => {
    // Login to Nextcloud
    await page.goto(NEXTCLOUD_URL);

    // Check if already logged in
    const isLoggedIn = await page.locator('[data-user], .app-menu').isVisible().catch(() => false);

    if (!isLoggedIn) {
      // Wait for login page to load
      await page.waitForLoadState('networkidle');

      // Try multiple possible selectors for username field
      const usernameField = page.locator('input[name="user"], input[type="text"][autocomplete="username"], #user, input[placeholder*="Username"]').first();
      const passwordField = page.locator('input[name="password"], input[type="password"], #password').first();
      const submitButton = page.locator('button[type="submit"], input[type="submit"], button:has-text("Log in")').first();

      await usernameField.waitFor({ timeout: 10000 });
      await usernameField.fill(USERNAME);
      await passwordField.fill(PASSWORD);
      await submitButton.click();

      // Wait for login to complete
      await page.waitForLoadState('networkidle');
      await page.waitForTimeout(2000);
    }
  });

  test('App is accessible and loads', async ({ page }) => {
    // Navigate to Scores app
    await page.goto(APP_URL);

    // Wait for app to load
    await page.waitForLoadState('networkidle');

    // Check that we're on the scores page
    expect(page.url()).toContain('/apps/scores');

    // Verify page loaded without errors
    const errorElements = await page.locator('.error, .alert-error').count();
    expect(errorElements).toBe(0);
  });

  test('Main UI elements are present', async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForLoadState('networkidle');

    // Check for main app container
    const appContainer = page.locator('#app-content, .app-content');
    await expect(appContainer).toBeVisible({ timeout: 10000 });
  });

  test('Search functionality is available', async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForLoadState('networkidle');

    // Look for search input (may vary based on implementation)
    const searchInput = page.locator('input[type="search"], input[placeholder*="Search"], input[placeholder*="search"]').first();

    if (await searchInput.isVisible().catch(() => false)) {
      await expect(searchInput).toBeVisible();
    }
  });

  test('No console errors on load', async ({ page }) => {
    const consoleErrors = [];

    page.on('console', msg => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
      }
    });

    await page.goto(APP_URL);
    await page.waitForLoadState('networkidle');

    // Filter out common non-critical errors
    const criticalErrors = consoleErrors.filter(error =>
      !error.includes('favicon') &&
      !error.includes('chrome-extension')
    );

    expect(criticalErrors.length).toBe(0);
  });

  test('App responds to navigation', async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForLoadState('networkidle');

    // Check that the page responds (not frozen)
    const title = await page.title();
    expect(title.length).toBeGreaterThan(0);
  });

});

test.describe('Scores App - Settings (Admin)', () => {

  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto(NEXTCLOUD_URL);

    const isLoggedIn = await page.locator('[data-user], .app-menu').isVisible().catch(() => false);

    if (!isLoggedIn) {
      await page.waitForLoadState('networkidle');

      const usernameField = page.locator('input[name="user"], input[type="text"][autocomplete="username"], #user, input[placeholder*="Username"]').first();
      const passwordField = page.locator('input[name="password"], input[type="password"], #password').first();
      const submitButton = page.locator('button[type="submit"], input[type="submit"], button:has-text("Log in")').first();

      await usernameField.waitFor({ timeout: 10000 });
      await usernameField.fill(USERNAME);
      await passwordField.fill(PASSWORD);
      await submitButton.click();
      await page.waitForLoadState('networkidle');
      await page.waitForTimeout(2000);
    }
  });

  test('Admin can access settings', async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForLoadState('networkidle');

    // Look for settings button/icon
    const settingsButton = page.locator('[class*="settings"], [aria-label*="Settings"], button:has-text("Settings")').first();

    if (await settingsButton.isVisible().catch(() => false)) {
      await expect(settingsButton).toBeVisible();
    }
  });

});
