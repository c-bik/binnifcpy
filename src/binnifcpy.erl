-module(binnifcpy).
-export([clear_bin/1, get_self/0, async/0, clear_bin_async/1]).

-on_load(init/0).

init() ->
    erlang:load_nif(priv_dir() ++ "/binnifcpy", 0).

-define(NOT_LOADED,
    erlang:nif_error({not_loaded, [{module, ?MODULE}, {line, ?LINE}]})
).

clear_bin(_X) -> ?NOT_LOADED.
clear_bin_async(_X) -> ?NOT_LOADED.
get_self() -> ?NOT_LOADED.
async() -> ?NOT_LOADED.

priv_dir() ->
    case code:priv_dir(?MODULE) of
        {error, bad_name} ->
            filename:join(
              filename:dirname(
                filename:dirname(
                  code:which(?MODULE))), "priv");
        D -> D
    end.

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

self_test() ->
    ?assertEqual(self(), get_self()).

bin_test() ->
    List = lists:duplicate(5 * 1024 * 1024, 0),
    BinZero = list_to_binary(List),
    TestBin = << <<(rand:uniform(255))>> || _ <- List>>,
    ?assertNotEqual(BinZero, TestBin),
    ?assertEqual(BinZero, clear_bin(TestBin)),
    ?assertEqual(BinZero, TestBin).

async_test()->
    T = os:timestamp(),
    async(),
    receive
        Term ->
            Took = timer:now_diff(os:timestamp(), T),
            ?assert(Took > 0),
            ?assert(Took < 4 * 1000 * 1000),
            ?assertEqual(from_async_process, Term)
    after 5000 ->
        throw(no_message_received)
    end.

async_bin_test()->
    List = lists:duplicate(5 * 1024 * 1024, 0),
    BinZero = list_to_binary(List),
    TestBin = << <<(rand:uniform(255))>> || _ <- List>>,
    T = os:timestamp(),
    ?assertNotEqual(BinZero, TestBin),
    clear_bin_async(TestBin),
    receive
        Term ->
            Took = timer:now_diff(os:timestamp(), T),
            ?assert(Took > 0),
            ?assert(Took < 3 * 1000 * 1000),
            ?assertEqual(from_clear_bin_async_process, Term),
            ?assertEqual(BinZero, TestBin)
    after 5000 ->
        throw(no_message_received)
    end.

-endif.