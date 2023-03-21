%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Mar 2023 8:33 PM
%%%-------------------------------------------------------------------
-module(print).
-author("KATCO").

-export([start/0, print/1, stop/0, start_popular/0]).

start() ->
%%  {Pid, _} = spawn_link(fun() -> loop() end),
  {Pid, _} = spawn_monitor(
    fun () ->
      loop()
    end),
  io:fwrite("My Print PID is ~p~n",[Pid]),
  register(printp, Pid),
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
                #{<<"message">> := #{<<"tweet">> := #{<<"entities">> :=  #{<<"hashtags">> :=HashTags}}}} = JsonMap,
                io:format("Received Hash: ~p~n", [HashTags]),
%%                hashpid ! {list, HashTags},
                JsonToUnicode = unicode:characters_to_list(TweetText),
                io:format("Received Json: ~p~n", [JsonToUnicode]);
              _ ->
                io:format("Exit with panic exception ~n")
%%                erlang:exit(panic)
          end;

          true ->
            pass
%%            io:format("Received message: ~s~n", [Message])
      end,
      loop();
    stop ->
      io:format("Stopping printer actor~n");
    AnyData ->
      io:format("Received message: ~s~n", [AnyData]),
      loop()
  end.

print(Message) ->
  printer_actor ! {print, Message}.

stop() ->
  printer_actor ! stop.

start_popular()->
 {PidH, _} = spawn_monitor(fun() -> mostpopular([]) end),
  register(hashpid, PidH),
  erlang:send_after(5000, whereis(hashpid), [time]),
   {ok, PidH}.

mostpopular(List) ->
  receive
    {list, HashList} ->
      mostpopular(lists:append(List, HashList));
    {time} ->
      io:format("Most Frequent Hashtag: ~s~n", [most_frequent(List)]),
      erlang:send_after(5000, self(), {time}),
      mostpopular([])
  end.

most_frequent(List) ->
  {_Freq, Element} = lists:foldl(fun(Item, {Freq, Element}) ->
    Count = count(Item, List),
    if
      Count > Freq -> {Count, Item};
      true -> {Freq, Element}
    end end, {0, undefined}, List),
  Element.

count(Element, List) ->
  lists:foldl(fun(Item, Acc) ->
    if Item == Element ->
      Acc + 1;
      true ->
        Acc
    end
              end, 0, List).

%%-export([start_link/0]).
%%
%%start_link() ->
%%  {Pid, _} = spawn_monitor(
%%    fun () ->
%%      receive_tweet()
%%    end),
%%  {ok, Pid}.
%%
%%
%%receive_tweet() ->
%%  receive
%%    {sse_event, _Event, Data} ->
%%      Tweet = parse_tweet(Data),
%%      io:format("~s~n", [Tweet]),
%%      receive_tweet();
%%    stop ->
%%      ok;
%%    data ->
%%%%      [_ | Json] = string:split(data, "event: \"message\"\n\ndata: "),
%%      io:format("~s~n", [data]),
%%      io:format("______________________________________________________________~n"),
%%      receive_tweet()
%%  end.
%%
%%parse_tweet(Data) ->
%%%%  Tweet = jsx:decode(Data),
%%%%  proplists:get_value(<<"text">>, Tweet, <<>>).
%%%%  io:format("~s~n", [Tweet]).
%%  Data.