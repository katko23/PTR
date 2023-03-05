# FAF.PTR16.1 -- Project 0
> **Performed by:** Cătălin Coșeru, group FAF-201 \
> **Verified by:** asist. univ. Alexandru Osadcenco

## P0W1

**Task 1** -- Hello world in erlang

```erlang
-module(helloworld).
-author("KATCO").

%% API
-export([helloworld/0]).

helloworld() -> io:fwrite("Hello World writed by Catalin").
```

Soo it's just a basic hello world program written in erlang.

**Task 2** -- Hello world unit test

```erlang
-module(helloworld_test).
-author("KATCO").
-import(helloworld,[helloworld/0]).
-include_lib("eunit/include/eunit.hrl").
%% API
-export([]).

helloworld_test() -> helloworld().
```

Is a unit testing module hello world, written in erlang and using lib eunit.

## P0W2

**Task 1** -- isPrime(N) ?

```erlang
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
```

Function in erlang for checking if N is a prime number.
This is an Erlang function named isPrime that takes an integer argument N and checks 
whether it is a prime number. It first handles cases where N is 0, 1, or 2, and 
returns false for 0 and 1, and true for 2. For all other cases, it calls a helper 
function isPrime(N, 2), which checks whether N is divisible by any number greater 
than 1 and less than or equal to N. If N is divisible by any such number, 
it returns false, otherwise it returns true.

**Task 2** -- Area of a cylinder

```erlang
cylinderArea (H, R) when H > 0; R > 0 ->
  2 * pi() * R * ( H + R ).
```

A simple program to compute the area of a cylinder knowing radius and height.

**Task 3** -- All right angle triangles where a,b,c is under 20.

```erlang
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
```

This is an Erlang program that generates a list of all right-angled triangles where all sides are integers and the lengths of two sides are a and b, and the length of the hypotenuse is c.

The program consists of two functions, listRightAngleTriangles and listRightAngleTrianglesB. The first function initializes a list and calls the second function with initial parameters A=1 and Arr=[]. The second function iterates through all possible values of a and b up to 20, computes the corresponding value of c using the Pythagorean theorem, and checks whether the resulting triangle is a right-angled triangle. If it is, the function adds the tuple {a,b,c} to the list. Finally, the two lists are appended together and returned as the output of the program.

**Task 4** -- All possible anagrams of a word.

```erlang
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

```

This is an Erlang program that takes a list of words as input and groups together all the words that are anagrams of each other. The program uses a dictionary data structure to store the anagram groups.

The groupAnagrams function takes two arguments: the list of words and an empty dictionary. It then iterates over the list of words and for each word, it first sorts the letters of the word into alphabetical order, then checks if the resulting sorted word is already in the dictionary. If it is, it appends the current word to the list of words associated with that sorted word in the dictionary. If it is not, it creates a new entry in the dictionary with the sorted word as the key and the current word as the first element in the list of words associated with that key.

The get_anagrams function is a helper function that takes a list of letters as input and returns a list of all possible permutations of those letters. It uses recursion and list comprehensions to generate the permutations.

**Task 5** -- Number to roman number format.

```erlang
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
```

This code defines a function that converts a given string of digits representing a decimal number into its Roman numeral representation. The string is first converted to an integer using string:to_integer/1, then broken down into thousands, hundreds, tens, and units, and each part is converted to its corresponding Roman numeral using simple lookup tables based on the digits. The Roman numeral representation is built up by concatenating the Roman numeral strings for each part.

**Task 6** -- Factorize a number.

```erlang
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
    lists:map(fun(El) -> case minimaltask:isPrime(El) of true -> El; false -> 0 end end, lists:seq(2,N))).

```

The factorize function takes an integer N and returns a list of prime factors that make up N. It first calls the getPrimes function to get all primes up to N. It then recursively factors N by dividing it by the smallest prime factors until all prime factors have been found. When N is not divisible by a prime factor, the function moves on to the next one until all prime factors have been tested.

