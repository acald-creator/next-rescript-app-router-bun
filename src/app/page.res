// Next.js Image component binding
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

@react.component
let make = () => {
  <div
    className="font-sans grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20">
    <main className="flex flex-col gap-[32px] row-start-2 items-center sm:items-start">
      <div className="flex items-center gap-4">
        <Image
          className="dark:invert"
          src="/next.svg"
          alt="Next.js logo"
          width={180}
          height={38}
          priority={true}
        />
        <span className="text-4xl font-light text-foreground/30">
          {React.string("+")}
        </span>
        <span className="text-3xl font-bold tracking-tight text-[#e6484f]">
          {React.string("ReScript")}
        </span>
      </div>
      <p className="text-center sm:text-left text-sm text-foreground/60 max-w-md">
        {React.string(
          "A Next.js 15 App Router application written in ReScript. Type-safe, functional, and fast.",
        )}
      </p>
      <ol className="font-mono list-inside list-decimal text-sm/6 text-center sm:text-left">
        <li className="mb-2 tracking-[-.01em]">
          {React.string("Get started by editing ")}
          <code
            className="bg-black/[.05] dark:bg-white/[.06] font-mono font-semibold px-1 py-0.5 rounded">
            {React.string("src/app/page.res")}
          </code>
          {React.string(".")}
        </li>
        <li className="tracking-[-.01em]">
          {React.string("Save and see your changes instantly.")}
        </li>
      </ol>
      <div className="flex gap-4 items-center flex-col sm:flex-row">
        <a
          className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center bg-foreground text-background gap-2 hover:bg-[#383838] dark:hover:bg-[#ccc] font-medium text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5 sm:w-auto"
          href="https://rescript-lang.org/docs/manual/latest/introduction"
          target="_blank"
          rel="noopener noreferrer">
          {React.string("ReScript Docs")}
        </a>
        <a
          className="rounded-full border border-solid border-black/[.08] dark:border-white/[.145] transition-colors flex items-center justify-center hover:bg-[#f2f2f2] dark:hover:bg-[#1a1a1a] hover:border-transparent font-medium text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5 w-full sm:w-auto md:w-[158px]"
          href="https://nextjs.org/docs?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app"
          target="_blank"
          rel="noopener noreferrer">
          {React.string("Next.js Docs")}
        </a>
      </div>
    </main>
    <footer className="row-start-3 flex gap-[24px] flex-wrap items-center justify-center">
      <a
        className="flex items-center gap-2 hover:underline hover:underline-offset-4"
        href="https://rescript-lang.org"
        target="_blank"
        rel="noopener noreferrer">
        <Image src="/file.svg" alt="File icon" width={16} height={16} />
        {React.string("ReScript")}
      </a>
      <a
        className="flex items-center gap-2 hover:underline hover:underline-offset-4"
        href="https://nextjs.org/learn?utm_source=create-next-app&utm_medium=appdir-template-tw&utm_campaign=create-next-app"
        target="_blank"
        rel="noopener noreferrer">
        <Image src="/window.svg" alt="Window icon" width={16} height={16} />
        {React.string("Learn Next.js")}
      </a>
      <a
        className="flex items-center gap-2 hover:underline hover:underline-offset-4"
        href="https://github.com/rescript-lang/rescript"
        target="_blank"
        rel="noopener noreferrer">
        <Image src="/globe.svg" alt="Globe icon" width={16} height={16} />
        {React.string("GitHub")}
      </a>
    </footer>
  </div>
}

// Default export for Next.js
let default = make
