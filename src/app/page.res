module Image = {
  @module("next/image") @react.component
  external make: (
    ~className: string=?,
    ~src: string,
    ~alt: string,
    ~width: int,
    ~height: int,
    ~priority: bool=?,
  ) => React.element = "default"
}

let componentExample: CodeBlock.example = {
  label: "Component",
  resCode: `@react.component
let make = () => {
  let (count, setCount) = React.useState(() => 0)

  <button onClick={_ => setCount(c => c + 1)}>
    {React.string("Clicks: " ++ Int.toString(count))}
  </button>
}`,
  jsCode: `import { jsx } from "react/jsx-runtime";
import { useState } from "react";

function make() {
  let [count, setCount] = useState(() => 0);

  return jsx("button", {
    onClick: () => setCount(c => c + 1),
    children: "Clicks: " + count.toString()
  });
}`,
}

let bindingExample: CodeBlock.example = {
  label: "Binding",
  resCode: `// Type-safe bindings to Next.js APIs
module Link = {
  @module("next/link") @react.component
  external make: (
    ~href: string,
    ~prefetch: bool=?,
    ~className: string=?,
    ~children: React.element,
  ) => React.element = "default"
}

// Used like any ReScript component
<Link href="/about" prefetch={true}>
  {React.string("About")}
</Link>`,
  jsCode: `// Compiles to a direct import — zero overhead
import Link from "next/link";

jsx(Link, {
  href: "/about",
  prefetch: true,
  children: "About"
});`,
}

let serverExample: CodeBlock.example = {
  label: "Server",
  resCode: `// Async server APIs (Next.js 16)
module Cookies = {
  type cookieStore
  type cookieValue = { name: string, value: string }

  @module("next/headers")
  external cookies: unit => promise<cookieStore>
    = "cookies"

  @send
  external get: (cookieStore, string)
    => option<cookieValue> = "get"
}

// Usage in a server component
let token = await Cookies.cookies()
  ->Cookies.get("session")`,
  jsCode: `import { cookies } from "next/headers";

// Direct call — ReScript externals compile away
let token = (await cookies()).get("session");`,
}

@react.component
let make = () => {
  <div
    className="font-sans grid grid-rows-[1fr_auto] items-center justify-items-center min-h-screen p-8 pb-12 gap-16 sm:p-20">
    <main className="flex flex-col gap-10 items-center sm:items-start max-w-2xl w-full">
      // Header
      <div className="flex flex-col gap-3">
        <div className="flex items-center gap-3">
          <Image
            className="dark:invert"
            src="/next.svg"
            alt="Next.js logo"
            width={120}
            height={25}
            priority={true}
          />
          <span className="text-2xl font-light text-foreground/20">
            {React.string("+")}
          </span>
          <span className="text-xl font-bold tracking-tight text-[#e6484f]">
            {React.string("ReScript")}
          </span>
        </div>
        <p className="text-sm text-foreground/50">
          {React.string(
            "Write Next.js apps in ReScript. The compiler catches your mistakes, the output is clean JS.",
          )}
        </p>
      </div>
      // Code showcase
      <CodeBlock examples={[componentExample, bindingExample, serverExample]} />
      // Quick start
      <div className="flex flex-col gap-2 w-full">
        <p className="text-xs font-mono text-foreground/40"> {React.string("Get started")} </p>
        <div
          className="font-mono text-sm bg-black/[.03] dark:bg-white/[.03] border border-black/[.08] dark:border-white/[.08] rounded-lg px-4 py-3 text-foreground/70 select-all">
          {React.string("bun create next-rescript-app my-app")}
        </div>
        <p className="text-xs text-foreground/40 mt-1">
          {React.string("or edit ")}
          <code
            className="bg-black/[.05] dark:bg-white/[.06] font-mono font-medium px-1 py-0.5 rounded text-foreground/60">
            {React.string("src/app/page.res")}
          </code>
          {React.string(" to start building.")}
        </p>
      </div>
      // Links
      <div className="flex gap-3 flex-wrap">
        <a
          className="rounded-full border border-solid border-transparent bg-foreground text-background hover:bg-[#383838] dark:hover:bg-[#ccc] font-medium text-sm h-9 px-4 flex items-center transition-colors"
          href="https://rescript-lang.org/docs/manual/latest/introduction"
          target="_blank"
          rel="noopener noreferrer">
          {React.string("ReScript Docs")}
        </a>
        <a
          className="rounded-full border border-solid border-black/[.08] dark:border-white/[.145] hover:bg-[#f2f2f2] dark:hover:bg-[#1a1a1a] hover:border-transparent font-medium text-sm h-9 px-4 flex items-center transition-colors"
          href="https://nextjs.org/docs"
          target="_blank"
          rel="noopener noreferrer">
          {React.string("Next.js Docs")}
        </a>
        <a
          className="rounded-full border border-solid border-black/[.08] dark:border-white/[.145] hover:bg-[#f2f2f2] dark:hover:bg-[#1a1a1a] hover:border-transparent font-medium text-sm h-9 px-4 flex items-center transition-colors"
          href="https://github.com/acald-creator/next-rescript-app-router-bun"
          target="_blank"
          rel="noopener noreferrer">
          {React.string("GitHub")}
        </a>
      </div>
    </main>
    // Footer
    <footer className="text-xs text-foreground/30 font-mono">
      {React.string("Next.js 16 + ReScript 11 + Bun")}
    </footer>
  </div>
}

let default = make
