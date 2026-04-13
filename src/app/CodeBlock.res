@@directive("'use client'")

type example = {
  label: string,
  resCode: string,
  jsCode: string,
}

@react.component
let make = (~examples: array<example>) => {
  let (activeExample, setActiveExample) = React.useState(() => 0)
  let (activeTab, setActiveTab) = React.useState(() => #res)

  let current = examples->Array.get(activeExample)->Option.getOr(examples->Array.getUnsafe(0))

  <div className="w-full max-w-2xl">
    // Example selector
    {switch examples->Array.length > 1 {
    | true =>
      <div className="flex gap-1 mb-3">
        {examples
        ->Array.mapWithIndex((example, i) => {
          let isActive = i === activeExample
          <button
            key={Int.toString(i)}
            onClick={_ => {
              setActiveExample(_ => i)
              setActiveTab(_ => #res)
            }}
            className={`px-3 py-1 text-xs rounded-full transition-colors ${isActive
                ? "bg-foreground text-background"
                : "text-foreground/50 hover:text-foreground/80"}`}>
            {React.string(example.label)}
          </button>
        })
        ->React.array}
      </div>
    | false => React.null
    }}
    // Code block
    <div className="rounded-lg border border-black/[.08] dark:border-white/[.12] overflow-hidden">
      // File tabs
      <div
        className="flex items-center gap-0 bg-black/[.03] dark:bg-white/[.03] border-b border-black/[.08] dark:border-white/[.08]">
        <button
          onClick={_ => setActiveTab(_ => #res)}
          className={`px-4 py-2 text-xs font-mono transition-colors border-b-2 ${activeTab === #res
              ? "border-foreground/80 text-foreground"
              : "border-transparent text-foreground/40 hover:text-foreground/60"}`}>
          {React.string(".res")}
        </button>
        <button
          onClick={_ => setActiveTab(_ => #mjs)}
          className={`px-4 py-2 text-xs font-mono transition-colors border-b-2 ${activeTab === #mjs
              ? "border-foreground/80 text-foreground"
              : "border-transparent text-foreground/40 hover:text-foreground/60"}`}>
          {React.string(".res.mjs")}
        </button>
      </div>
      // Code content
      <pre
        className="p-4 overflow-x-auto text-[13px] leading-relaxed bg-black/[.02] dark:bg-white/[.02]">
        <code className="font-mono text-foreground/80">
          {React.string(
            switch activeTab {
            | #res => current.resCode
            | #mjs => current.jsCode
            },
          )}
        </code>
      </pre>
    </div>
  </div>
}

let default = make
