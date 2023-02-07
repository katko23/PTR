%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Feb 2023 5:52 PM
%%%-------------------------------------------------------------------
-module(helloworld).
-author("KATCO").

%% API
-export([helloworld/0]).

helloworld() -> io:fwrite("Hello World writed by Catalin").