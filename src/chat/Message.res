type role = [#system | #user | #assistant]

type t = {
  role: role,
  content: string,
}

type uiMessage = {
  id: string,
  role: role,
  content: string,
}

let toApi = (message: uiMessage): t => {
  role: message.role,
  content: message.content,
}

let decodeRole = (json: JSON.t): option<role> =>
  switch JSON.Decode.string(json) {
  | Some("system") => Some(#system)
  | Some("user") => Some(#user)
  | Some("assistant") => Some(#assistant)
  | _ => None
  }

let decode = (json: JSON.t): option<t> =>
  switch JSON.Decode.object(json) {
  | None => None
  | Some(dict) =>
    switch (Dict.get(dict, "role"), Dict.get(dict, "content")) {
    | (Some(roleJson), Some(contentJson)) =>
      switch (decodeRole(roleJson), JSON.Decode.string(contentJson)) {
      | (Some(role), Some(content)) => Some({role, content})
      | _ => None
      }
    | _ => None
    }
  }

let decodeRequest = (json: JSON.t): result<array<t>, string> =>
  switch JSON.Decode.object(json) {
  | None => Error("Expected a JSON object with a messages array")
  | Some(dict) =>
    switch Dict.get(dict, "messages") {
    | None => Error("Missing messages")
    | Some(messagesJson) =>
      switch JSON.Decode.array(messagesJson) {
      | None => Error("messages must be an array")
      | Some(items) =>
        let count = Array.length(items)
        if count === 0 {
          Error("messages must not be empty")
        } else if count > 50 {
          Error("Too many messages (max 50)")
        } else {
          items->Array.reduce(Ok([]), (acc, item) =>
            switch acc {
            | Error(message) => Error(message)
            | Ok(messages) =>
              switch decode(item) {
              | None => Error("Each message needs a role and content string")
              | Some(message) =>
                if String.length(message.content) > 32000 {
                  Error("Message content is too long")
                } else {
                  Ok(Array.concat(messages, [message]))
                }
              }
            }
          )
        }
      }
    }
  }

let errorMessage = (json: JSON.t): option<string> =>
  switch JSON.Decode.object(json) {
  | None => JSON.Decode.string(json)
  | Some(root) =>
    switch Dict.get(root, "error") {
    | Some(errorJson) =>
      switch JSON.Decode.object(errorJson) {
      | Some(errorDict) =>
        switch Dict.get(errorDict, "message") {
        | Some(messageJson) => JSON.Decode.string(messageJson)
        | None => None
        }
      | None => JSON.Decode.string(errorJson)
      }
    | None =>
      switch Dict.get(root, "message") {
      | Some(messageJson) => JSON.Decode.string(messageJson)
      | None => None
      }
    }
  }

let deltaFromChunk = (raw: string): option<string> =>
  try {
    let json = JSON.parseExn(raw)
    switch JSON.Decode.object(json) {
    | None => None
    | Some(root) =>
      switch Dict.get(root, "choices") {
      | Some(choicesJson) =>
        switch JSON.Decode.array(choicesJson) {
        | Some(choices) =>
          switch Array.get(choices, 0) {
          | Some(choiceJson) =>
            switch JSON.Decode.object(choiceJson) {
            | Some(choice) =>
              switch Dict.get(choice, "delta") {
              | Some(deltaJson) =>
                switch JSON.Decode.object(deltaJson) {
                | Some(delta) =>
                  switch Dict.get(delta, "content") {
                  | Some(contentJson) => JSON.Decode.string(contentJson)
                  | None => None
                  }
                | None => None
                }
              | None => None
              }
            | None => None
            }
          | None => None
          }
        | None => None
        }
      | None => None
      }
    }
  } catch {
  | _ => None
  }
