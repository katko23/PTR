%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Feb 2023 1:41 AM
%%%-------------------------------------------------------------------
-module(semaphore).
-author("KATCO").

%% API
-export([]).
-export([create_semaphore/1, acquire/1, release/1]).

create_semaphore(Count) ->
  spawn(fun() -> loop(Count) end).

acquire(Semaphore) ->
  Semaphore ! wait,
  receive
    ok -> ok
  end.

release(Semaphore) ->
  Semaphore ! signal.

loop(Count) ->
  receive
    wait ->
      if Count > 0 ->
          NewCount = Count - 1,
          loop(NewCount);
        true ->
          receive
            signal ->
              NewCount = Count + 1,
              loop(NewCount)
          end
      end;
    signal ->
      NewCount = Count + 1,
      loop(NewCount)
  end.