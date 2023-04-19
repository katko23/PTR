%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. Mar 2023 11:53 PM
%%%-------------------------------------------------------------------
-module(batcher).
-author("KATCO").

-export([start/2]).

start(Time, Amount) ->
  Pid = spawn(
    fun () ->
      loop(Time, Amount, [], 0)
    end),
%%  send_data_to_mysql:send("Catalin"),
  io:fwrite("My Batcher PID is ~p~n",[Pid]),
  register(batcher, Pid),
  {ok, Pid}.

loop(Time, Amount, List, Time_nr) ->
  receive
    {agregatorprint, Mess} ->
      io:format("~n================ ~n Batch : ~n ==================~n"),
      lists:foreach(fun(Elemt) ->
                        send_data_to_mysql:send_tweets(Elemt)
%%                      event_print(Elemt),
%%                      io:format("~n================ ~n Element : ~n ==================~n")
                    end, Mess),
      timerbatch:send_time(self(), Time, Time_nr + 1),
    loop(Time, Amount, List, Time_nr + 1)
      ;
    {print, Mess} ->
      case List == [] of
        true ->
          timerbatch:send_time(self(), Time, Time_nr);
        false ->
          ok
      end,
      NewList = lists:append(List, [Mess]),
%%      io:format("Lenghth ~p~n", [length(NewList)]),
%%      io:format("Amount ~p~n", [Amount]),
      case length(NewList)==Amount of
        true ->
%%          io:format("~n================ ~n Batch : ~n ==================~n"),
%%          event_print(NewList),
          if Time_nr == 999 ->
            timerbatch:send_time(self(), Time, 0),
            loop(Time, Amount, [], 0);
          true ->
            timerbatch:send_time(self(), Time, Time_nr + 1),
            loop(Time, Amount, [], Time_nr+1)
          end;
        false ->
          if Time_nr == 999 ->
            loop(Time, Amount, NewList, 0);
          true ->
            loop(Time, Amount, NewList, Time_nr+1)
          end
      end;
    {timesup, N} ->
      io:format("Time ~p ~p ~n", [N, Time_nr]),
      agreg ! {give},
      case N == Time_nr of
        true ->
%%          io:format("~n================ ~n Batch : ~n ==================~n"),
          timerbatch:send_time(self(), Time, Time_nr + 1),
%%          event_print(List),
          if N == 999 ->
              agreg ! {give},
              loop(Time, Amount, [], 0);
            true ->
              agreg ! {give},
              loop(Time, Amount, [], N+1)
          end;
        false -> loop(Time, Amount, List, Time_nr)
        end;
    stop ->
      io:format("Stopping batcher actor~n")
  end.

event_print([]) -> ok;
event_print([H|T]) ->
  io:format("~p~n", [H]),
  event_print(T).
