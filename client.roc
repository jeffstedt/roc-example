app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.11.0/SY4WWMhWQ9NvQgvIthcv15AUeA7rAIJHAHgiaSHGhdY.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.9.0/JI4BuuOuWnD1R3Xcx-F8VrWdj-LM_FfDRB00ekYjIIQ.tar.br",
}

import cli.Stdout
import cli.Http exposing []
import cli.Task exposing [Task]
import Decode exposing [fromBytesPartial]

import json.Json

Todo : {
    id : I64,
    text : Str,
    completed : Bool,
}

Response : {
    data : List Todo,
}

main =
    request = Http.send! {
        method: Get,
        headers: [],
        url: "http://localhost:8000/todos",
        mimeType: "",
        body: [],
        timeout: TimeoutMilliseconds 5000,
    }

    output =
        when request |> Http.handleStringResponse is
            Err err -> Http.errorToString! err
            Ok body -> body

    decoder = Json.utf8With { fieldNameMapping: CamelCase }

    response : DecodeResult Response
    response = fromBytesPartial (Str.toUtf8 output) decoder

    toString : Todo -> { id : Str, text : Str, completed : Str }
    toString = \todo -> {
        id: Num.toStr todo.id,
        text: todo.text,
        completed: if todo.completed then "true" else "false",
    }

    when response.result is
        Ok { data } ->
            List.map data toString
                |> List.map (\{ id, text, completed } -> "id: $(id), text: $(text), completed: $(completed)")
                |> Str.joinWith "\n"
                |> Stdout.line!

        Err _err -> Stdout.write! "Err, could not decode response"
