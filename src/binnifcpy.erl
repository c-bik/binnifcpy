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