The getPrimes function returns a list of primes up to N. It does this by filtering out all non-prime numbers in a list of numbers from 2 to N. It checks if each number is prime by calling the isPrime function from the minimaltask module, and if it is not prime, the number 0 is used to replace it in the list.


## P0W3

**Task 1** -- Queue :)

```erlang
new_queue() ->
  spawn(?MODULE, queueptr, [[]]).

queueptr(Arr) ->
  receive
    {From, {push, Value}} ->
      From ! {self(), ok},
      queueptr(lists:append(Arr,[Value]));
    {From, {pop}} ->
      From ! {self(), lists:last(Arr)},
      queueptr(lists:droplast(Arr));
    terminate ->
      ok
  end.

push(Pid, Value) ->
  Pid ! {self(), {push, Value}},
  receive
    {Pid, Msg} -> Msg
  end.

pop(Pid) ->
  Pid ! {self(), {pop}},
  receive
    {Pid, Msg} -> Msg
  end.
```

This is a simple implementation of a queue data structure in Erlang using processes. The new_queue/0 function creates a new queue by spawning a new process that manages the queue.

The queueptr/1 function is the process that manages the queue. It receives messages from other processes to push or pop items from the queue, and updates the internal representation of the queue accordingly.

The push/2 and pop/1 functions are used to interact with the queue. They send messages to the queue process to push or pop items, respectively, and wait for a response.

The queue is implemented as a list, with the head of the list representing the front of the queue and the tail of the list representing the back of the queue. Items are pushed to the back of the list and popped from the front of the list.

**Task 2** -- DLL list

```erlang
create_dlllist([H|T]) ->
  PID = spawn(fun() -> nodedll(nil,H,nil) end),
  create_dlllist(T,PID),
  PID
.

insert(PID, Value) ->
  NewPid = spawn(fun() -> nodedll(PID, Value ,nil) end),
  PID ! {insnext, NewPid},
  NewPid
.

create_dlllist([],_)->ok;
create_dlllist([H|T],Pred) ->
  NewPid = insert(Pred,H),
  create_dlllist(T, NewPid)
.

traverse(PID) ->
  PID ! {traverse,self(),[]},
  receive
    {traversed,Arr} -> Arr
  end
.

inverse(PID) ->
  PID ! {inverse,self(),[]},
  receive
    {inversed,Arr} -> Arr
  end
.

nodedll(Pred , Value , Next) ->
  receive
    {insnext, NextPid} ->
      nodedll(Pred, Value, NextPid);
    {delpred, PredPid} ->
      nodedll(PredPid, Value, Next);
    {traverse,From,Arr} ->
      if
        Next == nil -> From ! {traversed, Arr++[Value]}, nodedll(Pred, Value, Next);
        true -> Next ! {traverse,From,Arr++[Value]}, nodedll(Pred, Value, Next)
      end;
    {inverse,From,Arr} ->
      if
        Next == nil -> From ! {inversed, [Value] ++ Arr}, nodedll(Pred, Value, Next);
        true -> Next ! {inverse,From,[Value] ++ Arr}, nodedll(Pred, Value, Next)
      end
  end
.
```

This is a program that creates and manipulates a doubly linked list data structure using message passing between Erlang processes.

The create_dlllist/1 function takes a list as input and creates a doubly linked list from it. It does this by spawning a process that initializes the first node in the list with a nil predecessor, the head value of the list as its own value, and a nil successor. Then, it recursively calls insert/2 with the tail of the list and the PID of the initial node as arguments until all nodes in the list have been inserted.

The insert/2 function creates a new node with the given value and inserts it as the successor of the node with the given PID. It then sends a message to the predecessor node to update its successor to be the new node.

The traverse/1 function sends a message to the given PID to start traversing the list from the beginning. The nodes in the list send messages to their successors to continue the traversal until the last node is reached, at which point the final list of values is sent back to the traverse function.

The inverse/1 function works in a similar way to traverse/1, but the order of the list is reversed during traversal.

The nodedll/3 function is the main processing function for each node in the list. It waits to receive messages from other nodes to insert or delete nodes or to traverse or inverse the list. Depending on the message received, it sends messages to its predecessor or successor to update the linkages between the nodes or to continue traversing or inverting the list.


