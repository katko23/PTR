%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Feb 2023 9:21 PM
%%%-------------------------------------------------------------------
-module(main_working).
-export([while/1, while/2, start/0]).
-import(lab1, [isPrime/1, cylinderArea/2, reverse/1, sum/3, uniqueSum/1, extractRandomN/2, uniqueSum2/1, firstFibonacciElements/1]).
-import(lab1, [translator/2]).

while(T) -> while(T,0).
while([], Acc) -> Acc;
while([H|T], Acc) ->
  io:fwrite("~w~n",[H]),
  while(T,Acc+1).


start() ->
%%%%  Name = 'Catalin',
%%%%  io:fwrite("Hello, world!\n~w~n",[Name]),
%%%%  Name_lists = ['Catalin','Damian','Stefan'],
%%%%  while(Name_lists),
%%  io:fwrite("~p~n",[isPrime(1)]),
%%%%  io:fwrite("~p~n",[isPrime(2)]),
%%%%  io:fwrite("~w~n",[isPrime(100)]),
%%%%  io:fwrite("~w~n",[isPrime(7)]),
%%  io:fwrite("~.4f~n",[cylinderArea(3, 4)]),
%%  io:fwrite("~p~n",[reverse ([1 , 2 , 4 , 8 , 4])]),
%%  sum(1, 10, 2),
%%  io:fwrite("~p~n",[uniqueSum ([1 , 2 , 4 , 8 , 4 , 2])]),
%%  io:fwrite("~p~n",[uniqueSum2 ([1 , 2 , 4 , 8 , 4 , 2])]),
%%  io:fwrite("~p~n",[extractRandomN ([1 , 2 , 4 , 8 , 4] , 3)]),
%%  io:fwrite("~p~n",[firstFibonacciElements (7)]),
%%  Dictionary = dict:append("papa", "father",dict:append("mama","mother",dict:new())),
%%  Original_string = " mama is with papa ",
%%  io:fwrite("~p~n",[lab1:translator ( Dictionary , Original_string )]),
%%  io:fwrite("~p~n",[lab1:smallestNumber ([0,3,4]) ]),
%%  io:fwrite("~p~n",[lab1:rotateLeft ([1 , 2 , 4 , 8 , 4] , 3)]),
%%  io:fwrite("~p~n",[lab1:listRightAngleTriangles() ]),
%%  io:fwrite("~p~n",[lab1:removeConsecutiveDuplicates([1, 2, 2, 2, 4, 8, 4]) ]),
%%%%  io:fwrite("~p~n",[lab1:lineWords ([" Hello " ," Alaska " ," Dad " ," Peace "])])
%%  io:fwrite("~p~n",[lab1:words_in_one_row(["Hello" ,"Alaska" ,"Dad" ,"Peace"])]),
%%%%  io:fwrite("~p~n",[lab1:encode("lorem" , 3)]),
%%  lab1:encMsg("lorem", 3),,
%%  lab1:caesar("lorem", 3)
%%  io:fwrite("~p ~n",[lab1:lettersCombinations("23")]),
%%  io:fwrite("~p ~n",[lab1:groupAnagrams ([" eat " , " tea " , " tan " , " ate " , " nat " , " bat "])]),
%%%%  io:fwrite("~p~n",[lab1:get_anagrams(["e","a","t"])]),
%%  io:fwrite("~p~n",[bonustask:commonPrefix(["flower" ,"flow" ,"flight"])])
%%  io:fwrite("~p~n",[bonustask:checkPrefix([[X]||X<-"flower"],[[X] || X <-"fl"],"")])
%%  io:fwrite("~p~n",[bonustask:toRoman("4999")])
%%  io:fwrite("~p~n", [bonustask:getPrimes(13)])
  io:fwrite("~w~n", [bonustask:factorize(40)])
.
