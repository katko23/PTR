%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Mar 2023 9:34 PM
%%%-------------------------------------------------------------------
-module(print_superv).
-behaviour(supervisor).
-author("KATCO").

-export([start_link/0, init/1, send_message/1]).

start_link() ->
  {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
  {ok, Pid}.

init(_Args) ->
  MaxRestart = 6,
  MaxTime = 100,
  SupFlags = #{
    strategy => simple_one_for_one,
    intensity => MaxRestart,
    period => MaxTime
  },

  ChildWorker = #{
    id => print,
    start => {print, start, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => [print]},

  ChildSpecs = [ChildWorker],
  {ok, {SupFlags, ChildSpecs}}.

send_message(Msg) ->
  Pid = case supervisor:which_children(my_supervisor) of
          [{_, ChildPid, worker, [my_actor]}] -> ChildPid;
          _ -> undefined
        end,
  case Pid of
    undefined -> {error, no_actor_found};
    _ -> Pid ! Msg, {ok, sent}
  end.