%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Feb 2023 1:03 AM
%%%-------------------------------------------------------------------
-module(maintask).
-author("KATCO").

%% API
-export([new_queue/0, push/2, pop/1, queueptr/1]).

new_queue() ->
  spawn(?MODULE, queueptr, [[]]).

queueptr(Arr) ->
  receive
    {From, {push, Value}} ->
      From ! {self(), ok},
      queueptr(lists:append(Arr,[Value]));
    {From, {pop}} ->
      From ! {self(), lists:last(Arr)},
      queueptr(lists:droplast(Arr));
    terminate ->
      ok
  end.

push(Pid, Value) ->
  Pid ! {self(), {push, Value}},
  receive
    {Pid, Msg} -> Msg
  end.

pop(Pid) ->
  Pid ! {self(), {pop}},
  receive
    {Pid, Msg} -> Msg
  end.
