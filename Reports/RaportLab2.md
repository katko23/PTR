# FAF.PTR16.1 -- Project 0
> **Performed by:** Cătălin Coșeru, group FAF-201 \
> **Verified by:** asist. univ. Alexandru Osadcenco

## P0W1

**Task 1** -- Write an actor that would read SSE streams. The SSE streams for this lab
are available on Docker Hub at alexburlacu/rtp-server, courtesy of our beloved FAFer Alex
Burlacu.


```erlang
start(Stream) ->
  {Pid, _} = spawn_monitor(
    fun () ->
      send_event(Stream)
    end),
  {ok, Pid}.

send_event(Stream) ->

  {ok, Conn} = shotgun:open("localhost", 8000),
  Options = #{
    async => true,
    async_mode => sse,
    handle_event =>
    fun (_, _State, BinaryMessages) ->

      print_supervisor:send_message(BinaryMessages),
      wkl ! {add}
    end
  },
  {ok, _Ref} = shotgun:get(Conn, Stream, #{}, Options),
  delay(100000),
  shotgun:close(Conn).

delay(Miliseconds) ->
  receive
  after timer:sleep(Miliseconds * 10) -> {ok}
  end.
```


**Task 2** -- Printer actor. Simulate some load on the actor by sleeping every
time a tweet is received. Suggested time of sleep – 5ms to 50ms. Consider using Poisson
distribution. Sleep values / distribution parameters need to be parameterizable.

```erlang
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
```

## P0W2

**Task 1** -- Printer Supervisor

```erlang
start_link() ->
  {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
%%  {ok, Pid} = supervisor:start_link(print_supervisor, []),
%%  global:register_name(psv, Pid),
  io:fwrite("My Print SUpervisors PID is ~p~n",[Pid]),
  global:register_name(psv, Pid),

  add_new_child(),
  add_new_child(),
%%  add_new_child(),

  {ok, Pid}.

init(_Args) ->
  MaxRestart = 1000,
  MaxTime = 1,
  SupFlags = #{
    strategy => simple_one_for_one,
    intensity => MaxRestart,
    period => MaxTime
  },

  ChildWorker = #{
    id => worker1,
    start => {change_worker, start, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => [change_worker]},

  ChildSpecs = [ChildWorker],
  {ok, {SupFlags, ChildSpecs}}.

add_new_child() ->
  supervisor:start_child(?MODULE, []).
%%  supervisor:start_child(print_supervisor, []).

remove_one_child() ->
  ChildPIDS = get_all_children(),
  [FirstChild | _ ] = ChildPIDS,
  supervisor:terminate_child(?MODULE, FirstChild).

get_all_children() ->
  ChildrenProcessData = supervisor:which_children(?MODULE),
  lists:map(fun({_, ChildPid, _, _}) -> ChildPid end, ChildrenProcessData).

send_message(Msg )->
  N = round_robin(length(print_supervisor:get_all_children())),
  ChildSpecs = lists:nth(N, print_supervisor:get_all_children()),
  ChildSpecs ! {print, Msg},
  N2 = round_robin(length(print_supervisor:get_all_children())),
  ChildSpecs2 = lists:nth(N2, print_supervisor:get_all_children()),
  ChildSpecs2 ! {print, Msg}
%%  N3 = round_robin(length(print_supervisor:get_all_children())),
%%  ChildSpecs3 = lists:nth(N3, print_supervisor:get_all_children()),
%%  ChildSpecs3 ! {print, Msg}
%%  io:format("Childrens alive = ~p~n", [supervisor:which_children(print_supervisor)]),
%%  io:format("Childrens alive: ~p~n", [print_supervisor:get_all_children()])
.

retweet(Msg) ->
  N = round_robin(length(print_supervisor:get_all_children())),
  ChildSpecs = lists:nth(N, print_supervisor:get_all_children()),
  ChildSpecs ! {retweet, Msg}
.
round_robin(N) ->
%%  io:format("My number of prints is ~p~n", [N]),
  rr ! {N, getNext, self()},
  receive
    {Number} -> Number
  end.
```

Soo this code is just implementation of
a supervisor for a set of child processes 
that perform printing operations.

**Task 2** -- Load Balancer

```erlang
start(Name) ->
%%  {Pid, _} = spawn_link(fun() -> loop() end),
  {Pid, _} = spawn_monitor(
    fun () ->
      loop(1,1)
    end),
  register(Name, Pid),
  {ok, Pid}.

loop(N, I) ->
  if
    I > N -> Index = 1 ;
    true -> Index = I
  end,
  receive
    {PrintersNumb, getNext, Self} ->
      Self ! {Index},
      loop(PrintersNumb, Index+1);
    stop ->
      ok
  end.

stop() ->
  rr ! stop.
```

A simple roundrobin to balance the load on all printers.

## P0W3

**Task 1** -- Bad Words

```erlang
split_string(String) ->
  string:tokens(String, " \t\n\r\f.").

check(Phrase) ->
  Words = split_string(Phrase),
  ListofWords = lists:map(fun(Element) ->
    Word = string:to_lower(Element),
    case check_word(Word) of
      true ->
        Len = length(Word),
        lists:duplicate(Len, $*);
      false -> Element
    end
                          end, Words),
  string:join(ListofWords, " ")
.


check_word(Word) ->
  BadWords = [
    "arse",
    "arsehead",
    "arsehole",
    "ass",
    "asshole",
    "bastard",
    "bitch",
    "bloody",
    "bollocks",
    "brotherfucker",
    "bugger",
    "bullshit",
    "child-fucker",
    "childfucker",
    "cock",
    "cocksucker",
    "crap",
    "cunt",
    "damn",
    "dick",
    "dickhead",
    "dyke",
    "fatherfucker",
    "frigger",
    "fuck",
    "goddamn",
    "godsdamn",
    "hell",
    "horseshit",
    "kike",
    "motherfucker",
    "nigga",
    "nigra",
    "piss",
    "prick",
    "pussy",
    "shit",
    "shite",
    "sisterfucker",
    "slut",
    "spastic",
    "turd",
    "twat",
    "wanker",
    "whore",
    "wtf"
  ],
  lists:member(Word, BadWords).
```

