// ESLint config for the React components (app/javascript) and their tests
// (test/javascript), and the Sprockets jQuery bundle (app/assets/javascripts).
// Run it with bin/lint, which also runs RuboCop.
import js from "@eslint/js";
import react from "eslint-plugin-react";
import reactHooks from "eslint-plugin-react-hooks";
import globals from "globals";

export default [
  {
    ignores: [
      "node_modules/",
      "public/",
      "tmp/",
      "vendor/",
      "app/assets/builds/",
      "app/assets/config/manifest.js",
    ],
  },
  js.configs.recommended,
  {
    files: ["app/javascript/**/*.{js,jsx}", "test/javascript/**/*.{js,jsx}"],
    ...react.configs.flat.recommended,
    languageOptions: {
      ...react.configs.flat.recommended.languageOptions,
      ecmaVersion: "latest",
      sourceType: "module",
      globals: globals.browser,
    },
    settings: { react: { version: "detect" } },
  },
  {
    files: ["app/javascript/**/*.{js,jsx}", "test/javascript/**/*.{js,jsx}"],
    // esbuild compiles JSX with the automatic runtime, so files don't need
    // `import React`.
    ...react.configs.flat["jsx-runtime"],
  },
  {
    files: ["app/javascript/**/*.{js,jsx}", "test/javascript/**/*.{js,jsx}"],
    rules: {
      // React 19 no longer checks propTypes on function components, so they
      // would only be dead code. The Vitest tests cover the props instead.
      "react/prop-types": "off",
    },
  },
  {
    files: ["app/javascript/**/*.{js,jsx}"],
    ...reactHooks.configs.flat.recommended,
  },
  {
    files: ["app/assets/javascripts/**/*.js"],
    languageOptions: {
      sourceType: "script",
      globals: { ...globals.browser, ...globals.jquery },
    },
  },
];
