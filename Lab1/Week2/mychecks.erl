%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Feb 2023 10:34 AM
%%%-------------------------------------------------------------------
-module(mychecks).
-author("KATCO").

%% API
-export([main/0]).


maybe_to_int(Float) ->
  Trunc = trunc(Float),
  if Trunc == Float -> Trunc; true -> Float end .


main() ->
  io:fwrite("~w ~n",[lists:filter(fun(N) -> is_integer(maybe_to_int(N)) end,[12.32, 12.0, 1122.3, 121.0])])
.
%%def maybe_to_int(float) do
%%truncated = trunc(float)
%%if truncated == float, do: truncated, else: float
%%end