-module(binnifcpy).
-export([byte_array/1]).

-on_load(init/0).

init() ->
    erlang:load_nif(priv_dir() ++ "/binnifcpy", 0).

byte_array(_X) ->
    exit(nif_library_not_loaded).

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

basic_test() ->
    List = lists:duplicate(1024 * 1024 * 5, 0),
    BinZero = list_to_binary(List),
    TestBin = << <<(rand:uniform(255))>> || _ <- List>>,
    ?assertNotEqual(BinZero, TestBin),
    ?assertEqual(BinZero, byte_array(TestBin)),
    ?assertEqual(BinZero, TestBin).

-endif.