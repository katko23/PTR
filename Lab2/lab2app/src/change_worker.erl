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
%%              #{<<"message">> := #{<<"tweet">> := #{<<"entities">> :=  #{<<"hashtags">> :=HashTags}}}} = JsonMap,
%%              io:format("Received Hash: ~p~n", [HashTags]),
%%%%                hashpid ! {list, HashTags},
              JsonToUnicode = unicode:characters_to_list(TweetText),
              wkl ! {substr},
              io:format("Received Json: ~p~n", [badwords:check(JsonToUnicode)])
            ;
            _ ->
              self() ! exit
          end;

        true ->
          pass
%%            io:format("Received message: ~s~n", [Message])
      end,
      loop();
    exit ->
      io:format("Exit with panic exception ~n"),
      wkl ! {substr},
%%      exit(self(), normal),
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
