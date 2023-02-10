%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Feb 2023 9:14 AM
%%%-------------------------------------------------------------------
-module(main_work).
-author("KATCO").
-import(minimaltasks, [task1/0]).
%% API
-export([start/0]).

start() ->
  spawn(fun() -> task1() end).
