# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Development
npm start               # Start Vite dev server on port 8000
npm run dev             # Alias for npm start

# Build
npm run build           # Full build (core + all 6 plugins)
npm run build:core      # Build core only (TypeScript + Vite + banner)
npm run build:styles    # Build CSS/SCSS only
npm run build:es5       # Build ES5-compatible output

# Test
npm test                # Run QUnit tests via Puppeteer (headless Chrome, port 8009)

# React wrapper (run from repo root)
npm test --prefix react         # Run React wrapper tests (Vitest)
npm run build --prefix react    # Build React wrapper
npm run react:demo              # Run React demo
```

## Architecture

reveal.js is a browser-based presentation framework. The codebase has two distinct packages:

### Core (`/js`, `/plugin`)

The `Reveal` object (created by a factory in `js/reveal.js`) acts as a central hub. On `initialize()`, it instantiates ~15 controller classes — each responsible for one concern (navigation, keyboard, touch, animations, backgrounds, notes, etc.). Controllers receive the `Reveal` instance as a dependency and communicate through it.

- `js/index.ts` — public entry point with backwards-compatibility shims
- `js/reveal.js` — main factory; owns state and coordinates controllers
- `js/config.ts` — all config options with defaults and TypeScript types
- `js/controllers/` — one file per concern (autoanimate, fragments, keyboard, overview, etc.)
- `js/utils/` — pure utilities (loader, color, device, constants)
- `plugin/` — 6 official plugins (highlight, markdown, math, notes, search, zoom), each with its own `vite.config.ts`

Build output format: ES Module (`.esm.js`) and UMD (`.js`), built via Vite/Rollup. Plugins are built separately.

Config precedence (highest wins): query params > `initialize()` options > constructor options > pre-init `configure()` calls > defaults.

### React Wrapper (`/react`)

Package `@revealjs/react` — a thin React layer over the core. See `react/AGENTS.md` for detailed behavioral contracts. Key invariants:

- `Deck` creates one `Reveal` instance on mount, destroys on unmount. Safe under React StrictMode.
- `Reveal.sync()` is expensive — only call it when slide *structure* changes (slides added/removed/reordered). Ordinary content updates inside a slide must not trigger sync.
- Config is shallow-compared; recreating a config object with identical shallow values must not call `configure()`.
- Component responsibilities: `Deck` owns lifecycle/config/events, `Slide` owns attribute mapping, `Markdown` owns markdown parsing and DOM post-processing, `Code` owns highlight integration.

### Testing

- **Core**: QUnit HTML test files in `/test/`, run via Puppeteer against the Vite dev server (port 8009).
- **React**: Vitest tests colocated with components as `*.test.tsx`.

### Code Style

Tabs, single quotes, 100-char line width (`.prettierrc`). Prettier only formats TypeScript — JS files are excluded. The codebase is a mix of `.js` controllers (JSDoc-annotated) and `.ts` utilities/config; the React wrapper is pure TypeScript/TSX.
