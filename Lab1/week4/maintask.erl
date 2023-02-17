%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Feb 2023 6:00 PM
%%%-------------------------------------------------------------------
-module(maintask).
-author("KATCO").

%% API
-export([create_function/0, splitbyspace/1]).

splitbyspace(I) ->
  if I == 0 ->
    Changepid = spawn(fun() -> changenm(0) end),
    io:fwrite("Pid of changenm is ~p ~n", [Changepid]),
    link(Changepid);
    true ->
      Changepid = I
  end,
  receive
    {String} ->
      Changepid ! {splited,string:tokens(String, [$\s])},
      splitbyspace(Changepid)
end.

changenm(I) ->
  if I == 0 ->
    Printpid = spawn(fun() -> print() end),
    io:fwrite("Pid of print is ~p ~n", [Printpid]),
    link(Printpid);
    true ->
      Printpid = I
  end,
  receive
    {splited, ListString} ->
      String = lists:flatten(lists:map(fun(El) -> El ++ " " end,ListString)),
      Liststr = string:replace(string:to_lower(String),"m","n", all),
      Ans = lists:flatten(lists:map(fun(El) -> if length(El) > 1 ->lists:flatten(string:replace(El,"n","m", all)); true -> El end end, Liststr)),
      Printpid ! {changed,Ans},
      changenm(Printpid)
  end
.

print() ->
  receive
    {changed, Ans} ->
      io:fwrite("Changed String is -> ~p ~n", [Ans]),
      print()
  end.

create_function() ->
  {PID,_Ref} = spawn_monitor(?MODULE,splitbyspace, [0]),
  io:fwrite("Pid of splitbyspace is ~p ~n", [PID]),
  supervisor_functions(PID).

supervisor_functions(PID) ->
  receive
    {'DOWN', _Ref, process, Pid, Why} ->
      io:format("Worker ~w went down: ~s~n", [Pid, Why]),
      {PIDN,_Refer} = spawn_monitor(?MODULE,splitbyspace, [0]),
      io:fwrite("Pid of splitbyspace is ~p ~n", [PID]),
      supervisor_functions(PIDN);
    String ->
      PID ! {String},
      supervisor_functions(PID)
  end.