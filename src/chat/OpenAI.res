// OpenAI-compatible Chat Completions client (`/v1/chat/completions`).
// Works with OpenAI, OpenRouter, Groq, Ollama, Azure-compatible proxies, etc.

module Env = {
  @val @scope(("process", "env"))
  external apiKey: Nullable.t<string> = "OPENAI_API_KEY"

  @val @scope(("process", "env"))
  external baseUrl: Nullable.t<string> = "OPENAI_BASE_URL"

  @val @scope(("process", "env"))
  external model: Nullable.t<string> = "OPENAI_MODEL"

  @val @scope(("process", "env"))
  external systemPrompt: Nullable.t<string> = "OPENAI_SYSTEM_PROMPT"
}

let nonEmpty = (value: Nullable.t<string>): option<string> =>
  switch Nullable.toOption(value) {
  | Some(text) =>
    let trimmed = String.trim(text)
    trimmed === "" ? None : Some(trimmed)
  | None => None
  }

let defaultBaseUrl = "https://api.openai.com/v1"
let defaultModel = "gpt-4o-mini"

let baseUrl = () => nonEmpty(Env.baseUrl)->Option.getOr(defaultBaseUrl)
let model = () => nonEmpty(Env.model)->Option.getOr(defaultModel)
let apiKey = () => nonEmpty(Env.apiKey)
let systemPrompt = () => nonEmpty(Env.systemPrompt)

let trimSlash = (url: string) =>
  String.endsWith(url, "/") ? String.slice(url, ~start=0, ~end=String.length(url) - 1) : url

let isDemo = () =>
  switch (apiKey(), nonEmpty(Env.baseUrl)) {
  | (None, None) => true
  | _ => false
  }

type publicConfig = {
  demo: bool,
  model: string,
}

let publicConfig = (): publicConfig => {
  demo: isDemo(),
  model: isDemo() ? "demo" : model(),
}

type streamError = {status: int, message: string}

let demoText = `This is demo mode. Tokens are streamed locally because OPENAI_API_KEY is not set.

Add a .env.local file:

OPENAI_API_KEY=sk-...
OPENAI_BASE_URL=https://api.openai.com/v1
OPENAI_MODEL=gpt-4o-mini

OPENAI_BASE_URL can point at any OpenAI-compatible provider — OpenRouter, Groq, Ollama, Azure, vLLM, and others.`

let encodeSseChunk = (content: string): string => {
  let payload = {
    "choices": [{"delta": {"content": content}}],
  }
  "data: " ++ Option.getOr(JSON.stringifyAny(payload), "{}") ++ "\n\n"
}

let makeDemoStream = (): WebApi.readableStream => {
  let encoder = WebApi.makeTextEncoder()
  let words = String.split(demoText, " ")
  let index = ref(0)
  WebApi.makeReadableStream({
    "start": controller => {
      let rec sendNext = async () => {
        if index.contents >= Array.length(words) {
          WebApi.enqueue(controller, WebApi.encode(encoder, "data: [DONE]\n\n"))
          WebApi.close(controller)
        } else {
          let word = words->Array.get(index.contents)->Option.getOr("")
          let suffix = index.contents < Array.length(words) - 1 ? " " : ""
          WebApi.enqueue(controller, WebApi.encode(encoder, encodeSseChunk(word ++ suffix)))
          index := index.contents + 1
          await WebApi.wait(22)
          await sendNext()
        }
      }
      let _ = sendNext()
    },
  })
}

let withSystemPrompt = (messages: array<Message.t>): array<Message.t> =>
  switch systemPrompt() {
  | None => messages
  | Some(content) =>
    let systemMessage: Message.t = {role: #system, content: content}
    Array.concat([systemMessage], messages)
  }

let complete = async (messages: array<Message.t>): result<WebApi.readableStream, streamError> =>
  if isDemo() {
    Ok(makeDemoStream())
  } else {
    let url = trimSlash(baseUrl()) ++ "/chat/completions"
    let headers = Dict.fromArray([("Content-Type", "application/json")])
    switch apiKey() {
    | Some(key) => Dict.set(headers, "Authorization", "Bearer " ++ key)
    | None => ()
    }
    let body = {
      "model": model(),
      "stream": true,
      "messages": withSystemPrompt(messages),
    }
    try {
      let response = await WebApi.fetch(
        url,
        {
          method: "POST",
          headers,
          body: JSON.stringifyAny(body)->Option.getOr("{}"),
        },
      )
      if !WebApi.ok(response) {
        let payload = try {
          await WebApi.responseJson(response)
        } catch {
        | _ => JSON.Encode.string(await WebApi.responseText(response))
        }
        Error({
          status: WebApi.status(response),
          message: Message.errorMessage(payload)->Option.getOr("Upstream request failed"),
        })
      } else {
        switch Nullable.toOption(WebApi.responseBody(response)) {
        | None => Error({status: 502, message: "Upstream response had no body"})
        | Some(stream) => Ok(stream)
        }
      }
    } catch {
    | exn =>
      Error({
        status: 502,
        message: switch Error.fromException(exn) {
        | Some(err) => Error.message(err)->Option.getOr("Failed to reach the model provider")
        | None => "Failed to reach the model provider"
        },
      })
    }
  }

let streamHeaders = Dict.fromArray([
  ("Content-Type", "text/event-stream; charset=utf-8"),
  ("Cache-Control", "no-cache, no-transform"),
  ("Connection", "keep-alive"),
  ("X-Accel-Buffering", "no"),
])
