%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Feb 2023 4:16 PM
%%%-------------------------------------------------------------------
-module(minimaltasks).
-author("KATCO").

%% API
-export([start/0, create_workers/1, worker/1]).


worker(Id) ->
  receive
    Anything ->
      io:fwrite("Worker ~w has received ~w ~n ", [Id, Anything]),
    worker(Id)
  end,
  worker(Id).

create_workers(N) ->
  Workers = [  % { {Pid, Ref}, Id }
    { spawn_monitor(?MODULE, worker, [Id]), Id }
    || Id <- lists:seq(1,N)
  ],
  io:format("Workers : ~n~p~n", [Workers]),
  monitor_workers(Workers).

monitor_workers(Workers) ->
  receive
    {'DOWN', Ref, process, Pid, Why} ->
      CrashedWorker = {Pid, Ref},
      NewWorkers = replace(CrashedWorker, Workers, Why),
      io:format("Old Workers:~n~p~n", [Workers]),
      io:format("New Workers:~n~p~n", [NewWorkers]),
      monitor_workers(NewWorkers);
    _Other ->
%%      lists:foreach(fun({{Pid,_Ref},Id}) -> register(pid++Id,Pid) end, Workers),
      monitor_workers(Workers)
  end.

replace(CrashedWorker, Workers, Why) ->
  lists:map(fun(PidRefId) ->
    { {Pid,_Ref}=Worker, Id} = PidRefId,
    case Worker =:= CrashedWorker of
      true ->  %replace worker
        io:format("Worker ~w (~w) went down: ~s~n",
          [Id, Pid, Why]),
        {spawn_monitor(?MODULE, worker, [Id]), Id}; %=> { {Pid,Ref}, Id }
      false ->  %leave worker alone
        PidRefId
    end
            end,
    Workers).

start() ->
  observer:start(),  %%In the Processes tab, you can right click on a worker and kill it.
  create_workers(4).

%% c(minimaltasks).
%% PIDCM = spawn(minimaltasks, create_workers, [4]).
%% PID1 = <0.89.0>, PID2 = <0.90.0>, PID3 = <0.91.0>, PID4 = <0.92.0>.
%% exit(PID3, shutdown).
