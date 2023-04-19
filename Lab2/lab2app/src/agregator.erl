%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Mar 2023 10:46 PM
%%%-------------------------------------------------------------------
-module(agregator).
-author("KATCO").

%% API
-export([start/1]).

start(Amount) ->
  Pid = spawn(
    fun () ->
      loop([],[],[],[],Amount * 3)
    end),
  io:fwrite("My Agregator PID is ~p~n",[Pid]),
  register(agreg, Pid),
  {ok, Pid}.

loop(Print, Emo, Eng, Ans, Amount) ->
  case length(Ans) >= Amount of
    true ->
      batcher ! {agregatorprint, Ans},
      loop(Print, Emo, Eng, [], Amount);
    false ->
      pass
  end,
%%  io:format("Print List is - ~p~n", [Print]),
%%  io:format("Sent List is - ~p~n", [Emo]),
%%  io:format("Enga List is - ~p~n", [Eng]),
%%  io:format("Answers List is - ~p~n", [Ans]),

  lists:foreach(fun([HP|TP]) ->
    lists:foreach(fun([HS|TS]) ->
      lists:foreach(fun([HE|TE]) ->
        case checkList(HP,HS,HE) of
          true ->
            Id = HP,
            loop(
              delete(HP, Print),
              delete(HS, Emo),
              delete(HE, Eng),
              lists:append(Ans, [[TP, TS, TE, Id]]), Amount);
          false ->
            pass
        end
                    end,Eng)
                  end,Emo)
                end,Print),

  receive
    {print, Id, Mess, UserId} ->
      NewList = lists:append(Print, [[Id, Mess, UserId]]),
      loop(NewList, Emo, Eng, Ans, Amount)
  ;
    {emotion, Id, Mess} ->
      NewList = lists:append(Emo, [[Id,Mess]]),
      loop(Print, NewList, Eng, Ans, Amount)
  ;
    {engagement, Id, Mess} ->
      NewList = lists:append(Eng, [[Id,Mess]]),
      loop(Print, Emo, NewList, Ans, Amount)
  ;
    {give} ->
      batcher ! {agregatorprint, Ans},
      loop(Print, Emo, Eng, [], Amount)
  ;
    stop ->
      io:format("Stopping Agregator actor~n")
  end
.


checkList(HP, HS, HE) ->
  HP =:= HS andalso HS =:= HE
  .

delete(_, []) ->
  [];  % base case: empty list, return empty list
delete(Id, [[Id|_]|T]) ->
  delete(Id, T);  % skip sublists whose first element is Id
delete(Id, [H|T]) ->
  [H | delete(Id, T)].  % keep sublists whose first element is not Id