## P0W4

**Task 1** -- Main task - chain of actors.

```erlang
splitbyspace(I) ->
  if I == 0 ->
    Changepid = spawn(fun() -> changenm(0) end),
    io:fwrite("Pid of changenm is ~p ~n", [Changepid]),
    link(Changepid);
    true ->
      Changepid = I
  end,
  receive
    {String} ->
      Changepid ! {splited,string:tokens(String, [$\s])},
      splitbyspace(Changepid)
  end.

changenm(I) ->
  if I == 0 ->
    Printpid = spawn(fun() -> print() end),
    io:fwrite("Pid of print is ~p ~n", [Printpid]),
    link(Printpid);
    true ->
      Printpid = I
  end,
  receive
    {splited, ListString} ->
      String = lists:flatten(lists:map(fun(El) -> El ++ " " end,ListString)),
      Liststr = string:replace(string:to_lower(String),"m","n", all),
      Ans = lists:flatten(lists:map(fun(El) -> if length(El) > 1 ->lists:flatten(string:replace(El,"n","m", all)); true -> El end end, Liststr)),
      Printpid ! {changed,Ans},
      changenm(Printpid)
  end
.

print() ->
  receive
    {changed, Ans} ->
      io:fwrite("Changed String is -> ~p ~n", [Ans]),
      print()
  end.

create_function() ->
  {PID,_Ref} = spawn_monitor(?MODULE,splitbyspace, [0]),
  io:fwrite("Pid of splitbyspace is ~p ~n", [PID]),
  supervisor_functions(PID).

supervisor_functions(PID) ->
  receive
    {'DOWN', _Ref, process, Pid, Why} ->
      io:format("Worker ~w went down: ~s~n", [Pid, Why]),
      {PIDN,_Refer} = spawn_monitor(?MODULE,splitbyspace, [0]),
      io:fwrite("Pid of splitbyspace is ~p ~n", [PID]),
      supervisor_functions(PIDN);
    String ->
      PID ! {String},
      supervisor_functions(PID)
  end.
```

This code defines three processes: splitbyspace/1, changenm/1, and print/0. It also defines a supervisor function create_function/0 which creates and supervises splitbyspace/1 processes.

The splitbyspace/1 function receives an input value I and if it's the first call, it creates a new process changenm/1 and links it to splitbyspace/1. It then enters an infinite loop where it waits for a message containing a string. When it receives a string, it sends it to the changenm/1 process and waits for a response. It then loops again and waits for the next string.

The changenm/1 function also enters an infinite loop where it waits for a message containing a list of strings. It then concatenates the list of strings into a single string, replaces all occurrences of the letter "m" with "n", and then replaces all occurrences of the letter "n" with "m" if the length of the substring is greater than 1. It then sends the resulting string to the print/0 process and loops again, waiting for the next list of strings.

The print/0 function enters an infinite loop where it waits for a message containing a changed string. It then prints the changed string to the console and loops again, waiting for the next changed string.

The create_function/0 function creates a splitbyspace/1 process and then enters an infinite loop where it waits for a message. If the message is a string, it sends it to the splitbyspace/1 process. If a splitbyspace/1 process terminates, it creates a new splitbyspace/1 process and continues listening for messages.

**Task 2** -- Bonus task - Sensors , and supervisors (supervision tree)

