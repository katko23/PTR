%%%-------------------------------------------------------------------
%% @doc lab2app top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(lab2app_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{strategy => one_for_all,
                 intensity => 1000,
                 period => 1},



  Stream1 = "/tweets/1",
  Stream2 = "/tweets/2",

  Printer = #{
    id => print,
    start => {print, start, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => [print]},

%%  Printer = #{
%%    id => print_superv,
%%    start => {print_superv, start_link, []},
%%    restart => permanent,
%%    shutdown => 2000,
%%    type => supervisor,
%%    modules => [print_superv]},

  WorkLoad = #{
    id => workload,
    start => {workload, start, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => [workload]},

  Reader1 = #{
    id => reader1,
    start => {sse_reader, start, [Stream1]},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => [sse_reader]},

  Reader2 = #{
    id => reader2,
    start => {sse_reader, start, [Stream2]},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => [sse_reader]},

  SupervisorLB = #{
    id => print_supervisor_lb,
    start => {print_supervisor_lb, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => supervisor,
    modules => [print_supervisor_lb]},

  Supervisor = #{
    id => print_supervisor,
    start => {print_supervisor, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => supervisor,
    modules => [print_supervisor]},

  RoundRobin = #{
    id => round_robin,
    start => {round_robin, start, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => [round_robin]},

%%  Popular = #{
%%    id => popular,
%%    start => {print, start_popular, []},
%%    restart => permanent,
%%    shutdown => 2000,
%%    type => worker,
%%    modules => [print]},


%%  Scaler = #{
%%    id => print_scaler,
%%    start => {print_scaler, start_link, []},
%%    restart => permanent,
%%    shutdown => 2000,
%%    type => worker,
%%    modules => [print_scaler]},

    ChildSpecs = [RoundRobin, Supervisor, SupervisorLB, Printer, Reader1, Reader2, WorkLoad],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
