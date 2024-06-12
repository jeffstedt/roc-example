app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.11.0/SY4WWMhWQ9NvQgvIthcv15AUeA7rAIJHAHgiaSHGhdY.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.9.0/JI4BuuOuWnD1R3Xcx-F8VrWdj-LM_FfDRB00ekYjIIQ.tar.br",
}

import cli.Stdout
import cli.Stdin
import cli.Http
import cli.Task
import json.Json

Todo : {
    id : I64,
    text : Str,
    completed : Bool,
}

Data : [
    NotFound Str,
    Todos (List Todo),
]

Response : {
    data : Data,
}

main =

    Stdout.line! "Enter todo id to get a specific todo, or press enter to get all todos 👇"
    input = Stdin.line!
    url = if input == "" then "http://localhost:8000/todos" else "http://localhost:8000/todos/$(input)"

    request = Http.send! {
        method: Get,
        headers: [],
        url: url,
        mimeType: "",
        # body: Str.toUtf8 "111",
        body: [],
        timeout: TimeoutMilliseconds 5000,
    }

    output =
        when request |> Http.handleStringResponse is
            Err err -> Http.errorToString! err
            Ok body -> body

    decoder = Json.utf8With { fieldNameMapping: CamelCase }

    response : DecodeResult Response
    response = Decode.fromBytesPartial (Str.toUtf8 output) decoder

    toString : Todo -> { id : Str, text : Str, completed : Str }
    toString = \todo -> {
        id: Num.toStr todo.id,
        text: todo.text,
        completed: if todo.completed then "true" else "false",
    }

    result : Data -> Str
    result = \data ->
        when data is
            NotFound msg ->
                msg

            Todos todos ->
                List.map todos toString
                |> List.map (\{ id, text, completed } -> "id: $(id), text: $(text), completed: $(completed)")
                |> Str.joinWith
                    "\n"

    when response.result is
        Ok record ->
            Stdout.line! (result record.data)

        Err _err -> Stdout.write! "Err, could not decode response"
