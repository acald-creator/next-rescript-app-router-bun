// Web fetch, streams, and abort — the bindings the chat route and UI actually call.

type readableStream
type abortSignal
type uint8Array
type textDecoder
type textEncoder
type streamController
type reader
type request
type response
type abortController
@new external makeAbortController: unit => abortController = "AbortController"
@get external abortSignal: abortController => abortSignal = "signal"
@send external abort: abortController => unit = "abort"

type fetchInit = {
  method?: string,
  headers?: Dict.t<string>,
  body?: string,
  signal?: abortSignal,
}

@val external fetch: (string, fetchInit) => promise<response> = "fetch"

@get external ok: response => bool = "ok"
@get external status: response => int = "status"
@get external responseBody: response => Nullable.t<readableStream> = "body"
@send external responseJson: response => promise<JSON.t> = "json"
@send external responseText: response => promise<string> = "text"
@send external requestJson: request => promise<JSON.t> = "json"

type responseInit = {
  status?: int,
  headers?: Dict.t<string>,
}

@new external makeResponse: (readableStream, responseInit) => response = "Response"

@scope("Response") @val
external jsonResponse: ('a, responseInit) => response = "json"

@send external getReader: readableStream => reader = "getReader"

type readResult = {
  @as("done") isDone: bool,
  value: Nullable.t<uint8Array>,
}

@send external read: reader => promise<readResult> = "read"

@new external makeTextDecoder: unit => textDecoder = "TextDecoder"
@send external decode: (textDecoder, uint8Array) => string = "decode"

@new external makeTextEncoder: unit => textEncoder = "TextEncoder"
@send external encode: (textEncoder, string) => uint8Array = "encode"

@new
external makeReadableStream: {"start": streamController => unit} => readableStream =
  "ReadableStream"

@send external enqueue: (streamController, uint8Array) => unit = "enqueue"
@send external close: streamController => unit = "close"

@val external setTimeout: (unit => unit, int) => int = "setTimeout"

let wait = (ms: int): promise<unit> =>
  Promise.make((resolve, _reject) => {
    let _id = setTimeout(() => resolve(), ms)
  })

@send
external scrollIntoView: (Dom.element, {"behavior": string, "block": string}) => unit =
  "scrollIntoView"

let scrollToBottom = (el: Dom.element) => scrollIntoView(el, {"behavior": "smooth", "block": "end"})

let isAbortError = (err: Error.t) =>
  switch Error.name(err) {
  | Some("AbortError") => true
  | _ => false
  }
