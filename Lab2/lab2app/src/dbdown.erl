%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Apr 2023 12:13 AM
%%%-------------------------------------------------------------------
-module(dbdown).
-author("KATCO").

%% API
-export([start/0, loop/2]).

start() ->
  Pid = spawn(
    fun () ->
      loop([],[])
    end),
  io:fwrite("My BDDown PID is ~p~n",[Pid]),
  register(dbdown, Pid),
  {ok, Pid}.

loop(UserArray, TweetArray) ->
  case trysend() of
    true ->
      lists:foreach(fun(Element) ->
                  [UserId,UserName] = Element,
%%                  send_data_to_mysql:send_user(UserId,UserName),
                  io:format("BDDown Send - ~p ~s ~n", [UserId, UserName])
                end, UserArray),
  lists:foreach(fun(Element) ->
    [TweetID, Tweet, Emotional, Engagement, IdUser] = Element,
%%        send_data_to_mysql:send_tweets([TweetID, Tweet, Emotional, Engagement, IdUser]),
    io:format("BDDown Send Tweet - ~p ~p ~p ~p ~p ~n", [TweetID, Tweet, Emotional, Engagement, IdUser])
                end, TweetArray);
      false -> ok
  end,
  receive
    {user, UserElement} ->
      List = lists:append(UserArray, [UserElement]),
      NewList = remove_dups(List),
      loop(NewList, TweetArray);
    {tweet, TweetElement} ->
      List = lists:append(TweetArray, [TweetElement]),
      NewList = remove_dups(List),
      loop(UserArray, NewList)
  end.

trysend()->
  try
  {ok, Pid} = mysql:start_link([{host, "localhost"}, {user, "admin_ptr"},
    {password, "adminptr2023"}, {database, "ptr"}]),
  mysql:stop(Pid),
    true
  catch
    Exception: Reason -> {caught, Exception, Reason},
      false
  end

.

remove_dups([])    -> [];
remove_dups([H|T]) -> [H | [X || X <- remove_dups(T), X /= H]].