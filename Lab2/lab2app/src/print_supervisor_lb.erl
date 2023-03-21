%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Mar 2023 3:01 AM
%%%-------------------------------------------------------------------
-module(print_supervisor_lb).
-author("KATCO").

-behaviour(supervisor).

-export([start_link/0, init/1, add_new_child/0, get_all_children/0, remove_one_child/0, send_message/1, least_conn/1]).

-record(server, {pid, num_connections}).

start_link() ->
  {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
  global:register_name(psv, Pid),
  io:fwrite("My Print SUpervisors PID is ~p~n",[Pid]),
  global:register_name(psv, Pid),
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

  ChildWorker = #{
    id => change_worker,
    start => {change_worker, start, []},
    restart => permanent,
%%    shutdown => brutal_kill,
    type => worker,
    modules => [change_worker]},

  ChildSpecs = [ChildWorker],
  {ok, {SupFlags, ChildSpecs}}.

add_new_child() ->
  supervisor:start_child(?MODULE, []).

remove_one_child() ->
  ChildPIDS = get_all_children(),
  [FirstChild | _ ] = ChildPIDS,
  supervisor:terminate_child(?MODULE, FirstChild).

get_all_children() ->
  ChildrenProcessData = supervisor:which_children(?MODULE),
  lists:map(fun({_, ChildPid, _, _}) -> ChildPid end, ChildrenProcessData).

send_message(Msg) ->
  {ok, State} = leastconnection:start(print_supervisor_lb:get_all_children()),
  {ok, ChildPid, NewState} = leastconnection:dispatch(State),
  ChildPid ! {print, Msg},
  NewState.

least_conn(Children) ->
  State = lists:map(fun(Pid) -> #server{pid=Pid, num_connections=0} end, Children),
  {ok, LeastConnPid, NewState} = leastconnection:dispatch(State),
  {ok, LeastConnPid, NewState}.