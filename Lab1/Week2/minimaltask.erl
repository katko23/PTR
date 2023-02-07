%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Feb 2023 2:07 AM
%%%-------------------------------------------------------------------
-module(minimaltask).
-author("KATCO").
-import(math,[pi/0]).
%% API
-export([isPrime/1, cylinderArea/2, reverse/1, sum/3, uniqueSum/1, extractRandomN/2, uniqueSum2/1, firstFibonacciElements/1]).
-export([translator/2, smallestNumber/1, rotateLeft/2, listRightAngleTriangles/0]).

-import(sets, [add_element/2, is_element/2, new/0]).

%function nr 1 isPrime
isPrime(N) when N == 0 ; N == 1 -> false;
isPrime(N) when N == 2 -> true;
isPrime(N) -> isPrime(N,2).
isPrime(N,N) -> true;
isPrime(N,M) when N > 0->
  ChPrime = N rem M,
  if
    ChPrime == 0 -> false;
  true -> isPrime(N,M+1)
end.


% function 2 Area of a cylinder
cylinderArea (H, R) when H > 0; R > 0 ->
  2 * pi() * R * ( H + R ).

% function 3 Reverse of an array
reverse(L) -> reverse(L,[]).
reverse([],Acc) -> Acc;
reverse([H|T],Acc) -> reverse(T, [H|Acc]).

% a simple for from a element E to a number N with given progresion P
sum(E, N, _P) when E >= N -> io:fwrite("~w~n",[E]);
sum(E, N, P) when E < N ->
  io:fwrite("~w~n",[E]),
  sum(E+P,N, P).

% function 4 unique sum
uniqueSum(Arr) -> uniqueSum(Arr, new(), 0).
uniqueSum([], _, S) -> S;
uniqueSum([H|T],Temp, S) ->
  case is_element(H, Temp) of
    true ->
      uniqueSum(T,Temp,S);
    false ->
      TempS = add_element(H,Temp),
      uniqueSum(T,TempS,S + H)
  end.

% function 4 unique sum method 2
uniqueSum2(Arr) -> lists:sum(lists:uniq(Arr)).

%function 5 with extraction of random Numbers
extractRandomN (L , N) -> extractRandomN(L, N, []).
extractRandomN (_, 0, Templ) -> Templ;
extractRandomN (L, N, Templ) ->
  R = rand:uniform(length(L)),
  Templ1 = lists:append(Templ,lists:sublist(L,R,1)),
  extractRandomN(lists:delete(lists:sublist(L,R,1),L), N-1, Templ1).


%function 6 with first fibonacci numbers
firstFibonacciElements (1)-> [1];
firstFibonacciElements (2)-> [1, 1];
firstFibonacciElements (N) -> firstFibonacciElements(N-2, [1,1]).
firstFibonacciElements (0, L) -> L;
firstFibonacciElements (N, L) ->
  L2 = lists:sublist(L,length(L)-1,2),
  Temp = lists:append(L,[lists:sum(L2)]),
  firstFibonacciElements(N-1,Temp).

%function 7 translator
translator(Dict, String) ->
  Lstring = string:split(String, " ", all),
  translator(Dict, Lstring, []).
translator(_, [], Temp)-> string:join(Temp," ");
translator(Dict, [H|T], Temp)->
  case dict:is_key(H, Dict) of
    true ->
      {_, Value} = dict:find(H,Dict),
      translator(Dict, T, lists:append(Temp,Value));
    false ->
      translator(Dict, T, lists:append(Temp,[H]))
  end.

%function 8 smallestNumber
smallestNumber(Arr)->
  smallestNumber(lists:sort(Arr),0,0).
smallestNumber([],N,_)->N;
smallestNumber([H|T],N,Z)->
  if
    H == 0 ->
      smallestNumber(T,N,Z+1) ;
    true ->
      Number = H*math:pow(10,Z),
      smallestNumber(T,N*10+Number,0)
  end.

%function 9 rotate left array
rotateLeft(Arr,0)->Arr;
rotateLeft([H|T], N) ->
  Arr = lists:append(T,[H]),
  rotateLeft(Arr, N-1).


%function 10 all a^2 + b^2 = c^2
listRightAngleTriangles () -> listRightAngleTriangles(1,[]).
listRightAngleTriangles (20,Arr) -> Arr;
listRightAngleTriangles (A,Arr) ->
  Arr1 = listRightAngleTriangles (A+1,Arr),
  Arr2 = listRightAngleTrianglesB (A, 1,Arr1),
  Arr2
.

listRightAngleTrianglesB (_, 20,Arr) -> Arr;
listRightAngleTrianglesB (A,B,Arr) ->
  C = round(math:sqrt(A*A + B*B)),
  case A*A + B*B == C*C of
    true -> ArrT = [{A,B,C}];
    false -> ArrT = []
  end,
%%  io:fwrite("~w ~w ~w ~n",[A,B,C]),
  Arr2 = listRightAngleTrianglesB (A,B+1,Arr),
  lists:append(Arr2,ArrT)
.



