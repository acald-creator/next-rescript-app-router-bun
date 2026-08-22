let dynamic = "force-dynamic"
let maxDuration = 60

let errorResponse = (message: string, ~status: int) =>
  WebApi.jsonResponse({"error": message}, {status: status})

let \"GET" = async (_request: WebApi.request) => WebApi.jsonResponse(OpenAI.publicConfig(), {status: 200})

let \"POST" = async (request: WebApi.request) => {
  let json = try {
    await WebApi.requestJson(request)
  } catch {
  | _ => JSON.Encode.object(Dict.fromArray([]))
  }

  switch Message.decodeRequest(json) {
  | Error(message) => errorResponse(message, ~status=400)
  | Ok(messages) =>
    switch await OpenAI.complete(messages) {
    | Error(err) => errorResponse(err.message, ~status=err.status)
    | Ok(stream) => WebApi.makeResponse(stream, {status: 200, headers: OpenAI.streamHeaders})
    }
  }
}
