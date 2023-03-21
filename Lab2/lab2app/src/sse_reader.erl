%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Mar 2023 8:37 PM
%%%-------------------------------------------------------------------
-module(sse_reader).
-author("KATCO").
-export([start/1]).

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
%%      io:format("-------------------------------------------------------------~n"),
%%      [_ | Json] = string:split(BinaryMessages, "event: \"message\"\n\ndata: "),
%%      io:format("~s~n", [jsx:decode(Json)])
%%      io:format("~s~n", [BinaryMessages]),

%%      io:format("~p~n", [whereis(printp)])
%%      [{_Id, ChildPID, _Type, _Modules}] = supervisor:get_childspec(print, print),
%%      ChildPID ! {print, BinaryMessages}


%%      print_supervisor_lb:send_message(BinaryMessages)

    print_supervisor:send_message(BinaryMessages),
    wkl ! {add}


%%      print:parse_tweets(BinaryMessages)



%%      whereis(printp) ! {print, BinaryMessages}
    end
  },
  {ok, _Ref} = shotgun:get(Conn, Stream, #{}, Options),
  delay(10000),
  shotgun:close(Conn).

delay(Miliseconds) ->
  receive
  after timer:sleep(Miliseconds * 10) -> {ok}
  end.