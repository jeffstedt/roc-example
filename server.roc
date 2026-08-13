app [Context, program] {
	pf: platform "https://github.com/roc-lang/basic-webserver/releases/download/0.16.0/42jC1JT3auhHSmv2Ah8mW5F2MXiAakq1UQQ4NQceQjXw.tar.zst",
	http: "https://github.com/roc-lang/http/releases/download/1.0.0/6ZUwqYhCS8PU9Mo6MF7oV82ET2o7KYb57CLKDq4cq4sS.tar.zst",
}

import pf.Server
import pf.Stdout
import http.Response

Context : { todos : List(Todo) }
Todo : { id : I64, task : Str, status : TodoStatus }
TodoStatus := [InProgress, Completed].{
	encoder_for : encoding -> (TodoStatus, state -> Try(state, err))
		where [
			encoding.encode_str : Str, state -> Try(state, err),
		]
	encoder_for = |_encoding| {
		Encoding : encoding

		|status, state| Encoding.encode_str(todo_status_to_str(status), state)
	}
}

program = { init!, respond!, shutdown! }

init! : () => Try({ config : Server.Config, context : Context }, [Exit(I64), ..])
init! = ||
	Ok({
		config: Server.default_config.with_listen({ host: "127.0.0.1", port: 8000 }),
		context: {
			todos: [
				{ id: 123, task: "Install Roc", status: Completed },
				{ id: 456, task: "Learn Roc", status: InProgress },
			]
		},
	})

respond! : Server.Request, Context => Try(Server.Outcome, [ServerErr(Str), ..])
respond! = |req, context|
	match handle_req!(req, context) {
		Ok(response) => Ok(Server.respond(response))
		Err(err) => Err(ServerErr(Str.inspect(err)))
	}

handle_req! : Server.Request, Context => Try(Response, _)
handle_req! = |req, context| {
	log_request!(req)?

	match get_path_parts(req) {
		["", "api"] | ["", "api", ""] | ["", "api", "todos"] => Ok(json_response(200, context.todos))
		["", "api", "todos", id_str] => Ok(json_response(200, get_todo_by_id(id_str, context.todos)))
		_ => Ok(text_response(404, "URL Not Found (404)"))
	}
}

log_request! : Server.Request => Try({}, _)
log_request! = |req| {
	Stdout.line!("${Str.inspect(req.method())} #{req.target()}")
		? |err| StdoutErr(Str.inspect(err))
	Ok({})
}

get_path_parts : Server.Request -> List(Str)
get_path_parts = |req|
	match req.target() {
		Resource({ raw_path: path, .. }) => Str.split_on(path, "/")
		_ => []
	}

get_todo_by_id : Str, List(Todo) -> List(Todo)
get_todo_by_id = |id_str, todos|
	match I64.from_str(id_str) {
		Ok(id) => List.keep_if(todos, |todo| todo.id == id)
		Err(_) => []
	}

text_response : U16, Str -> Response
text_response = |status, body|
	Response.from_status(status)
		.with_headers([{ name: "Content-Type", value: "text/plain; charset=utf-8" }])
		.with_body(body |> Str.to_utf8)

json_response : U16, List(Todo) -> Response
json_response = |status, todos|
	Response.from_status(status)
		.with_headers([{ name: "Content-Type", value: "application/json; charset=utf-8" }])
		.with_body(todos |> Json.to_str |> Str.to_utf8)

todo_status_to_str : TodoStatus -> Str
todo_status_to_str = |status|
	match status {
		InProgress => "in-progress"
		Completed => "completed"
	}

shutdown! : Server.ShutdownReason, Context => Try({}, [Exit(I64), ..])
shutdown! = |_reason, _context| Ok({})