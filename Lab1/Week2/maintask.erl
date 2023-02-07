%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Feb 2023 10:18 PM
%%%-------------------------------------------------------------------
-module(maintask).
-author("KATCO").

%% API
-export([removeConsecutiveDuplicates/1, lineWords/1, words_in_one_row/1]).
-export([encode/2, decode/2, encode2/2, decode2/2, encMsg/2, caesar/2]).
-export([lettersCombinations/1]).
-export([groupAnagrams/1, get_anagrams/1]).


%function 11 remove cons duplicates
removeConsecutiveDuplicates(Arr) -> removeConsecutiveDuplicates(Arr, []).
removeConsecutiveDuplicates([],Arr) -> Arr;
removeConsecutiveDuplicates([H|T],Arr) ->
  HN = lists:sublist(T, 1, 1),
  HL = [H],
%%  io:fwrite("~w ~w ~n",[H,HN]),
  if
    HL /= HN ->
      ArrN = lists:append(Arr,[H]);
    true ->
      ArrN = Arr
  end ,
  removeConsecutiveDuplicates(T,ArrN).

%Main Tasks
%lineWords function 12
lineWords(Arr) -> lineWords(Arr, []).
lineWords([], Ans) -> Ans;
lineWords([H|T],Ans) ->
  case
    checkRowString(stringToList(string:to_lower(H)), 0) of
    true ->
      AnsN = lists:append(Ans,[H]),
      lineWords(T,AnsN);
    false -> lineWords(T,Ans)
  end
.
checkRowString([], _) -> true;
checkRowString([H|T], I) ->
  Ar1 = ['a','s','d','f','g','h','j','k','l'],
  Ar2 = ['q','w','e','r','t','y','u','i','o','p'],
  Ar3 = ['z','x','c','v','b','n','m'],
  case I of
    1 ->
      case  lists:member(H, Ar1) of
        true ->
          checkRowString(T,1);
        false ->
          false
      end;
    2 ->
      case  lists:member(H, Ar2) of
        true ->
          checkRowString(T,2);
        false ->
          false
      end;
    3 ->
      case  lists:member(H, Ar3) of
        true ->
          checkRowString(T,3);
        false ->
          false
      end;
    0 ->
      case  lists:member(H, Ar1) of
        true ->
          checkRowString(T,1);
        false ->
          false
      end,
      case  lists:member(H, Ar2) of
        true ->
          checkRowString(T,2);
        false ->
          false
      end,
      case  lists:member(H, Ar3) of
        true ->
          checkRowString(T,3);
        false ->
          false
      end
  end.
stringToList(String)->stringToList(String,[]).
stringToList("",Arr) -> Arr;
stringToList(String,Arr) ->
  Substr = string:sub_string(String, 1, 1),
  ArrN = lists:append(Arr,[Substr]),
  stringToList(string:sub_string(String,2,length(String)),ArrN).

words_in_one_row(Words) ->
  [Word || Word <- Words, in_one_row(string:to_lower(Word))].

in_one_row(Word) ->
  Row1 = "qwertyuiop",
  Row2 = "asdfghjkl",
  Row3 = "zxcvbnm",
  case lists:filter(fun(C) -> lists:member(string:to_lower(C), Row1) end, Word) of
    [] -> false;
    _ -> true
  end,
  case lists:filter(fun(C) -> lists:member(string:to_lower(C), Row2) end, Word) of
    [] -> false;
    _ -> true
  end,
  case lists:filter(fun(C) -> lists:member(string:to_lower(C), Row3) end, Word) of
    [] -> false;
    _ -> true
  end.


%Cypher code functions 13
encode(String,N)->
  Arr = [[X] || X <- String],
  changeByN(Arr,N, [])
.

decode(String,N)->
  Arr = [[X] || X <- String],
  changeByN(Arr, -N, [])
.

changeByN([],_,ArrN) -> ArrN;
changeByN([H|T],N,ArrN) ->
  io:fwrite("~p ~n",[H]),
  El = shift_char(H, N, $a, $z),
  changeByN(T,N,lists:append(ArrN, El))
.

shift_char(C, Shift, Upper, Lower) ->
  io:fwrite("~p ~p ~p ~p ~n",[C,Shift,Upper,Lower]),
  NC = lists:flatten(io_lib:format("~w~w",[C,Shift])),
  lists:sum(NC)
.

encode2(PlainText, Shift) ->
  [shift_char2(C, Shift) || C <- string:to_list(string:strip(PlainText))].

decode2(PlainText, Shift) ->
  [shift_char2(C, -Shift) || C <- string:to_list(string:strip(PlainText))].

shift_char2(C, Shift) ->
  case C of
    $a -> shift_char2(C, Shift, $a, $z);
    $A -> shift_char2(C, Shift, $A, $Z);
    _  -> C
  end.

shift_char2(C, Shift, Lower, Upper) ->
  case C + Shift of
    N when N > Upper -> Lower + (N - Upper - 1);
    N when N < Lower -> Upper - (Lower - N - 1);
    N -> N
  end.

enc(Char,Key) when (Char >= $A) and (Char =< $Z) or
  (Char >= $a) and (Char =< $z) ->
  Offset = $A + Char band 32, N = Char - Offset,
  Offset + (N + Key) rem 26;

