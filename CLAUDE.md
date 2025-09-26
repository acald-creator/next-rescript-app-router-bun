# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Next.js 15 application using the App Router architecture with ReScript integration and Bun as the package manager. The project combines TypeScript (for Next.js components) with ReScript (for functional programming) and uses Biome for code formatting and linting.

## Development Commands

### Running the Application
- `bun dev` - Start development server (preferred, uses Bun)
- `npm run dev` - Alternative development server
- `bun run dev:turbo` - Development with Turbopack (experimental)

### Building
- `bun run build` - Full production build (compiles ReScript then Next.js)
- `bun run build:turbo` - Build with Turbopack (experimental)

### ReScript Development
- `bun run res:build` - Compile ReScript files to JavaScript
- `bun run res:dev` - Watch mode for ReScript compilation
- `bun run res:clean` - Clean ReScript build artifacts

### Code Quality
- `bun run lint` - Run Biome linter and formatter checks
- `bun run format` - Auto-format code with Biome

### Production
- `bun run start` - Serve static build with npx serve
- `bun run start:turbo` - Start Next.js production server

## Architecture

### Hybrid Language Approach
This project uses both TypeScript and ReScript:
- **TypeScript**: Next.js App Router components (`src/app/`)
- **ReScript**: Business logic and utilities (`src/bindings/`)

### ReScript Integration
- ReScript source files are in `src/` with `.res` extension
- Compiled to ES modules with `.res.mjs` suffix
- Output is in-source (alongside `.res` files)
- Next.js config handles transpilation of ReScript dependencies
- Uses `@rescript/core` and `@rescript/react` packages

### Next.js Configuration
The `next.config.ts` includes:
- Custom webpack rules for ReScript `.mjs` files
- Transpilation of ReScript packages
- Client-side fallbacks for Node.js modules (fs, path)

### Directory Structure
- `src/app/` - Next.js App Router pages and layouts (TypeScript)
- `src/bindings/` - ReScript bindings for Next.js APIs
- `lib/bs/` - ReScript build artifacts (auto-generated)

### ReScript Bindings
The project includes comprehensive Next.js App Router bindings in `src/bindings/NextAppRouter.res` covering:
- Client-side navigation hooks (useRouter, usePathname, etc.)
- Link component
- Metadata types and helpers
- Error handling
- Loading states

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
3. Edit ReScript files in `src/` - they auto-compile to `.res.mjs`
4. Edit TypeScript components in `src/app/`
5. Run linting: `bun run lint`

## Common ReScript Compilation Errors

### Inline Record Types Error
**Error**: "An inline record type declaration is only allowed in a variant constructor's declaration"

**Cause**: ReScript doesn't allow inline record types in regular type definitions like:
```rescript
type example = {
  field: array<{name: string, value: int}>  // ❌ This fails
}
```

**Fix**: Extract inline records as separate type definitions:
```rescript
type innerRecord = {name: string, value: int}
type example = {
  field: array<innerRecord>  // ✅ This works
}
```

### Optional Fields Syntax
**Error**: Type mismatches with optional record fields

**Cause**: ReScript's `?` optional field syntax doesn't work as expected for JavaScript interop.

**Fix**: Use explicit `option<'a>` types:
```rescript
// ❌ Don't use this for JS bindings:
type metadata = { title?: string }

// ✅ Use this instead:
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
// ❌ This fails:
@module("next/image") @react.component
external image: (~src: string) => React.element = "default"

@react.component
let make = () => <div />

// ✅ Use this instead:
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
// ❌ This fails with namespace/const errors:
@module("next/font/google")
external geist: {...} => {...} = "Geist"
let font = geist({...})

// ✅ Use this pattern instead:
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

### Metadata Export
**Pattern**: Use the Metadata types from bindings:
```rescript
open NextAppRouter.Metadata

let metadata: metadata = {
  title: Some("Page Title"),
  description: Some("Page description"),
  keywords: None,
  // ... set other fields to None
}
```

### Special HTML Attributes
**Issue**: ReScript doesn't support quoted prop names like `"aria-hidden"`

**Workaround**: Either omit the attribute or create a more complex binding with `@as`:
```rescript
// Simple approach - omit if not critical:
<Image src="/icon.svg" alt="Icon" width={16} height={16} />

// Complex approach - use @as decorator (advanced):
// ~ariaHidden: bool=? @as("aria-hidden")
```

### Next.js Configuration Updates
**Required**: Add ReScript compiled extensions to Next.js config:
```typescript
// next.config.ts
const nextConfig: NextConfig = {
  pageExtensions: ["tsx", "ts", "jsx", "js", "res.mjs"],
  // ... other config
}
```

### String Content
**Pattern**: Always wrap text content in `React.string()`:
```rescript
// ❌ This fails:
<div>"Hello World"</div>

// ✅ Use this:
<div>{React.string("Hello World")}</div>
```