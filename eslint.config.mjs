// ESLint config for the React components (app/javascript), the Sprockets
// jQuery bundle (app/assets/javascripts) and the Node build config files.
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
      "app/assets/config/manifest.js",
    ],
  },
  js.configs.recommended,
  {
    files: ["app/javascript/**/*.{js,jsx}"],
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
  {
    files: ["babel.config.js", "config/webpack/**/*.js"],
    languageOptions: {
      sourceType: "commonjs",
      globals: globals.node,
    },
  },
];