enc(Char, _Key) ->  Char.

encMsg(Msg, Key) ->
  lists:map(fun(Char) -> enc(Char, Key) end, Msg).

caesar(Message, Key) ->

  Encode = (Key),
  Decode = (-Key),
  Range = lists:seq(1,26),

  io:format("Message: : ~s~n", [Message]),
  Encrypted = encMsg(Message, Encode),
  Decrypted = encMsg(Encrypted, Decode),

  io:format("Encrypted:  ~s~n", [Encrypted]),
  io:format("Decrypted: ~s~n", [Decrypted]),
  io:format("Solution: "),
  lists:foreach(fun(N) ->
    Encr = encMsg(Message, N),
    io:format("~p",[Encr])
                end, Range).

%%lettersCombinations(Digits) ->
%%  lettersCombinations(Digits, []).
%%lettersCombinations([], Acc) -> Acc;
%%lettersCombinations([Digit|Digits], Acc) ->
%%  NewAcc = [lists:append(X, [DigitToLetter || DigitToLetter <- lettersForDigit(Digit)]) || X <- Acc],
%%  lists:flatten(lettersCombinations(Digits, NewAcc)).
%%
%%lettersForDigit(Digit) when Digit >= '2' andalso Digit =< '9' ->
%%  lists:map(fun (N) -> integer_to_list(N + 96) end, lists:seq(0, 3)).


%%lettersCombinations(Numbers) ->
%%  lettersCombinations(Numbers, "", []).
%%lettersCombinations([], Acc, Acc) -> Acc;
%%lettersCombinations([H|T], Acc, Result) ->
%%  Keypad = [
%%    ["a", "b", "c"],
%%    ["d", "e", "f"],
%%    ["g", "h", "i"],
%%    ["j", "k", "l"],
%%    ["m", "n", "o"],
%%    ["p", "q", "r", "s"],
%%    ["t", "u", "v"],
%%    ["w", "x", "y", "z"]
%%  ],
%%  Combinations = Keypad[list_to_integer(H)],
%%lists:flatmap(fun(S) -> [Acc ++ S | lettersCombinations(T, Acc ++ S, Result)] end,Combinations)
%%.


% function 14 with lettersCombinations
lettersCombinations(Numbers) -> lettersCombinations([[X] || X <- Numbers],[]).
lettersCombinations([],Arr) -> [Arr];
lettersCombinations([H|T],Arr) ->
  lists:flatmap(fun(N) ->
    lettersCombinations(T,lists:append(Arr,[N]))
%%    io:format("~p",[Encr])
                end, number_to_letters(H))
.

number_to_letters(A) ->
  case A of
    "2" -> "abc";
    "3" -> "def";
    "4" -> "ghi";
    "5" -> "jkl";
    "6" -> "mno";
    "7" -> "pqrs";
    "8" -> "tuv";
    "9" -> "wxyz"
  end.

%%groupAnagrams ([" eat " , " tea " , " tan " , " ate " , " nat " , " bat "]) -> {
%%  " abt ": [" bat "] ,
%%  " ant ": [" nat " , " tan "] ,
%%  " aet ": [" ate " , " eat " , " tea "]
%%  }


% function 15 grouping anagrams , in otherwords is permutation
groupAnagrams(Words) -> groupAnagrams(Words,dict:new()).
groupAnagrams([],Dict) -> Dict;
groupAnagrams([H|T],Dict) ->
%%  io:fwrite("~p~n",[Dict]),
  Anagrams = get_anagrams(lists:sort([[X] || X <- H])),
  [HN|_] = Anagrams,
  case dict:is_key(HN, Dict) of
    true ->
      {_,Value} = dict:find(HN,Dict),
%%      io:fwrite("~p~n",[DictN]),
      LN = lists:append(Value,[H]),
      NextDict = dict:store(HN,LN,Dict)
    ;
    false ->
      NextDict = dict:store(HN,[H],Dict)
  end,
  groupAnagrams(T,NextDict)
.
%get all the permutations
get_anagrams([]) -> [[]];
get_anagrams(L) -> [lists:flatten([H|T]) || H <- L, T <- get_anagrams(L--[H])].


%%%get commonPrefix
%%commonPrefix (Strings) ->
%%%%  io:fwrite("Initial List ~p~n",[Strings]),
%%  findPrefix(lists:sort(fun(A,B) -> length(A) < length(B) end,Strings), "").
%%findPrefix([], Prefix) ->
%%  Prefix;
%%findPrefix([String|Strings], Prefix) ->
%%  if Prefix =/= nomatch ->
%%    io:fwrite("~p~p~n",[String,Prefix]),
%%    Sufix = string:prefix(String, Prefix),
%%    io:fwrite("Sufixul e ~p~n",[Sufix]),
%%    if Sufix == String -> SufixN = length(String) - 1;
%%      true -> SufixN = string:str(String,Sufix)
%%    end,
%%    findPrefix(Strings, string:sub_string(String,1,SufixN));
%%  true ->
%%    io:fwrite("~p~p~n",[String,Strings])
%%  end
%%.