So any bad words that a tweet might contain is not printed. 
Instead, a set of stars should appear, the number of which corresponds to
the bad word’s length.

**Task 2** -- Increase/Reduce nr of workers

```erlang
start() ->
  Pid = spawn(
    fun () ->
      loop(0, 2, 10)
    end),
  register(wkl, Pid),
  {ok, Pid}.

loop(N, Min, Max) ->
  case (N >= 10 andalso N < Max) of
    true -> print_supervisor:add_new_child(),
      loop(0, Min, Max)
    ;
    false ->
      case (N < -50 andalso N > Min) of
        true -> print_supervisor:remove_one_child(),
          loop(0, Min, Max);
        false -> ok
      end
  end,
%%  io:format("My workflow is ~p~n", [N]),
  receive
    {add} ->
      loop(N + 1, Min, Max);
    {substr} ->
      loop(N - 1, Min, Max);
    {Self, get} ->
      Self ! {workload, N},
      loop(N, Min, Max)
  end
.
```

This is a program that creates, and deletes printers ,soo if the sended messages is a bigger than 
the printed one , is sent a message to increase the number of priters, and if some printers has no job
, then it's stoped.

## P0W4

**Task 1** -- # 3 Tipes of workers.

Printer:
```erlang
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
```

Emotion:

```erlang
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
      Mess = lists:concat(["Emotional Score - ", EmotionalScore]),
      agreg ! {emotion, Id, Mess},
      loop();
    stop ->
      io:format("Stopping emotion actor~n")
  end.
```


Engagement:


```erlang
loop() ->
  receive
    {compute, Id, Fav, Retw, Follow} ->
      if Follow == 0 -> Engagement = 0;
        true ->
          Engagement = ((Fav + Retw) / Follow)
      end,
      Mess = lists:concat(["Engagement - ", Engagement]),
      agreg ! {engagement, Id, Mess},
      loop();
    {compute, Fav, Follow} ->
      if Follow == 0 -> Engagement = 0;
        true ->
          Engagement = (Fav / Follow)
      end,
      loop();
    AnyData ->
      io:format("Received message: ~p~n", [AnyData]),
      loop();
    stop ->
      io:format("Stopping engagement actor~n")
  end.
```

This is an implementation of an Erlang printer. The start() function spawns a new process that runs the loop() function. The loop() function waits for messages to arrive and processes them accordingly. There are two types of messages that the loop() function can receive:

{print, Message}: This message contains a binary that represents a JSON object. The loop() function decodes the JSON object, extracts various pieces of data from it, and then sends messages to other processes to perform various calculations on the data. Finally, the loop() function sends a message to the agreg process to print the message and some additional information to the console.

{retweet, JsonMap}: This message contains a map that represents a JSON object that describes a retweet. The loop() function extracts various pieces of data from the JSON object and sends messages to other processes to perform various calculations on the data.

Also you can see an implementation of a emotion worker and an engagement worker, both are some 
actors , that perform some calculus to get the engagementa ratio and the emotional score of the tweet.


## P0W5

**Task 1** -- Batcher

```erlang
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
```

This is a set of functions written in Erlang to make an actor of batcher type , that will bring some
processed tweets in order to send it to another unit.

**Task 2** -- Aggregator

```erlang
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
  [H | delete(Id, T)].
```

## P0W6

**Task 1** -- Mysql DB

```erlang
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
```


## Conclusion

Through the completion of this lab 2 on real-time programming, I accomplished a series of tasks in a reactive system, specifically based on a reactive stream of tweets, which needed to be printed, calculated, and sent to a database. Likewise, I didn't forget about errors, their handling, and the implementation of all real-time programming rules: processing "in-stream" messages, support for high-level "StreamSQL" languages, fault tolerance, scalability, transparency, and also real-time responsiveness.
## Bibliography

https://www.tutorialspoint.com/erlang/erlang_environment.htm
https://www.erlang.org/docs/25/
https://learnyousomeerlang.com/content
https://learnyousomeerlang.com/starting-out-for-real
https://medium.com/erlang-central/building-your-first-erlang-app-using-rebar3-25f40b109aad
https://rebar3.org/docs/getting-started/
https://elixirforum.com/t/erl-exe-is-not-recognized-as-an-internal-or-external-command/34893/3
https://www.erlang.org/doc/apps/erts/crash_dump.html#reasons-for-crash-dumps--slogan-
https://www.tutorialspoint.com/erlang/erlang_recursion.htm
https://learnyousomeerlang.com/designing-a-concurrent-application#an-event-module
https://stackoverflow.com/questions/25748917/how-to-do-a-simple-http-post-get-with-header-using-erlang-without-a-library-if
https://github.com/dizzyd/erlang-mysql-driver/blob/main/test/mysql_test.erl
https://github.com/dizzyd/erlang-mysql-driver
https://stackoverflow.com/questions/2060547/erlang-mysql-example
https://github.com/mysql-otp/mysql-otp
https://www.erlang.org/doc/man/string.html#split-2
https://stackoverflow.com/questions/31563995/erlang-variable-result-unsafe-in-try


