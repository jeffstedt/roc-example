app [main] {
    ws: platform "https://github.com/roc-lang/basic-webserver/releases/download/0.5.0/Vq-iXfrRf-aHxhJpAh71uoVUlC-rsWvmjzTYOJKhu4M.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.9.0/JI4BuuOuWnD1R3Xcx-F8VrWdj-LM_FfDRB00ekYjIIQ.tar.br",
}

import ws.Task
import json.Json

Todo : {
    id : I64,
    text : Str,
    completed : Bool,
}

respondWithJson = \status, headers, body ->
    Task.ok {
        status,
        headers,
        body: Encode.toBytes { data: body } Json.utf8,
    }

main = \request ->

    init : List Todo
    init = [
        { id: 111, text: "Learn Roc", completed: Bool.false },
        { id: 222, text: "Go outside", completed: Bool.false },
    ]

    when request.url is
        # Todo: Create route for getting a specific todo
        "/todos" ->
            respondWithJson 200 [] init

        _ ->
            respondWithJson 404 [] "404 not found"
