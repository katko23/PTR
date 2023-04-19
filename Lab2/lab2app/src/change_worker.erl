%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Mar 2023 10:17 AM
%%%-------------------------------------------------------------------
-module(change_worker).
-author("KATCO").

%% API
-export([start/0, print/1, stop/0]).

start() ->
%%  {Pid, _} = spawn_link(fun() -> loop() end),
%%  {Pid, _} = spawn_monitor(
%%    fun () ->
%%      loop()
%%    end),
  Pid = spawn(
    fun () ->
      loop()
    end),
  io:fwrite("My Print changed PID is ~p~n",[Pid]),
%%  register(printc, Pid),
  {ok, Pid}.

loop() ->
  receive
    {print, Message} ->
      String = binary_to_list(Message),
      if
        "event: \"message\"" /= String ->
%%          io:format("Received message: ~d~n", [Message])
          [_ | Splited] = string:split(String,": "),
%%          io:format("Received Split: ~s~n", [Splited]),
          case string:find(Splited, "panic") of
            nomatch->
%%                Json = jsone:decode(list_to_binary(Splited)),
              Json = list_to_binary(Splited),
              JsonMap = jsx:decode(Json),
              #{<<"message">> := #{<<"tweet">> := #{<<"text">> := TweetText}}} = JsonMap,
              #{<<"message">> := #{<<"tweet">> := #{<<"favorite_count">> := FavText}}} = JsonMap,
              #{<<"message">> := #{<<"tweet">> := #{<<"retweet_count">> := RetText}}} = JsonMap,
              #{<<"message">> := #{<<"tweet">> := #{<<"user">> := #{<<"favourites_count">> := FavUserText}}}} = JsonMap,
              #{<<"message">> := #{<<"tweet">> := #{<<"user">> := #{<<"name">> := UsernameText}}}} = JsonMap,
              #{<<"message">> := #{<<"tweet">> := #{<<"user">> := #{<<"id">> := UserIdText}}}} = JsonMap,
              #{<<"message">> := #{<<"tweet">> := #{<<"user">> := #{<<"followers_count">> := FollowText}}}} = JsonMap,
              #{<<"message">> := #{<<"tweet">> := #{<<"id">> := Id}}} = JsonMap,

              try
                #{<<"message">> := #{<<"tweet">> := #{<<"retweeted_status">> := Retweeted }}} = JsonMap,
                  print_supervisor:retweet(Retweeted)
                catch
                Exception:Reason -> {caught, Exception, Reason}
              end,

%%              #{<<"message">> := #{<<"tweet">> := #{<<"entities">> :=  #{<<"hashtags">> :=HashTags}}}} = JsonMap,
%%              io:format("Received Hash: ~p~n", [HashTags]),
%%%%                hashpid ! {list, HashTags},
              JsonToUnicode = unicode:characters_to_list(TweetText),
              wkl ! {substr},
              TweetWords = string:tokens(JsonToUnicode, "&#0123456789,./'\";:{}[]()*%/+-_<>!?\n@ "),
%%              calculate_score(TweetWords),
              send_data_to_mysql:send_user(UserIdText, UsernameText),
              emotion_supervisor:emotional_score(Id, TweetWords),
              engagement_supervisor:engagement_score(Id, FavText, RetText, FollowText),
              engagement_supervisor:engagement_score(FavUserText, FollowText),
%%              calculate_engagement(FavText, RetText, FollowText),
%%              io:format("Received Json: ~p~n", [badwords:check(JsonToUnicode)]),
              Mess = lists:concat(["Received Json - ", badwords:check(JsonToUnicode) ]),
              agreg ! {print, Id, Mess, UserIdText}
%%              batcher ! {print, Mess}
            ;
            _ ->
              self() ! exit
          end;

        true ->
          pass
%%            io:format("Received message: ~s~n", [Message])
      end,
      loop();
    {retweet, JsonMap} ->
      #{<<"text">> := TweetText} = JsonMap,
      #{<<"favorite_count">> := FavText} = JsonMap,
      #{<<"retweet_count">> := RetText} = JsonMap,
      #{<<"user">> := #{<<"favourites_count">> := FavUserText}} = JsonMap,
      #{<<"user">> := #{<<"followers_count">> := FollowText}} = JsonMap,
      #{<<"user">> := #{<<"name">> := UsernameText}} = JsonMap,
      #{<<"user">> := #{<<"id_str">> := UserIdText}} = JsonMap,
      #{<<"id">> := Id} = JsonMap,
      try
        #{<<"message">> := #{<<"tweet">> := #{<<"retweeted_status">> := Retweeted }}} = JsonMap,
        print_supervisor:retweet(Retweeted)
      catch
        Exception:Reason -> {caught, Exception, Reason}
      end,
      JsonToUnicode = unicode:characters_to_list(TweetText),
      wkl ! {substr},
      TweetWords = string:tokens(JsonToUnicode, "&#0123456789,./'\";:{}[]()*%/+-_<>!?\n@ "),
      send_data_to_mysql:send_user(UserIdText, UsernameText),
      emotion_supervisor:emotional_score(Id, TweetWords),
      engagement_supervisor:engagement_score(Id, FavText, RetText, FollowText),
      engagement_supervisor:engagement_score(FavUserText, FollowText),
      Mess = lists:concat(["Received Json - ", badwords:check(JsonToUnicode) ]),
      agreg ! {print, Id, Mess, UserIdText},
    loop()
    ;
    exit ->
%%      io:format("Exit with panic exception ~n"),
      wkl ! {substr},
%%      exit(self(), normal),
      loop();
    stop ->
      io:format("Stopping printer actor~n");
    AnyData ->
      io:format("Received message: ~p~n", [AnyData]),
      loop()
  end.
print(Message) ->
  printer_actor ! {print, Message}.

stop() ->
  printer_actor ! stop.

calculate_score(TweetWords) ->
  ScoresInTweet =  lists:map(
    fun(Key) when is_integer(Key) =:= false ->
      LowerKey = string:to_lower(Key),
      Score = emotional_score:find_emotion(LowerKey),
      Score
    end,
    TweetWords),
  SumOfTweetTokens = lists:sum(ScoresInTweet),
  EmotionalScore = SumOfTweetTokens / length(ScoresInTweet),
  io:format("Emotional Score ~p ~n", [EmotionalScore]),
  EmotionalScore.

calculate_engagement(Fav, Retw, Follow) ->
%%  try
%%  Engagement = (list_to_integer(Fav) * list_to_integer(Retw)) / list_to_integer(Follow),
%%  Engagement
%%  catch
%%    Exception:Reason -> {caught, Exception, Reason},
%%    Engagement = 0
%%  end,
  io:format("Favorit ~p~n", [Fav]),
  io:format("Retweet ~p~n", [Retw]),
  io:format("Follow ~p~n", [Follow]),
  if Follow == 0 -> Engagement = 0;
    true ->
  Engagement = ((Fav + Retw) / Follow)
  end,
  io:format("Engagement ~p ~n", [Engagement])
.