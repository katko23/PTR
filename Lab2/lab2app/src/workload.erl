%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Mar 2023 9:40 AM
%%%-------------------------------------------------------------------
-module(workload).
-author("KATCO").

%% API
-export([start/0]).

start() ->
  Pid = spawn(
    fun () ->
      loop(0, 2, 10)
    end),
  register(wkl, Pid),
  {ok, Pid}.

loop(N, Min, Max) ->
  case (N >= 10 andalso N < Max) of
   true -> print_supervisor:add_new_child(),
    loop(0, Min, Max)
  ;
    false ->
     case (N < -50 andalso N > Min) of
       true -> print_supervisor:remove_one_child(),
          loop(0, Min, Max);
       false -> ok
      end
    end,
%%  io:format("My workflow is ~p~n", [N]),
  receive
    {add} ->
      loop(N + 1, Min, Max);
    {substr} ->
      loop(N - 1, Min, Max);
    {Self, get} ->
      Self ! {workload, N},
      loop(N, Min, Max)
  end
.