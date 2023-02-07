%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Feb 2023 10:20 PM
%%%-------------------------------------------------------------------
-module(bonustask).
-author("KATCO").

%% API
-export([commonPrefix/1, checkPrefix/3]).
-export([toRoman/1]).
-export([factorize/1, getPrimes/1]).

commonPrefix (Strings) ->
  commonPrefix(lists:sort(fun(A,B) -> length(A) < length(B) end, Strings)," ").
commonPrefix([],Prefix) -> Prefix;
commonPrefix([H|T],Prefix) ->
%%  io:fwrite("~p prefix: ~p checkPrefix ~p ~n",[H,Prefix, checkPrefix([[X] || X <-Prefix],[[X] || X <-H],"")]),
  Temp = commonPrefix(T,checkPrefix([[X] || X <-Prefix],[[X] || X <-H],"")),
%%  io:fwrite("~p~n",[Temp]),
  Temp
.

checkPrefix([" "],String,_)-> lists:flatten(String);
checkPrefix([],_,Arr)->Arr;
checkPrefix(_,[],Arr)->Arr;
checkPrefix([H|T],[H1|T1],Arr) ->
  if H == H1
    -> checkPrefix(T,T1,string:concat(Arr,H));
    true -> Arr
  end
.


toRoman(String) ->
  {Num,_} = string:to_integer(String),
  AnsT = getThousands(Num),
  H = Num rem 1000,
  AnsH = getHundreds(H,AnsT),
  Tens = H rem 100,
  AnsTens = getTens(Tens,AnsH),
  U = Tens rem 10,
  getUnits(U,AnsTens)
.

getThousands(Num) ->
  case Num div 1000 of
    0 -> "";
    1 -> "M";
    2 -> "MM";
    3 -> "MMM";
    4 -> "MMMM"
  end.

getHundreds(Num,AnsT) ->
  case Num div 100 of
    0 -> string:concat(AnsT,"");
    1 -> string:concat(AnsT,"C");
    2 -> string:concat(AnsT,"CC");
    3 -> string:concat(AnsT,"CCC");
    4 -> string:concat(AnsT,"CD");
    5 -> string:concat(AnsT,"D");
    6 -> string:concat(AnsT,"DC");
    7 -> string:concat(AnsT,"DCC");
    8 -> string:concat(AnsT,"DCCC");
    9 -> string:concat(AnsT,"CM")
  end
.
getTens(Num,AnsT) ->
  case Num div 10 of
    0 -> string:concat(AnsT,"");
    1 -> string:concat(AnsT,"X");
    2 -> string:concat(AnsT,"XX");
    3 -> string:concat(AnsT,"XXX");
    4 -> string:concat(AnsT,"XL");
    5 -> string:concat(AnsT,"L");
    6 -> string:concat(AnsT,"LX");
    7 -> string:concat(AnsT,"LXX");
    8 -> string:concat(AnsT,"LXXX");
    9 -> string:concat(AnsT,"XC")
  end
.
getUnits(Num,AnsT) ->
  case Num of
    0 -> string:concat(AnsT,"");
    1 -> string:concat(AnsT,"I");
    2 -> string:concat(AnsT,"II");
    3 -> string:concat(AnsT,"III");
    4 -> string:concat(AnsT,"IV");
    5 -> string:concat(AnsT,"V");
    6 -> string:concat(AnsT,"VI");
    7 -> string:concat(AnsT,"VII");
    8 -> string:concat(AnsT,"VIII");
    9 -> string:concat(AnsT,"IX")
  end
.

factorize(N) ->
  factorize(N,[],getPrimes(N)).
factorize(N,Arr,[]) -> lists:append(Arr,[N]);
factorize(1,Arr,_) -> Arr;
factorize(N,Arr,[H|T]) ->
%%  io:fwrite(" ~w ~w ~w ~n",[N,Arr,H]),
  if N rem H == 0 ->
%%      io:fwrite(" ~w ~w ~w ~n",[N,Arr,H]),
        factorize(N div H,lists:append(Arr,[H]),getPrimes(N div H));
      true ->
        if N div H == 1 ->
          lists:append(Arr,[N]);
        true ->
          factorize(N,Arr,T)
        end
    end
.
getPrimes(N) ->
  lists:filter(fun(P)-> if P == 0 -> false; true -> true end end,
    lists:map(fun(El) -> case lab1:isPrime(El) of true -> El; false -> 0 end end, lists:seq(2,N))).
