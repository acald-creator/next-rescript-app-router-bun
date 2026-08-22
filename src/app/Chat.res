@@directive("'use client'")

type config = {
  demo: bool,
  model: string,
}

type status = Idle | Streaming

let prompts = [
  "What is an OpenAI-compatible API?",
  "Explain ReScript records vs objects.",
  "Write a Next.js App Router route handler.",
]

@react.component
let make = () => {
  let (messages, setMessages) = React.useState((): array<Message.uiMessage> => [])
  let (input, setInput) = React.useState(() => "")
  let (status, setStatus) = React.useState(() => Idle)
  let (error, setError) = React.useState(() => None)
  let (config, setConfig) = React.useState(() => None)
  let abortRef = React.useRef(None)
  let idRef = React.useRef(0)
  let bottomRef = React.useRef((Nullable.null: Nullable.t<Dom.element>))

  let nextId = () => {
    idRef.current = idRef.current + 1
    Int.toString(idRef.current)
  }

  let streaming = status == Streaming

  React.useEffect0(() => {
    let cancelled = ref(false)
    let load = async () => {
      try {
        let response = await WebApi.fetch("/api/chat", {method: "GET"})
        if WebApi.ok(response) {
          let json = await WebApi.responseJson(response)
          switch JSON.Decode.object(json) {
          | Some(dict) =>
            let demo = switch Dict.get(dict, "demo") {
            | Some(value) => JSON.Decode.bool(value)->Option.getOr(false)
            | None => false
            }
            let model = switch Dict.get(dict, "model") {
            | Some(value) => JSON.Decode.string(value)->Option.getOr("unknown")
            | None => "unknown"
            }
            if !cancelled.contents {
              setConfig(_ => Some({demo, model}))
            }
          | None => ()
          }
        }
      } catch {
      | _ => ()
      }
    }
    let _ = load()
    Some(() => cancelled := true)
  })

  React.useEffect1(() => {
    switch Nullable.toOption(bottomRef.current) {
    | Some(el) => WebApi.scrollToBottom(el)
    | None => ()
    }
    None
  }, [messages])

  let stop = () => {
    switch abortRef.current {
    | Some(controller) => WebApi.abort(controller)
    | None => ()
    }
    abortRef.current = None
    setStatus(_ => Idle)
  }

  let appendDelta = (delta: string) => {
    setMessages(prev => {
      let lastIndex = Array.length(prev) - 1
      prev->Array.mapWithIndex((message, index) =>
        index === lastIndex && message.role == #assistant
          ? {...message, content: message.content ++ delta}
          : message
      )
    })
  }

  let streamCompletion = async (history: array<Message.uiMessage>) => {
    let controller = WebApi.makeAbortController()
    abortRef.current = Some(controller)
    setStatus(_ => Streaming)
    setError(_ => None)

    let payload = {
      "messages": history
      ->Array.filter(message => !(message.role == #assistant && message.content === ""))
      ->Array.map(Message.toApi),
    }

    try {
      let response = await WebApi.fetch(
        "/api/chat",
        {
          method: "POST",
          headers: Dict.fromArray([("Content-Type", "application/json")]),
          body: JSON.stringifyAny(payload)->Option.getOr("{}"),
          signal: WebApi.abortSignal(controller),
        },
      )

      if !WebApi.ok(response) {
        let body = try {
          await WebApi.responseJson(response)
        } catch {
        | _ => JSON.Encode.string(await WebApi.responseText(response))
        }
        setError(_ => Some(Message.errorMessage(body)->Option.getOr("Request failed")))
      } else {
        switch Nullable.toOption(WebApi.responseBody(response)) {
        | None => setError(_ => Some("The chat API returned an empty body"))
        | Some(stream) => await Sse.consume(stream, ~onDelta=appendDelta)
        }
      }
    } catch {
    | exn =>
      switch Error.fromException(exn) {
      | Some(err) if WebApi.isAbortError(err) => ()
      | Some(err) => setError(_ => Some(Error.message(err)->Option.getOr("Request failed")))
      | None => setError(_ => Some("Request failed"))
      }
    }

    abortRef.current = None
    setStatus(_ => Idle)
  }

  let submit = (text: string) => {
    let trimmed = String.trim(text)
    if trimmed === "" || streaming {
      ()
    } else {
      let user: Message.uiMessage = {id: nextId(), role: #user, content: trimmed}
      let assistant: Message.uiMessage = {id: nextId(), role: #assistant, content: ""}
      let nextMessages = Array.concat(messages, [user, assistant])
      setMessages(_ => nextMessages)
      setInput(_ => "")
      let _ = streamCompletion(nextMessages)
    }
  }

  let onSubmit = (event: ReactEvent.Form.t) => {
    event->ReactEvent.Form.preventDefault
    submit(input)
  }

  let onKeyDown = (event: ReactEvent.Keyboard.t) => {
    if ReactEvent.Keyboard.key(event) === "Enter" && !ReactEvent.Keyboard.shiftKey(event) {
      event->ReactEvent.Keyboard.preventDefault
      submit(input)
    }
  }

  let modelLabel = switch config {
  | Some({demo: true}) => "demo"
  | Some({model}) => model
  | None => "…"
  }

  <div className="font-sans min-h-screen flex flex-col">
    <header
      className="sticky top-0 z-10 border-b border-black/[.08] dark:border-white/[.08] bg-background/80 backdrop-blur">
      <div className="max-w-2xl mx-auto px-4 h-14 flex items-center justify-between gap-4">
        <div className="flex items-center gap-2 min-w-0">
          <span className="font-semibold tracking-tight"> {React.string("Chat")} </span>
          <span className="text-foreground/25"> {React.string("/")} </span>
          <span className="text-sm text-[#e6484f] font-medium truncate">
            {React.string("ReScript")}
          </span>
        </div>
        <div className="text-xs font-mono text-foreground/45 truncate">
          {React.string(modelLabel ++ " · OpenAI-compatible")}
        </div>
      </div>
    </header>
    <main className="flex-1 overflow-y-auto">
      <div className="max-w-2xl mx-auto px-4 py-8 flex flex-col gap-6">
        {switch messages {
        | [] =>
          <div className="flex flex-col gap-8 pt-10">
            <div className="flex flex-col gap-2">
              <h1 className="text-2xl font-semibold tracking-tight">
                {React.string("Talk to any OpenAI-compatible model")}
              </h1>
              <p className="text-sm text-foreground/50 max-w-md">
                {React.string(
                  "This template streams Chat Completions from /api/chat. Point OPENAI_BASE_URL at OpenAI, OpenRouter, Groq, Ollama, or any compatible server.",
                )}
              </p>
            </div>
            <div className="flex flex-col gap-2">
              <p className="text-xs font-mono text-foreground/40"> {React.string("Try")} </p>
              <div className="flex flex-col gap-2">
                {prompts
                ->Array.map(prompt =>
                  <button
                    key={prompt}
                    type_="button"
                    onClick={_ => submit(prompt)}
                    className="text-left text-sm px-4 py-3 rounded-lg border border-black/[.08] dark:border-white/[.12] hover:bg-black/[.03] dark:hover:bg-white/[.04] transition-colors">
                    {React.string(prompt)}
                  </button>
                )
                ->React.array}
              </div>
            </div>
          </div>
        | _ =>
          <div className="flex flex-col gap-5">
            {messages
            ->Array.map(message => {
              let isUser = message.role == #user
              let showCursor =
                streaming &&
                !isUser &&
                messages->Array.get(Array.length(messages) - 1)->Option.map(last => last.id === message.id)->Option.getOr(false)

              <div
                key={message.id}
                className={`flex ${isUser ? "justify-end" : "justify-start"}`}>
                <div
                  className={`max-w-[85%] text-sm leading-relaxed whitespace-pre-wrap break-words ${isUser
                      ? "bg-foreground text-background rounded-2xl px-4 py-2.5"
                      : "text-foreground/90"}`}>
                  {message.content === "" && showCursor
                    ? <span className="inline-block w-1.5 h-4 align-middle bg-foreground/50 animate-pulse" />
                    : <>
                        {React.string(message.content)}
                        {showCursor
                          ? <span
                              className="inline-block w-[2px] h-4 ml-0.5 align-middle bg-foreground/70 animate-pulse"
                            />
                          : React.null}
                      </>}
                </div>
              </div>
            })
            ->React.array}
            <div
              ref={ReactDOM.Ref.domRef(bottomRef)}
            />
          </div>
        }}
      </div>
    </main>
    <footer
      className="sticky bottom-0 bg-background/80 backdrop-blur border-t border-black/[.08] dark:border-white/[.08]">
      <div className="max-w-2xl mx-auto px-4 py-4 flex flex-col gap-3">
        {switch config {
        | Some({demo: true}) =>
          <p className="text-xs text-foreground/45">
            {React.string("Demo mode — add OPENAI_API_KEY in .env.local to use a real model.")}
          </p>
        | _ => React.null
        }}
        {switch error {
        | Some(message) =>
          <p className="text-xs text-red-600 dark:text-red-400"> {React.string(message)} </p>
        | None => React.null
        }}
        <form onSubmit={onSubmit} className="flex items-end gap-2">
          <textarea
            value={input}
            rows={1}
            autoFocus={true}
            placeholder="Message"
            onChange={event => {
              let target = ReactEvent.Form.target(event)
              setInput(_ => target["value"])
            }}
            onKeyDown={onKeyDown}
            className="flex-1 resize-none min-h-11 max-h-40 px-4 py-2.5 text-sm rounded-2xl border border-black/[.08] dark:border-white/[.12] bg-black/[.02] dark:bg-white/[.03] outline-none focus:border-foreground/30"
          />
          {streaming
            ? <button
                type_="button"
                onClick={_ => stop()}
                className="h-11 px-4 rounded-2xl bg-foreground text-background text-sm font-medium hover:opacity-90">
                {React.string("Stop")}
              </button>
            : <button
                type_="submit"
                disabled={String.trim(input) === ""}
                className="h-11 px-4 rounded-2xl bg-foreground text-background text-sm font-medium hover:opacity-90 disabled:opacity-30">
                {React.string("Send")}
              </button>}
        </form>
        <p className="text-[11px] text-foreground/30 font-mono">
          {React.string("Next.js 16 + ReScript 11 + Bun · POST /api/chat")}
        </p>
      </div>
    </footer>
  </div>
}

let default = make
