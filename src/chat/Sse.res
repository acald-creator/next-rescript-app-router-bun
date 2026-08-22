type event = Delta(string) | Done | Ignore

let splitLines = (buffer: string): (string, array<string>) => {
  let parts = String.split(buffer, "\n")
  let lastIndex = Array.length(parts) - 1
  let rest = parts->Array.get(lastIndex)->Option.getOr("")
  let complete = Array.slice(parts, ~start=0, ~end=lastIndex)
  (rest, complete)
}

let parseLine = (line: string): event => {
  let trimmed = String.trim(line)
  if trimmed === "" || String.startsWith(trimmed, ":") {
    Ignore
  } else if String.startsWith(trimmed, "data:") {
    let data = String.trim(String.sliceToEnd(trimmed, ~start=5))
    if data === "[DONE]" {
      Done
    } else {
      switch Message.deltaFromChunk(data) {
      | Some(text) if text !== "" => Delta(text)
      | _ => Ignore
      }
    }
  } else {
    Ignore
  }
}

let consume = (stream: WebApi.readableStream, ~onDelta: string => unit): promise<unit> => {
  let reader = WebApi.getReader(stream)
  let decoder = WebApi.makeTextDecoder()

  let rec loop = (buffer: string): promise<unit> =>
    WebApi.read(reader)->Promise.then(result =>
      if result.isDone {
        Promise.resolve()
      } else {
        let next = switch Nullable.toOption(result.value) {
        | None => buffer
        | Some(bytes) => buffer ++ WebApi.decode(decoder, bytes)
        }
        let (rest, lines) = splitLines(next)
        let rec walk = (index, finished) =>
          if finished || index >= Array.length(lines) {
            finished
          } else {
            switch parseLine(lines->Array.get(index)->Option.getOr("")) {
            | Done => true
            | Delta(text) =>
              onDelta(text)
              walk(index + 1, false)
            | Ignore => walk(index + 1, false)
            }
          }
        if walk(0, false) {
          Promise.resolve()
        } else {
          loop(rest)
        }
      }
    )

  loop("")
}
