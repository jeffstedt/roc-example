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

    dbg request.url

    if request.url == "/todos" then
        respondWithJson 200 [] init
    else if Str.contains request.url "/todos" then
        todoById = Str.splitLast request.url "/"

        when todoById is
            Ok { after } ->
                findTodoById = \{ id } ->
                    inputId =
                        when Str.toI64 after is
                            Ok num -> num
                            Err _ -> 0
                    id == inputId

                searchTodo = List.findFirst init findTodoById
                when searchTodo is
                    Ok todo -> respondWithJson 200 [] [todo]
                    Err _ -> respondWithJson 404 [] "Not found"

            Err _ ->
                respondWithJson 404 [] init
    else
        respondWithJson 404 [] "Not found"
