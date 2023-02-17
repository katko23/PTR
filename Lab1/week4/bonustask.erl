%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Feb 2023 7:52 PM
%%%-------------------------------------------------------------------
-module(bonustask).
-author("KATCO").

%% API
-export([create_mainsensor/0, mainsensor/5, wheel/1, create_wheelsensor/0, cabinsensor/0, motorsensor/0, chasissensor/0, timemanagement/2]).

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

wheel(ID) ->
%%  Data = rand:uniform(10),
%%  if Data > 9 ->
%%    exit("Too big data");
%%    true ->
      wheel(ID)
%%  end
.

cabinsensor() ->
%%  Data = rand:uniform(200),
%%  if Data > 180 ->
%%    exit("Too big data");
%%  true ->
    cabinsensor()
%%  end
.

motorsensor() ->
%%  Data = rand:uniform(200),
%%  if Data > 180 ->
%%    exit("Too big data");
%%  true ->
  motorsensor()
%%  end
.

chasissensor() ->
%%  Data = rand:uniform(200),
%%  if Data > 180 ->
%%    exit("Too big data");
%%  true ->
  chasissensor()
%%  end
.

%%1> c(bonustask).
%%%%{ok,bonustask}
%%2> PID = spawn(bonustask, create_mainsensor, []).
%%%%<0.87.0>
%%3> PID ! {showpids}.
%%%%Wheel pid <0.88.0>
%%%%Cabin pid <0.89.0>
%%%%Motor pid <0.90.0>
%%%%{showpids}
%%%%Chasis pid <0.91.0>
%%4> exit(<0.88.0>,shutdown).
%%%%Wheel sensor is down
%%%%true
%%5> PID ! {showpids}.
%%%%Wheel pid <0.98.0>
%%%%Cabin pid <0.89.0>
%%%%Motor pid <0.90.0>
%%%%{showpids}
%%%%Chasis pid <0.91.0>
%%6> exit(<0.98.0>,shutdown).
%%%%Wheel sensor is down
%%%%true
%%7> exit(<0.89.0>,shutdown).
%%%%Cabin sensor is down
%%%%true
%%%%DEPLOY AIRBAGS !!!!!!
