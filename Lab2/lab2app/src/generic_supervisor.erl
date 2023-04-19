%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. Mar 2023 8:25 AM
%%%-------------------------------------------------------------------
-module(generic_supervisor).
-author("KATCO").

-behaviour(supervisor).

-export([start_link/0, init/1,
  add_new_print/0,
  add_new_emotion/0,
  add_new_engagement/0,
  add_new_child/0,
  get_all_children/0,
  remove_one_child/0
%%  engagement_score/3, engagement_score/2,
  ]).

start_link() ->
  {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
%%  add_new_print(),
%%  add_new_emotion(),
%%  add_new_engagement(),
  add_new_child(),

  {ok, Pid}.

init(_Args) ->
  MaxRestart = 1000,
  MaxTime = 1,
  SupFlags = #{
    strategy => simple_one_for_one,
    intensity => MaxRestart,
    period => MaxTime
  },

  Supervisor = #{
    id => print_supervisor,
    start => {print_supervisor, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => supervisor,
    modules => [print_supervisor]},

  EmotionSupervisor = #{
    id => emotion_supervisor,
    start => {emotion_supervisor, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => supervisor,
    modules => [emotion_supervisor]},

  EngagementSupervisor = #{
    id => engagement_supervisor,
    start => {engagement_supervisor, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => supervisor,
    modules => [engagement_supervisor]},

  ChildSpecs = [
    Supervisor
%%    EmotionSupervisor,
%%    EngagementSupervisor
  ],
  {ok, {SupFlags, ChildSpecs}}.

add_new_child() ->
  supervisor:start_child(?MODULE, []).

add_new_print() ->
  Supervisor = #{
    id => print_supervisor,
    start => {print_supervisor, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => supervisor,
    modules => [print_supervisor]},
  supervisor:start_child(?MODULE, [Supervisor]).

add_new_emotion() ->
  EmotionSupervisor = #{
    id => emotion_supervisor,
    start => {emotion_supervisor, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => supervisor,
    modules => [emotion_supervisor]},
  supervisor:start_child(?MODULE, [EmotionSupervisor]).

add_new_engagement() ->
  EngagementSupervisor = #{
    id => engagement_supervisor,
    start => {engagement_supervisor, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => supervisor,
    modules => [engagement_supervisor]},
  supervisor:start_child(?MODULE, [EngagementSupervisor]).

remove_one_child() ->
  ChildPIDS = get_all_children(),
  [FirstChild | _ ] = ChildPIDS,
  supervisor:terminate_child(?MODULE, FirstChild).

get_all_children() ->
  ChildrenProcessData = supervisor:which_children(?MODULE),
  lists:map(fun({_, ChildPid, _, _}) -> ChildPid end, ChildrenProcessData).