```erlang
create_mainsensor() ->
  WheelSens =  spawn_monitor(?MODULE, create_wheelsensor, []),
  {WheelPID, _} = WheelSens,
  register(wheel, WheelPID),
  CabinSens =  spawn_monitor(?MODULE, cabinsensor, []),
  {CabinPID, _} = CabinSens,
  register(cabin,CabinPID),
  MotorSens =  spawn_monitor(?MODULE, motorsensor, []),
  {MotorPID, _} = MotorSens,
  register(motor,MotorPID),
  ChasisSens = spawn_monitor(?MODULE, chasissensor, []),
  {ChasisPID, _} = ChasisSens,
  register(chasis, ChasisPID),
  Arr = [],
  mainsensor(Arr, whereis(wheel), whereis(cabin), whereis(motor), whereis(chasis))
.

mainsensor(BrokenSensors, WheelS, CabinS, MotorS, ChasisS) ->
  if length(BrokenSensors) >2 ->
    io:fwrite("DEPLOY AIRBAGS !!!!!!");
    true->
      ok
  end,
  receive
    {'DOWN', Ref, process, PID, _Why} ->
      case PID == WheelS of
        true ->
          io:fwrite("Wheel sensor is down ~n"),
          WheelSens = spawn_monitor(?MODULE, create_wheelsensor, []),
          {WheelPID, _} = WheelSens,
          spawn(?MODULE, timemanagement, [WheelPID, {wheelsens}]),
          mainsensor(lists:append(BrokenSensors,[{wheelsens}]), WheelPID, CabinS, MotorS, ChasisS);
        false ->
          ok
      end,
      case PID == CabinS of
        true ->
          io:fwrite("Cabin sensor is down ~n"),
          CabinSens = spawn_monitor(?MODULE, cabinsensor, []),
          {CabinPID, _} = CabinSens,
          spawn(?MODULE, timemanagement, [CabinPID, {cabinsens}]),
          mainsensor(lists:append(BrokenSensors,[{cabinsens}]), WheelS, CabinPID, MotorS, ChasisS);
        false ->
          ok
      end,
      case PID == MotorS of
        true ->
          io:fwrite("Motor sensor is down ~n"),
          MotorSens = spawn_monitor(?MODULE, motorsensor, []),
          {MotorPID, _} = MotorSens,
          spawn(?MODULE, timemanagement, [MotorPID, {motorsens}]),
          mainsensor(lists:append(BrokenSensors,[{motorsens}]), WheelS, CabinS, MotorPID, ChasisS);
        false -> ok
      end,
      case PID == ChasisS of
        true ->
          io:fwrite("Chasis sensor is down ~n"),
          ChasisSens = spawn_monitor(?MODULE, chasissensor, []),
          {ChasisPID, _} = ChasisSens,
          spawn(?MODULE, timemanagement, [ChasisPID, {chasissens}]),
          mainsensor(lists:append(BrokenSensors,[{chasissens}]), WheelS, CabinS, MotorS, ChasisPID);
        false -> ok
      end,
      io:fwrite("~w ~w ~n",[PID,Ref]),
      mainsensor(BrokenSensors, WheelS, CabinS, MotorS, ChasisS);
    {showpids} ->
      io:fwrite("Wheel pid ~p~n",[WheelS]),
      io:fwrite("Cabin pid ~p~n",[CabinS]),
      io:fwrite("Motor pid ~w~n",[MotorS]),
      io:fwrite("Chasis pid ~w~n",[ChasisS]),
      mainsensor(BrokenSensors, WheelS, CabinS, MotorS, ChasisS);
    Other ->
      case lists:member(Other, BrokenSensors) of
        true ->
          mainsensor(lists:delete(Other,BrokenSensors),  WheelS, CabinS, MotorS, ChasisS);
        false ->
          mainsensor(BrokenSensors,  WheelS, CabinS, MotorS, ChasisS)
      end
  end
.

timemanagement(From,Sens) ->
  timer:sleep(500),
  From ! Sens
.

create_wheelsensor() ->
  Wheels = [  % { {Pid, Ref}, Id }
    { spawn_monitor(?MODULE, wheel, [Id]), Id }
    || Id <- lists:seq(1,4)
  ],
  wheelsensor(Wheels).

wheelsensor(Wheels) ->
  receive
    {'DOWN', Ref, process, Pid, Why} ->
      CrashedSensor = {Pid, Ref},
      Restart = replaceWheel(CrashedSensor, Wheels, Why),
      wheelsensor(Restart);
    _Other ->
      wheelsensor(Wheels)
  end.

replaceWheel(CrashedSensor, Wheels, Why) ->
  lists:map(fun(PidRefId) ->
    { {Pid,_Ref}=Wheel, Id} = PidRefId,
    case Wheel =:= CrashedSensor of
      true ->  %replace worker
        io:format("Wheel ~w (~w) went down: ~s~n",
          [Id, Pid, Why]),
        {spawn_monitor(?MODULE, wheel, [Id]), Id}; %=> { {Pid,Ref}, Id }
      false ->  %leave worker alone
        PidRefId
    end
            end,
    Wheels).

```

