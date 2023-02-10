%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Feb 2023 8:58 AM
%%%-------------------------------------------------------------------
-module(minimaltasks).
-author("KATCO").
%% API
-export([task1/0, task2/0, task3/0, task4/1]).
%%-compile(export_all).

task1() ->
  receive
    C when C =/= {stop}->
      io:format("Received ~p ~n", [C]),
      task1();
    {stop} ->
      io:format("Stopping~n")
  end.

task2() ->
  receive
    C when (C =/= {stop}) and (is_integer(C))->
      io:format("Received ~w ~n", [C+1]),
      task2();
    C when (C =/= {stop}) ->
      case is_string(C) of
        true ->
          io:format("Received string ~p ~n", [string:to_lower(C)]),
          task2();
        false ->
          io:format("Received : I don’t know how to HANDLE this ! ~n")
      end;
    {stop} ->
      io:format("Stopping~n")
  end.

is_string([C|T]) when (C >= 0) and (C =< 255) ->
  is_string(T);
is_string([]) ->
  true;
is_string(_) ->
  false.

task3() ->
  spawn(fun() -> monitor(spawn(fun() -> actor2() end)) end).

monitor(Pid) ->
  Reference = erlang:monitor(process, Pid),
  receive
    {'DOWN', Reference, process, Pid, _} ->
      io:format("Actor 2 has stopped~n");
    _ ->
      monitor(Pid)
  end.

actor2() ->
  io:fwrite("PID of actor is ~p ~n", [self()]),
  receive
    stop ->
      io:format("Stopping actor 2~n"),
      exit(normal);
    N ->
      io:format("~p ~n", [N]),
      actor2()
  end.

task4(Number) -> task4(Number,1).
task4(Sum,Count) ->
  receive
    stop ->
      io:format("Stopping task4~n"),
      exit(normal);
    N ->
      NewSum = Sum + N,
      NewCount = Count + 1,
      io:format("Average : ~p ~n", [NewSum / NewCount]),
      task4(NewSum, NewCount)
  end.

