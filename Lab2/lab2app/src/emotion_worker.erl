%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Mar 2023 12:54 PM
%%%-------------------------------------------------------------------
-module(emotion_worker).
-author("KATCO").

%% API
-export([start/0]).

start() ->
  Pid = spawn(
    fun () ->
      loop()
    end),
  io:fwrite("My Emotion PID is ~p~n",[Pid]),
%%  register(printc, Pid),
  {ok, Pid}.

loop() ->
  receive
    {compute, Id, TweetWords} ->
      ScoresInTweet =  lists:map(
        fun(Key) when is_integer(Key) =:= false ->
          LowerKey = string:to_lower(Key),
          Score = emotional_score:find_emotion(LowerKey),
          Score
        end,
        TweetWords),
      SumOfTweetTokens = lists:sum(ScoresInTweet),
      EmotionalScore = SumOfTweetTokens / length(ScoresInTweet),
%%      io:format("Emotional Score ~p ~n", [EmotionalScore]),
      Mess = lists:concat(["Emotional Score - ", EmotionalScore]),
      agreg ! {emotion, Id, Mess},
%%      batcher ! {print, Mess},
      loop();
    stop ->
      io:format("Stopping emotion actor~n")
  end.
