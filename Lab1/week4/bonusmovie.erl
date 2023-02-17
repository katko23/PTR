%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Feb 2023 12:13 AM
%%%-------------------------------------------------------------------
-module(bonusmovie).
-author("KATCO").

%% API
-export([jules/2, scene/0, brett/0]).

scene() ->
  {BretPID, _} = spawn_monitor(?MODULE, brett, []),
  {JulesPID, _} = spawn_monitor(?MODULE, jules, [BretPID,["What does Marsellus Wallace look like?",
    "What country are you from?","'What' ain't no country I've ever heard of. They speak English in What?",
  "English, motherfucker, do you speak it?", "Then you know what I'm sayin'!",
    "Describe what Marsellus Wallace looks like!",
    "Say 'what' again. Say 'what' again, I dare you, I double dare you motherfucker, say what one more Goddamn time!",
    "Go on!","Does he look like a bitch?"]]),
  receive
    {'DOWN', _Ref, process, Pid, Why} ->
      case Pid == BretPID of
        true ->
          io:fwrite("Process brett is down cause it's ~p~n", [Why]);
        false -> ok
      end,
      case Pid == JulesPID of
        true ->
          io:fwrite("Process Jules is down cause it's ~p~n", [Why]);
        false -> ok
      end;
    _Other -> scene()
  end.

jules() -> jules().
jules(BretPID, []) -> exit(BretPID, {"Shooted in shoulder by Jules"}), jules();
jules(BretPID,[H|T]) ->
  BretPID ! {self(),H},
  receive
    Bret ->
      timer:sleep(200),
      io:fwrite("Brett: ~p~n",[Bret]),
      jules(BretPID, T)
  end.

brett() ->
  receive
    {From,String} ->
      case String of
        "What does Marsellus Wallace look like?" ->
          timer:sleep(200),
          io:fwrite("Jules: ~p~n",[String]),
          From ! "What?",
          brett();
        "What country are you from?" ->
          timer:sleep(200),
          io:fwrite("Jules: ~p~n",[String]),
          From ! "What?What?Wh - ?",
          brett();
        "'What' ain't no country I've ever heard of. They speak English in What?" ->
          timer:sleep(200),
          io:fwrite("Jules: ~p~n",[String]),
          From ! "What?",
          brett();
        "English, motherfucker, do you speak it?" ->
          timer:sleep(200),
          io:fwrite("Jules: ~p~n",[String]),
          From ! "Yes!Yes!",
          brett();
        "Then you know what I'm sayin'!" ->
          timer:sleep(200),
          io:fwrite("Jules: ~p~n",[String]),
          From ! "Yes!",
          brett();
        "Describe what Marsellus Wallace looks like!" ->
          timer:sleep(200),
          io:fwrite("Jules: ~p~n",[String]),
          From ! "What?",
          brett();
        "Say 'what' again. Say 'what' again, I dare you, I double dare you motherfucker, say what one more Goddamn time!" ->
          timer:sleep(200),
          io:fwrite("Jules: ~p~n",[String]),
          From ! "H-H-He's black...",
          brett();
        "Go on!" ->
          timer:sleep(200),
          io:fwrite("Jules: ~p~n",[String]),
          From ! "He's bald...!",
          brett();
        "Does he look like a bitch?" ->
          timer:sleep(200),
          io:fwrite("Jules: ~p~n",[String]),
          From ! "What?",
          brett()
      end
  end.