-module(animu_bot_dispatcher).

-export([dispatch/3]).
-author("Ricardo Azpeitia Pimentel").

-define(BOT_TOKEN, list_to_binary(os:getenv("BOT_TOKEN"))).
-define(API_URL, <<"https://api.telegram.org/bot", BOT_TOKEN/binary, "/">>).
-define(BOT_COMMAND, <<"bot_command">>).
-define(LOVE_PHARASES, [
    <<"It's not like I love YOOOU or anything, B-baka...">>,
    <<"Senpai yamette">>,
    <<"Onii-chan yamette">>,
    <<"ITS NOT WHAT IT LOOKS LIKE!">>,
    <<"I love you onii-chan">>,
    <<"I love you senpai">>
]).


command(ParsedRequest) ->
    case jsonpath:search(<<"message.text">>, ParsedRequest) of
        Msg when is_list(Msg) ->
            list_to_binary(Msg);
        Msg ->
            Msg
    end.

get_love() ->
    random:seed(os:timestamp()),
    Index = random:uniform(length(?LOVE_PHARASES)),
    lists:nth(Index, ?LOVE_PHARASES).

response(ParsedRequest) ->
    lager:info("Getting commands"),
    Command = command(ParsedRequest),
    lager:info("Command ~p", [Command]),
    response(ParsedRequest, Command).

response(_ParsedRequest, <<"/love">>) ->
    lager:info("Response /love"),
    get_love();
response(_ParsedRequest, <<"/gif ", Text/binary>>) ->
    try
        Url = "https://rightgif.com/search/web",
        RequestPayload = iolist_to_binary(["text=", Text]),
        lager:info("RightGif payload ~p", [RequestPayload]),
        R = httpc:request(post, {Url, [], "application/x-www-form-urlencoded", RequestPayload}, [], []),
        {ok, {{"HTTP/1.1", _ReturnCode, _State}, _Head, Body}} = R,
        lager:info("Response /gif"),
        jsonpath:search(<<"url">>, jiffy:decode(list_to_binary(Body)))
    catch
        Exception:Reason -> 
            lager:error("~p:~p ~p", [Exception, Reason, erlang:get_stacktrace()]),
            <<"aahhh~ onii-chan, tastukete, logs wo mieru">>
    end;
response(_ParsedRequest, <<"/help">>) ->
    lager:info("Response /help"),
    <<"Commands:\n/gif <text> -> show gif\n/love -> saids love phrase\n/help -> show this help">>;
response(_ParsedRequest, <<"/", Commands/binary>>) ->
    lager:info("Response unknown command ~p", [Commands]),
    iolist_to_binary([<<"unknown command ">> | Commands]);
response(_ParsedRequest, Text) ->
    lager:info("Response text ~p", [Text]),
    <<"">>.

dispatch('GET', [<<"bot">>], _Req) ->
    {ok, [], <<"Animu bot v1.0">>};

dispatch(Method, [<<"bot">>, ?BOT_TOKEN], Req)
    when Method == 'GET'; Method == 'POST' ->
    lager:info("Dispatching..."),
    Headers = [{<<"content-type">>, <<"application/json">>}],
    ParsedRequest = jiffy:decode(elli_request:body(Req)),
    lager:info("Generating response..."),
    % lagger:info(eli_request:body(Req)),
    TextResponse = response(ParsedRequest),
    lager:info("Response generated..."),
    ChatId = jsonpath:search(<<"message.chat.id">>, ParsedRequest),
    Response = {[
        {<<"method">>, <<"sendMessage">>},
        {<<"chat_id">>, ChatId},
        {<<"text">>, TextResponse}
    ]},
    lager:info("Encoding response..."),
    RawResponse = jiffy:encode(Response),
    lager:info("Response encoded..."),
    % lagger:info(RawResponse),
    {ok, Headers, RawResponse};

dispatch(_, _, _Req) ->
    {404, [], <<"Not Found">>}.