This code implements a sensor system for a vehicle, which includes wheel, cabin, motor, and chassis sensors. The create_mainsensor function starts the system by creating and registering all the sensors, and then calls the mainsensor function to manage them. The mainsensor function listens for sensor failures and restarts them as necessary. It also keeps track of broken sensors and triggers an alarm if more than two sensors are broken. The timemanagement function is a helper function that sends a message to a sensor after a short delay.

The create_wheelsensor function creates four wheel sensors, each of which is a worker process. The wheelsensor function receives messages from the workers and restarts them if they fail. The replaceWheel function is a helper function used by wheelsensor to replace a failed worker with a new one.

Overall, this code is an example of fault-tolerant programming, where the system is designed to handle failures and continue functioning despite them.

## P0W5

**Task 1** -- From HTML get quotes and save in json.

```erlang
et_quotes() ->
  inets:start(),
  {ok, {{Version, StatusCode, _Mess}, Headers, Body}} = httpc:request(get, {"http://quotes.toscrape.com", []}, [],[]),
  io:format("HTTP Version: ~s~n", [Version]),
  io:format("Status Code: ~p~n", [StatusCode]),
  io:format("Headers: ~p~n", [Headers]),
  io:format("Body: ~s~n", [Body]),
  Document = xmerl_scan:string(Body),
  io:format("Doc is : ~s~n", [Document])
.

get_quotes3() ->
  inets:start(),
  {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} = httpc:request(get, {"http://quotes.toscrape.com/", []}, [], []),
  Quotes = mochiweb_html:parse(Body),
%%  io:format("~p~n", [Quotes]),
  Parsed = mochiweb_xpath:execute("//span[@class='text']",Quotes),
%%  Parsed = mochiweb_xpath:execute("<span class=\"text\">(.*?)</span>",ParsedQuote),
  Text = lists:map(fun({_,_,T}) -> lists:flatten(erlang:binary_to_list(lists:nth(1, T))) end,Parsed),
%%  io:format("~s~n", [Text]),
  ParsedAuth = mochiweb_xpath:execute("//small[@class='author']",Quotes),
  Auth = lists:map(fun({_,_,T}) -> lists:flatten(erlang:binary_to_list(lists:nth(1, T))) end,ParsedAuth),
%%  io:format("~s~n", [Auth]),
  ParsedTag = mochiweb_xpath:execute("//div[@class='tags']",Quotes),
  Tags = lists:map(fun(El)-> Taguri = mochiweb_xpath:execute("//a[@class='tag']",El), lists:append(lists:map(fun({_,_,T}) -> lists:nth(1, T) end,Taguri),[]) end,ParsedTag),
%%  Tags = lists:map(fun({_,_,T}) -> T end,ParsedTags),
%%  io:format("~p~n", [Tags])
  save_to_map(Text,Auth,Tags)
.

save_to_map(Quotes,Actors,Tags) ->
  save_to_map(Quotes,Actors,Tags,[]).

save_to_map([],[],[],Map) -> Map;
save_to_map([QH|QT],[AH|AT],[TH|TT],MapL) ->
  Map = #{},
  Map1 = maps:put("Quote:", QH, Map),
  Map2 = maps:put("Auth:", AH, Map1),
  Map3 = maps:put("Tag:", TH, Map2),
  save_to_map(QT,AT,TT,lists:append(MapL,[Map3])).


write_json_file(Map) ->
  {ok, JsonFile} = file:open("example.json", [write]),
  JsonStr = lists:flatten(io_lib:format("~ts", [erlang:binary_to_list(jiffy:encode(Map))])),
  ok = file:write(JsonFile, JsonStr),
  file:close(JsonFile).
```

