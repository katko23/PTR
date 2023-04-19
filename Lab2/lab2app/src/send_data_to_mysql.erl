%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Apr 2023 10:25 PM
%%%-------------------------------------------------------------------
-module(send_data_to_mysql).
-author("KATCO").

%% API
-export([send_user/2, send_enagement_user/2, send_tweets/1]).


%%cand pornesti inscrierea in baza de date ai grija sa decomentezi codul pentru a inscrie, plus sunt multe date de
%% transmitere



send_user(UserId, UserName) ->

  try
  {ok, Pid} = mysql:start_link([{host, "localhost"}, {user, "admin_ptr"},
    {password, "adminptr2023"}, {database, "ptr"}]),

  io:format("Send - ~p ~s ~n", [UserId, UserName]),

  ok = mysql:query(Pid, "INSERT IGNORE INTO users (idUsers, username) VALUES (?, ?)", [UserId, UserName]),

  mysql:stop(Pid)

  catch
    Exception: Reason -> {caught, Exception, Reason},
      dbdown ! {user, [UserId, UserName]}
  end
.

send_enagement_user(UserId, Engagement) ->
  ok
  .

send_tweets(Array)->
  [TweetL|T] = Array,
  [TextTweet | [IdUser]] = TweetL,
  [TextEmotional|EngId] = T,
  [TextEngagement|[TweetID]] = EngId,



  {Tweet, Engagement, Emotional} = tweetparse(TextTweet, TextEmotional, TextEngagement),

  io:format("Send Tweet - ~p ~p ~p ~p ~p ~n", [TweetID, Tweet, Emotional, Engagement, IdUser]),

 try
  {ok, Pid} = mysql:start_link([{host, "localhost"}, {user, "admin_ptr"},
    {password, "adminptr2023"}, {database, "ptr"}]),

  ok = mysql:query(Pid,
    "INSERT IGNORE INTO tweets (idtweets, tweet_text, emotional_score, engagement_score, idUser) VALUES (?, ?, ?, ?, ?)",
    [TweetID, Tweet, Emotional, Engagement, IdUser]),

  mysql:stop(Pid)
  catch
   Exception: Reason -> {caught, Exception, Reason},
     dbdown ! {tweet, [TweetID, Tweet, Emotional, Engagement, IdUser]}
 end

.


tweetparse(TextTweet, TextEngagement, TextEmotional) ->
  try
    [_| [Tweet]] = string:split(TextTweet, " - "),
    [_| [Engagement]] = string:split(TextEngagement, " - "),
    [_| [Emotional]] = string:split(TextEmotional, " - "),
    {Tweet, Engagement, Emotional}
  catch
    Exception: Reason -> {caught, Exception, Reason}
end

.