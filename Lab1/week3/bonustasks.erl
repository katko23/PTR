%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Feb 2023 1:52 AM
%%%-------------------------------------------------------------------
-module(bonustasks).
-author("KATCO").

%% API
-export([createscheduler/0, loop/0, create_dlllist/1, traverse/1, inverse/1]).

createscheduler() ->
  spawn(?MODULE, loop, []).

worker() ->
  receive
    {FROM, do_work}->
    Randint = rand:uniform(2),
%%    io:format("Rand int ~p ~n",[Randint]),
  if Randint == 1 ->
%%    io:format("Rand int ~p ~n",[Randint]),
    FROM ! {self(), error},
    worker();
    true -> FROM ! succesful
  end
  end
  .

loop() ->
  receive
    {PID, error} ->
      io:format("Task fail ~n"),
      PID ! {self(), do_work},
      loop();
    succesful ->
      io:format("Task succesful : Miau ~n"),
      loop();
    stop ->
      io:format("I end the process ~n");
    _ ->
%%      io:format("PID of loop ~p ~n",[self()]),
      NewWorker = spawn(fun() -> worker() end ),
      NewWorker ! {self(), do_work},
      loop()
  end
.

%% c(bonustasks).
%% Scheduler = bonustasks:createscheduler().
%% Scheduler ! "Hello".

create_dlllist([H|T]) ->
  PID = spawn(fun() -> nodedll(nil,H,nil) end),
  create_dlllist(T,PID),
  PID
.

insert(PID, Value) ->
  NewPid = spawn(fun() -> nodedll(PID, Value ,nil) end),
  PID ! {insnext, NewPid},
  NewPid
.

create_dlllist([],_)->ok;
create_dlllist([H|T],Pred) ->
  NewPid = insert(Pred,H),
  create_dlllist(T, NewPid)
.

traverse(PID) ->
  PID ! {traverse,self(),[]},
  receive
    {traversed,Arr} -> Arr
  end
  .

inverse(PID) ->
  PID ! {inverse,self(),[]},
  receive
    {inversed,Arr} -> Arr
  end
.

nodedll(Pred , Value , Next) ->
  receive
    {insnext, NextPid} ->
      nodedll(Pred, Value, NextPid);
    {delpred, PredPid} ->
      nodedll(PredPid, Value, Next);
    {traverse,From,Arr} ->
      if
        Next == nil -> From ! {traversed, Arr++[Value]}, nodedll(Pred, Value, Next);
        true -> Next ! {traverse,From,Arr++[Value]}, nodedll(Pred, Value, Next)
      end;
    {inverse,From,Arr} ->
      if
        Next == nil -> From ! {inversed, [Value] ++ Arr}, nodedll(Pred, Value, Next);
        true -> Next ! {inverse,From,[Value] ++ Arr}, nodedll(Pred, Value, Next)
      end
  end
  .


%% c(bonustasks).
%% PID = bonustasks:create_dlllist([3 , 4 , 5 , 42]).
%% bonustasks:traverse(PID).
%% bonustasks:inverse(PID).