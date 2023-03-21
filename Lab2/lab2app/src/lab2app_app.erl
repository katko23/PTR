%%%-------------------------------------------------------------------
%% @doc lab2app public API
%% @end
%%%-------------------------------------------------------------------

-module(lab2app_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    lab2app_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
