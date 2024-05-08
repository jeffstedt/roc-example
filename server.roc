# This is ROC Lang, a new multi purpose language that can be used for web development, scripting, and more.
# The syntax is Elm-like. It is a functional language with a strong type system.
# Any autocomplete or syntax highlighting should be based on this file or Elm-like.

app [main] {
  ws: platform "https://github.com/roc-lang/basic-webserver/releases/download/0.5.0/Vq-iXfrRf-aHxhJpAh71uoVUlC-rsWvmjzTYOJKhu4M.tar.br",
  json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.9.0/JI4BuuOuWnD1R3Xcx-F8VrWdj-LM_FfDRB00ekYjIIQ.tar.br",
}

import ws.Task
import json.Json

# print =
#   Str.toUtf8

respond = \status, headers, json ->
  Task.ok {
    status,
    headers,
    body: Encode.toBytes json Json.utf8,
  }

main = \request ->
  when request.url is
    "/todos" ->
      respond 200 [] { data: [ { id: 123, text: "Test1", completed: False }] }
    _ ->
      respond 404 [] { data: "not found"}