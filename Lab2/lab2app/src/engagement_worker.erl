%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Mar 2023 1:02 PM
%%%-------------------------------------------------------------------
-module(engagement_worker).
-author("KATCO").

%% API
-export([start/0]).

start() ->
  Pid = spawn(
    fun () ->
      loop()
    end),
  io:fwrite("My Engagement calculator actor's PID is ~p~n",[Pid]),
%%  register(engc, Pid),
  {ok, Pid}.

loop() ->
  receive
    {compute, Id, Fav, Retw, Follow} ->
%%      io:format("Favorit ~p~n", [Fav]),
%%      io:format("Retweet ~p~n", [Retw]),
%%      io:format("Follow ~p~n", [Follow]),
      if Follow == 0 -> Engagement = 0;
        true ->
          Engagement = ((Fav + Retw) / Follow)
      end,
%%      io:format("Engagement ~p ~n", [Engagement]),
      Mess = lists:concat(["Engagement - ", Engagement]),
      agreg ! {engagement, Id, Mess},
%%      batcher ! {print, Mess},
      loop();
    {compute, Fav, Follow} ->
%%      io:format("Favorit ~p~n", [Fav]),
%%      io:format("Follow ~p~n", [Follow]),
      if Follow == 0 -> Engagement = 0;
        true ->
          Engagement = (Fav / Follow)
      end,
%%      io:format("Engagement per User ~p ~n", [Engagement]),
%%      Mess = lists:concat(["Engagement per User - ", Engagement, "~n" ]),
%%      batcher ! {print, Mess},
      loop();
    AnyData ->
      io:format("Received message: ~p~n", [AnyData]),
      loop();
    stop ->
      io:format("Stopping engagement actor~n")
  end.
