open Next.Metadata

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

// External bindings to access the font objects
@val external geistSans: {"variable": string} = "geistSans"
@val external geistMonoFont: {"variable": string} = "geistMonoFont"

// Metadata export
let metadata: metadata = {
  title: Some("Chat · ReScript + Next.js"),
  description: Some("OpenAI-compatible chat template for Next.js App Router and ReScript"),
}

// CSS import
%%raw(`import "./globals.css"`)

// Root layout component
@react.component
let make = (~children: React.element) => {
  <html lang="en">
    <body
      className={`${geistSans["variable"]} ${geistMonoFont["variable"]} antialiased`}>
      {children}
    </body>
  </html>
}

// Default export for Next.js
let default = make