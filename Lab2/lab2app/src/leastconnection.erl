%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Mar 2023 2:32 AM
%%%-------------------------------------------------------------------
-module(leastconnection).
-author("KATCO").

-export([start/1, dispatch/1]).

-record(server, {pid, num_connections}).

%% Start the load balancer with a list of server PIDs.
start(Servers) ->
  State = lists:map(fun(Pid) -> #server{pid=Pid, num_connections=0} end, Servers),
  {ok, State}.

%% Dispatch a request to the server with the least number of active connections.
dispatch(State) ->
  % Find the server with the least number of active connections.
  {Server, _} = lists:min([{S, S#server.num_connections} || S <- State]),
  % Increment the number of active connections on the selected server.
  NewState = update_server(Server, State, fun(S) -> S#server{num_connections=S#server.num_connections+1} end),
  % Return the selected server's PID.
  {ok, Server#server.pid, NewState}.

%% Update the state of a server.
update_server(ServerPid, State, UpdateFun) ->
  lists:map(fun(S) ->
    if S#server.pid == ServerPid -> UpdateFun(S);
      true -> S
    end
            end, State).