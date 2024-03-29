%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Mar 2023 10:32 PM
%%%-------------------------------------------------------------------
-module(round_robin).
-author("KATCO").

-export([start/1, stop/0]).

start(Name) ->
%%  {Pid, _} = spawn_link(fun() -> loop() end),
  {Pid, _} = spawn_monitor(
    fun () ->
      loop(1,1)
    end),
  register(Name, Pid),
  {ok, Pid}.

loop(N, I) ->
  if
    I > N -> Index = 1 ;
    true -> Index = I
  end,
  receive
    {PrintersNumb, getNext, Self} ->
        Self ! {Index},
  loop(PrintersNumb, Index+1);
    stop ->
      ok
  end.

stop() ->
  rr ! stop.