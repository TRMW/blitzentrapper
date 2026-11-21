// Unit tests for the React setlist widget (app/javascript). Run: yarn test
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: [ "test/javascript/**/*.test.{js,jsx}" ],
    environment: "jsdom",
  },
});
