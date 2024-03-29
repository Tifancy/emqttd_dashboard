-module(emqttd_dashboard_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    {ok, Sup} = emqttd_dashboard_sup:start_link(),
    {ok, _ChiId} = supervisor:start_child(Sup, worker_spec(emqttd_dashboard_users)),
    {ok, Listener} = application:get_env(emqttd_dashboard, listener),
    open_listener(Listener),
    {ok, Sup}.

stop(_State) ->
    ok.

%% open http port
open_listener({_Http, Port, Options}) ->
    MFArgs = {emqttd_dashboard, handle_request, []},
	mochiweb:start_http(Port, Options, MFArgs).

close_listener(Port) ->
    mochiweb:stop_http(Port).

worker_spec(Name) ->
    {Name,
        {Name, start_link, []},
            permanent, 10000, worker, [Name]}.

