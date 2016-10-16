-module(animu_bot_app).

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
    % hackney:start(),
    application:ensure_all_started(lager),
    application:ensure_all_started(ssl),
    application:ensure_all_started(inets),
    Return = application:start(animu_bot),
    io:format(user, "animu_bot_app:start/0 -> All apps started~n", []),
    Return.

start(_StartType, _StartArgs) ->
    Return = animu_bot_sup:start_link(),
    io:format(user, "animu_bot_app:start/2 -> Link started~n", []),
    Return.

stop(_State) ->
    io:format(user, "animu_bot_app:stop/1 -> Stoped~n", []),
    ok.
