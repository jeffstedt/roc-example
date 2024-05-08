app [main] {
    ws: platform "https://github.com/roc-lang/basic-webserver/releases/download/0.5.0/Vq-iXfrRf-aHxhJpAh71uoVUlC-rsWvmjzTYOJKhu4M.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.9.0/JI4BuuOuWnD1R3Xcx-F8VrWdj-LM_FfDRB00ekYjIIQ.tar.br",
}

import ws.Task
import json.Json

respond = \status, headers, json ->
    Task.ok {
        status,
        headers,
        body: Encode.toBytes json Json.utf8,
    }

main = \request ->
    when request.url is
        "/todos" ->
            respond 200 [] { data: [{ id: 123, text: "Test1", completed: False }] }

        _ ->
            respond 404 [] { data: "not found" }
