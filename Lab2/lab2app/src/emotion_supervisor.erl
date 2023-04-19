%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Mar 2023 1:09 PM
%%%-------------------------------------------------------------------
-module(emotion_supervisor).
-author("KATCO").

-behaviour(supervisor).

-export([start_link/0, init/1, add_new_child/0, get_all_children/0, remove_one_child/0, emotional_score/2, round_robin/1]).

start_link() ->
  {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
  io:fwrite("My Emotion Spervisors PID is ~p~n",[Pid]),
  global:register_name(emo, Pid),
  add_new_child(),
%%  add_new_child(),
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
    id => calculator,
    start => {emotion_worker, start, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => [emotion_worker]},

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

emotional_score(Id, Msg )->
  N = round_robin(length(emotion_supervisor:get_all_children())),
  ChildSpecs = lists:nth(N, emotion_supervisor:get_all_children()),
  ChildSpecs ! {compute, Id, Msg}
%%  N2 = round_robin(length(print_supervisor:get_all_children())),
%%  ChildSpecs2 = lists:nth(N2, print_supervisor:get_all_children()),
%%  ChildSpecs2 ! {print, Msg}
%%  N3 = round_robin(length(print_supervisor:get_all_children())),
%%  ChildSpecs3 = lists:nth(N3, print_supervisor:get_all_children()),
%%  ChildSpecs3 ! {print, Msg}
%%  io:format("Childrens alive = ~p~n", [supervisor:which_children(print_supervisor)]),
%%  io:format("Childrens alive: ~p~n", [print_supervisor:get_all_children()])
.

round_robin(N) ->
%%  io:format("My number of prints is ~p~n", [N]),
  rre ! {N, getNext, self()},
  receive
    {Number} -> Number
  end.