This is a set of functions written in Erlang to scrape quotes from the website http://quotes.toscrape.com/ and save them to a JSON file.

The get_quotes3/0 function sends a GET request to the website and uses mochiweb_html and mochiweb_xpath libraries to parse and extract the quotes, authors and tags from the HTML response. It then calls the save_to_map/3 function to store the scraped data in a map.

The save_to_map/4 function takes the lists of quotes, actors, and tags, and recursively constructs a list of maps with keys "Quote:", "Auth:", and "Tag:", respectively.

Finally, the write_json_file/1 function encodes the list of maps as a JSON string using the jiffy:encode/1 function, writes it to a file named "example.json" using the file:write/2 function, and closes the file using the file:close/1 function.

**Task 2** -- Main - server in cowboy

```erlang
init(_Transport, Req) ->
  {cowboy_rest, Req, undefined}.

allowed_methods(Req, _State) ->
  {["GET", "POST", "PUT", "PATCH", "DELETE"], Req, undefined}.

content_types_accepted(Req, _State) ->
  {[{"application/json", handle_post}], Req, undefined}.

content_types_provided(Req, _State) ->
  {[{"application/json", to_json}], Req, undefined}.


handle_get(Req, State) ->
  {Id, Req1} = cowboy_req:binding(id, Req),
  case Id of
    undefined -> % GET /movies
      {to_json(get_all_movies()), Req1, State};
    _ -> % GET /movies/:id
      {to_json(get_movie_by_id(Id, Req1), Req1), Req1, State}
  end.


handle_post(Req, State) ->
  {Movie, Req1} = cowboy_req:body(Req),
  {ok, NewMovieId} = add_movie(Movie),
  {to_json(get_movie_by_id(NewMovieId, Req1), Req1), Req1, State}.

handle_put(Req, State) ->
  {Id, Req1} = cowboy_req:binding(id, Req),
  {Movie, Req2} = cowboy_req:body(Req1),
  update_movie(Id, Movie),
  {to_json(get_movie_by_id(Id, Req2), Req2), Req2, State}.

handle_patch(Req, State) ->
  {Id, Req1} = cowboy_req:binding(id, Req),
  {MovieUpdates, Req2} = cowboy_req:body(Req1),
  update_movie(Id, MovieUpdates),
  {to_json(get_movie_by_id(Id, Req2), Req2), Req2, State}.

handle_delete(Req, State) ->
  {Id, Req1} = cowboy_req:binding(id, Req),
  delete_movie(Id),
  {to_json(get_all_movies()), Req1, State}.

%% Add a new movie to the list
add_movie(Req) ->
  {ok, Body, _} = cowboy_req:body(Req),
  Movie = jiffy:decode(Body),
  NewMovie = #movie{
    id = erlang:unique_integer([positive,monotonic]),
    title = maps:get("title",Movie),
    release_year = maps:get("release_year",Movie),
    director = maps:get("director",Movie)
  },
  NewList = [NewMovie | movies],
  {ok, NewMovie, NewList}.

%% Get all movies
get_all_movies() ->
  movies.

%% Delete a movie by ID
delete_movie(Id) ->
  case lists:keydelete(Id, #movie.id, movies) of
    {value, _Movie, NewList} ->
      movies = NewList;
    error ->
      movies
  end.

%% Get a movie by ID
get_movie_by_id(Id, Req) ->
  case lists:keyfind(Id, #movie.id, movies) of
    {Movie} ->
      Movie;
    false ->
      cowboy_req:reply(404, #{<<"error">> => <<"Movie not found">>}, Req),
      halt
  end.

%% Update a movie by ID
update_movie(_Id, _MovieUpdates) ->
%    case lists:keyfind(Id, #movie.id, movies) of
%        {OldMovie} ->
%            UpdatedMovie = jiffy:decode(Body),
%    	    NewMovie = #movie{
%        	id = erlang:unique_integer([positive,monotonic]),
%        	title = maps:get("title",Movie),
%        	release_year = maps:get("release_year",Movie),
%        	director = maps:get("director",Movie)
%    	    }
%            NewList = lists:keyreplace(Id, #movie.id, movies, UpdatedMovie),
%            {ok, to_json(UpdatedMovie, Req), Req, NewList};
%        false ->
  {<<"404 Not Found">>, movies}
%    end
.

to_json(Data, Req) ->
  {ok, Body, _} = jiffy:encode(Data),
  {Body, Req}.

to_json(Data) ->
  jiffy:encode(Data).

```

