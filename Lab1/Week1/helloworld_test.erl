%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Feb 2023 5:59 PM
%%%-------------------------------------------------------------------
-module(helloworld_test).
-author("KATCO").
-import(helloworld,[helloworld/0]).
-include_lib("eunit/include/eunit.hrl").
%% API
-export([]).

helloworld_test() -> helloworld().
