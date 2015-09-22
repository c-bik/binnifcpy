-module(binnifcpy).

-behaviour(application).
-behaviour(supervisor).

%% Application callbacks
-export([start/0, stop/0, start/2, stop/1]).

%% Supervisor callbacks
-export([init/1]).

-export([byte_array/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() -> application:start(?MODULE).
start(_StartType, _StartArgs) ->
    erlang:load_nif(priv_dir() ++ "/binnifcpy", 0),
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

stop() -> application:stop(?MODULE).
stop(_State) ->
    ok.

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    {ok, { {one_for_one, 5, 10}, []} }.

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
