%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Apr 2023 9:08 AM
%%%-------------------------------------------------------------------
-module(timerbatch).
-author("KATCO").

%% API
-export([send_time/3]).

send_time(Pid, Time, Time_nr) ->
  erlang:send_after(Time, Pid, {timesup, Time_nr}).