This code implement a REST API using the Cowboy Erlang HTTP server. It defines several handler functions for different HTTP methods (GET, POST, PUT, PATCH, DELETE) that perform different operations on a list of movies.

The init function is used to initialize the REST handler, and it simply returns a tuple containing the cowboy_rest atom, the HTTP request object Req, and the undefined state.

The allowed_methods function is used to specify which HTTP methods are allowed for the current request. In this case, all methods are allowed.

The content_types_accepted function is used to specify which content types the server can accept for the current request. In this case, only JSON data is accepted, and it is handled by the handle_post function.

The content_types_provided function is used to specify which content types the server can provide for the current request. In this case, only JSON data is provided, and it is handled by the to_json function.

The handle_get function is used to handle GET requests, and it checks if an ID parameter is present in the request URL. If it is not present, all movies are returned. Otherwise, the movie with the specified ID is returned.

The handle_post function is used to handle POST requests, and it adds a new movie to the list of movies.

The handle_put function is used to handle PUT requests, and it updates an existing movie in the list of movies.

The handle_patch function is used to handle PATCH requests, and it updates an existing movie in the list of movies with partial updates.

The handle_delete function is used to handle DELETE requests, and it deletes an existing movie from the list of movies.

The add_movie function is used to decode the JSON data in the request body, create a new movie record with a unique ID, and add it to the list of movies.

The get_all_movies function simply returns the list of all movies.

The delete_movie function deletes a movie from the list of movies with the specified ID.

The get_movie_by_id function returns the movie with the specified ID. If the movie is not found, it returns a 404 error.

The update_movie function is currently incomplete and commented out. It is intended to update an existing movie in the list of movies with new data, but it is not clear from the code how this is intended to be done.

Finally, the to_json function is used to encode data in JSON format using the jiffy library. It can be used to encode both the response data and the data in the request body.

## Conclusion

Carrying out the first laboratory in the Real-Time Programming course, I encountered a new type of programming language called functional. That's how I got to know the Erlang language and I suffered creating programs in this environment, using recursion instead of for, while or repeat cycles. I also noticed the difference between the implementation of some programs in object-oriented languages or imperative procedural languages compared to writing similar functions in the Erlang functional language.

## Bibliography

https://www.tutorialspoint.com/erlang/erlang_environment.htm
https://www.erlang.org/docs/25/
https://learnyousomeerlang.com/content
https://learnyousomeerlang.com/starting-out-for-real
https://medium.com/erlang-central/building-your-first-erlang-app-using-rebar3-25f40b109aad
https://rebar3.org/docs/getting-started/
https://elixirforum.com/t/erl-exe-is-not-recognized-as-an-internal-or-external-command/34893/3
https://www.erlang.org/doc/apps/erts/crash_dump.html#reasons-for-crash-dumps--slogan-
https://www.tutorialspoint.com/erlang/erlang_recursion.htm
https://learnyousomeerlang.com/designing-a-concurrent-application#an-event-module
https://habr.com/ru/post/173595/
https://github.com/ninenines/cowboy
https://www.davekuhlman.org/rebar3-cowboy-rest-template.html
https://ninenines.eu/docs/en/cowboy/2.8/manual/cowboy_req.binding/
https://developer.spotify.com/documentation/web-api/reference/#/
https://developer.spotify.com/documentation/web-api/
https://stackoverflow.com/questions/25748917/how-to-do-a-simple-http-post-get-with-header-using-erlang-without-a-library-if


