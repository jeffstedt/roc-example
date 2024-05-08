# This is ROC Lang, a new multi purpose language that can be used for web development, scripting, and more.
# The syntax is Elm-like. It is a functional language with a strong type system.
# Any autocomplete or syntax highlighting should be based on this file or Elm-like.

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
  completed : Bool
}

Response : {
  data : List Todo
}

main =
    request = {
        method: Get,
        headers: [],
        url: "http://localhost:8000/todos",
        mimeType: "",
        body: [],
        timeout: TimeoutMilliseconds 5000,
    }

    resp = Http.send! request

    output =
        when resp |> Http.handleStringResponse is
            Err err -> crash (Http.errorToString err)
            Ok body -> body

    decoder = Json.utf8With { fieldNameMapping: CamelCase }

    decoded : DecodeResult Response
    decoded = Decode.fromBytesPartial (Str.toUtf8 output) decoder

    when decoded.result is
        Ok { data } -> List.map data .text |> List.map Stdout.line
        Err err -> Task.err (Exit 1 "Error") # @TODO: Fix type mismatch
