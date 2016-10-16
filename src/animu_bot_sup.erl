-module(animu_bot_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    io:format(user, "animu_bot_sup:start_link/0~n", []),
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    io:format(user, "animu_bot_sup:init/1~n", []),
    ElliOpts = [{callback, animu_bot_callback}, {port, 3000}, {name, {local, elli}}],
    ElliSpec = {
        webserver,
        {elli, start_link, [ElliOpts]},
        permanent,
        5000,
        worker,
        [elli]},

    {ok, { {one_for_one, 0, 1}, [ElliSpec]} }.

