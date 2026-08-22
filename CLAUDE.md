# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Next.js 16 App Router chat template written in ReScript, using Bun as the package manager. All pages and components are ReScript (no TypeScript components). The UI streams OpenAI-compatible Chat Completions from `POST /api/chat`. Uses Biome for formatting/linting and Tailwind CSS v4 for styling.

## Development Commands

### Running the Application
- `bun dev` - Start development server (uses Turbopack by default in Next.js 16)
- `bun run build` - Full production build (compiles ReScript then Next.js)

### ReScript Development
- `bun run res:build` - Compile ReScript files to JavaScript
- `bun run res:dev` - Watch mode for ReScript compilation
- `bun run res:clean` - Clean ReScript build artifacts

### Code Quality
- `bun run lint` - Run Biome linter and formatter checks
- `bun run format` - Auto-format code with Biome

### Production
- `bun run start` - Start Next.js production server

## Architecture

### ReScript-First Approach
All pages, layouts, and components are written in ReScript:
- `src/app/` - Next.js App Router pages, layouts, chat UI, and route handlers (`.res` files)
- `src/chat/` - OpenAI-compatible message types, SSE parser, and completions client
- `src/bindings/` - ReScript FFI bindings for Next.js and web APIs

### ReScript Integration
- ReScript source files are in `src/` with `.res` extension
- Compiled to ES modules with `.res.mjs` suffix
- Output is in-source (alongside `.res` files)
- Next.js config handles transpilation of ReScript dependencies
- Uses `@rescript/core` and `@rescript/react` packages

### Next.js Configuration
The `next.config.ts` includes:
- Turbopack configuration with `resolveExtensions` for `.mjs` files
- Webpack fallback rules for non-Turbopack builds
- Transpilation of ReScript packages
- `pageExtensions: ["tsx", "ts", "jsx", "js", "res.mjs"]`

### Directory Structure
- `src/app/` - Next.js App Router pages, layouts, and the client chat UI
- `src/app/Chat.res` - Client component (`@@directive("'use client'")`) for messages, composer, and streaming
- `src/app/api/chat/route.res` - `GET` config + `POST` streaming Chat Completions proxy
- `src/chat/` - Message JSON, OpenAI-compatible client, SSE parser
- `src/bindings/` - In-repo ReScript bindings used by this template (`Next.res`, `WebApi.res`)

### ReScript Bindings

Bindings stay in the repo for the MVP. Add Next.js APIs to `Next.res` when a page needs them. Extract a shared package later if a second app wants the same surface.

**`src/bindings/Next.res`** — `metadata` export used by `layout.res`.

**`src/bindings/WebApi.res`** — fetch, ReadableStream, AbortController, and Response helpers used by the chat route and client.

Environment (server-only, via `.env.local`): `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `OPENAI_MODEL`, `OPENAI_SYSTEM_PROMPT`. If key and base URL are both unset, `/api/chat` streams a local demo response.

## Tools and Configuration

### Biome
- Handles both linting and formatting
- Configured for Next.js and React
- 2-space indentation
- Organizes imports automatically
- Configuration in `biome.json`

### Package Manager
- Uses Bun as the primary package manager (`bun.lock` present)
- Package.json scripts assume Bun availability

## Development Workflow

1. Start ReScript compilation in watch mode: `bun run res:dev`
2. Start Next.js dev server: `bun dev`
3. Edit ReScript files in `src/` — they auto-compile to `.res.mjs`
4. Run linting: `bun run lint`

## Common ReScript Compilation Errors

### Inline Record Types Error
**Error**: "An inline record type declaration is only allowed in a variant constructor's declaration"

**Cause**: ReScript doesn't allow inline record types in regular type definitions like:
```rescript
type example = {
  field: array<{name: string, value: int}>  // This fails
}
```

**Fix**: Extract inline records as separate type definitions:
```rescript
type innerRecord = {name: string, value: int}
type example = {
  field: array<innerRecord>  // This works
}
```

### Optional Fields Syntax
**Error**: Type mismatches with optional record fields

**Cause**: ReScript's `?` optional field syntax doesn't work as expected for JavaScript interop.

**Fix**: Use explicit `option<'a>` types:
```rescript
// Don't use this for JS bindings:
type metadata = { title?: string }

// Use this instead:
type metadata = { title: option<string> }
```

### URLSearchParams and Web APIs
**Error**: "The module or file URLSearchParams can't be found"

**Cause**: Web API types aren't automatically available in ReScript.

**Fix**: Create abstract type bindings:
```rescript
type urlSearchParams  // Abstract type for URLSearchParams
@module("next/navigation")
external useSearchParams: unit => urlSearchParams = "useSearchParams"
```

### Client Component Directives
**Correct Usage**: ReScript supports the Next.js App Router client directive

**How to use**: Add `@@directive("'use client'")` at the top of ReScript component files:
```rescript
@@directive("'use client'")

@react.component
let make = (~children) => {
  // Client-side component logic here
  <div className="client-component"> {children} </div>
}
```

**Note**: This marks the entire file as a client component, enabling browser-specific APIs like `useState`, `useEffect`, event handlers, etc.

## Converting TypeScript Components to ReScript

### Component Structure Issues
**Error**: "Only one component definition is allowed for each module"

**Cause**: Having both external component bindings and component definitions in the same module.

**Fix**: Wrap external bindings in a module:
```rescript
// This fails:
@module("next/image") @react.component
external image: (~src: string) => React.element = "default"

@react.component
let make = () => <div />

// Use this instead:
module Image = {
  @module("next/image") @react.component
  external make: (~src: string) => React.element = "default"
}

@react.component
let make = () => <Image src="/logo.png" />
```

### Next.js Font Bindings
**Error 1**: "Font loaders can't have namespace imports"
**Error 2**: "Font loaders must be called and assigned to a const in the module scope"

**Cause**: ReScript's module bindings generate either namespace imports or `var` declarations, but Next.js font loaders require:
1. Direct named imports (not namespace imports)
2. `const` declarations at module scope

**Fix**: Use `%%raw` to generate the exact JavaScript that Next.js expects:
```rescript
// Font loaders - must be const declarations at module scope for Next.js
%%raw(`
import { Geist, Geist_Mono } from "next/font/google";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"]
});

const geistMonoFont = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"]
});
`)

// External bindings to access the font objects from ReScript
@val external geistSans: {"variable": string} = "geistSans"
@val external geistMonoFont: {"variable": string} = "geistMonoFont"
```

### CSS Imports
**Pattern**: Use `%%raw` for CSS imports:
```rescript
// TypeScript: import "./globals.css"
// ReScript:
%%raw(`import "./globals.css"`)
```

### Metadata Export (Next.js 16)
**Pattern**: Use the Metadata types from bindings. Note: `viewport`, `themeColor`, and `colorScheme` are no longer part of `metadata` — use a separate `viewport` export.
```rescript
open Next.Metadata

let metadata: metadata = {
  title: Some("Page Title"),
  description: Some("Page description"),
}
```

### Async Server APIs (Next.js 16)
**Important**: `cookies()`, `headers()`, page `params`, and `searchParams` are async in Next.js 16. They return `promise<T>` and must be awaited. Bind them in `Next.res` when a page needs them.

### Special HTML Attributes
**Issue**: ReScript doesn't support quoted prop names like `"aria-hidden"`

**Workaround**: Either omit the attribute or create a more complex binding with `@as`:
```rescript
// Simple approach - omit if not critical:
<Image src="/icon.svg" alt="Icon" width={16} height={16} />

// Complex approach - use @as decorator (advanced):
// ~ariaHidden: bool=? @as("aria-hidden")
```

### String Content
**Pattern**: Always wrap text content in `React.string()`:
```rescript
// This fails:
<div>"Hello World"</div>

// Use this:
<div>{React.string("Hello World")}</div>
```

<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->
