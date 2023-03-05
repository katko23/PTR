%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Feb 2023 11:56 PM
%%%-------------------------------------------------------------------
-module(minimaltasks).
-author("KATCO").

%% API
-export([get_quotes/0, get_quotes2/0, extract_quotes_2/1, get_quotes3/0, save_to_map/3, write_json_file/1]).

get_quotes() ->
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
%%%%  {ok, File} = file:open("example.json", [write, binary]),
%%%%  JsonData = jsx:encode(Map),
%%  application:ensure_all_started(jiffy),
%%  Json = jiffy:encode(Map),
%%  % Write the JSON to a file
%%  file:write_file("data.json", Json).
%%%%  io:fwrite(File, "~s", [JsonData]),
%%%%  file:close(File).


get_quotes2() ->
  inets:start(),
  {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} = httpc:request(get, {"http://quotes.toscrape.com/", []}, [], []),
  Quotes = parse_quotes(Body),
  io:format("~p~n", [Quotes]).

parse_quotes(Body) ->
  try Quotes = re:run(Body, "<div class=\"quote\">(.*?)</div>", [{capture, all, list}]) of
    {match, _} ->
  lists:map(fun(Q) ->
    io:fwrite("~p~n",[Q]),
    Author = case re:run(element(2, Q), "<small class=\"author\">(.*?)</small>", [{capture, all, list}]) of
               {match, [AuthorStr]} -> AuthorStr;
               nomatch -> ""
             end,
    Quote = case re:run(element(2, Q), "<span class=\"text\">(.*?)</span>", [{capture, all, list}]) of
              {match, [QuoteStr]} -> QuoteStr;
              nomatch -> ""
            end,
    Tags = case re:run(element(2, Q), "<a href=\"/tag/(.*?)\" class=\"tag\">(.*?)</a>", [{capture, all, list}]) of
             {match, TagPairs} -> [Tag || {_, Tag} <- TagPairs];
             nomatch -> []
           end,
    io:format("Author : ~p~n Quote: ~p~n Tag : ~p~n~n", [Author, Quote, Tags]),
    #{author => Author, quote => Quote, tags => Tags}
            end, Quotes);
  nomatch -> []
catch
_:_ ->
[]
end.


%%parse_quotes(Body) ->
%%  Lines = string:tokens(Body, "\n"),
%%  io:format("~p~n", [Lines]),
%%Quotes = parse_quotes(Lines, []),
%%  lists:reverse(Quotes).
%%
%%parse_quotes([], Quotes) -> Quotes;
%%parse_quotes([Line | Rest], Quotes) ->
%%  case string:substr(Line, 1, 9) of
%%    "<div class" ->
%%      Author = parse_author(Line),
%%      {Text, Tags} = parse_text_and_tags(Rest),
%%      Quote = #{author => Author, text => Text, tags => Tags},
%%      parse_quotes(Rest, [Quote | Quotes]);
%%    _ ->
%%      parse_quotes(Rest, Quotes)
%%  end.
%%
%%parse_author(Line) ->
%%  case re:run(Line, "<span class=\"author\">(.+)</span>", [{capture, [1]}]) of
%%    {match, [Author]} ->
%%      Author;
%%    nomatch ->
%%      unknown
%%  end.
%%
%%parse_text_and_tags([Line | Rest]) ->
%%  case string:substr(Line, 1, 16) of
%%    "<span class=\"text" ->
%%      {Text, Rest1} = parse_text(Line, Rest),
%%      Tags = parse_tags(Rest1),
%%      {Text, Tags};
%%    _ ->
%%      parse_text_and_tags(Rest)
%%  end.
%%
%%parse_text(Line, Rest) ->
%%  case re:run(Line, "<span class=\"text\">(.+)</span>", [{capture, [1]}]) of
%%    {match, [Text]} ->
%%      {Text, Rest};
%%    nomatch ->
%%      {unknown, Rest}
%%  end.
%%
%%parse_tags([Line | Rest]) ->
%%  case string:substr(Line, 1, 14) of
%%    "<div class=\"tags" ->
%%      parse_tags_line(Line, []) ++ parse_tags(Rest);
%%    _ ->
%%      []
%%  end.
%%
%%parse_tags_line(Line, Tags) ->
%%  case re:run(Line, "<a href=\"/tag/.+\">(.+)</a>", [{capture, [1]}]) of
%%    {match, [Tag]} ->
%%      parse_tags_line(string:substr(Line, re:match_end()), [Tag | Tags]);
%%    nomatch ->
%%      Tags
%%  end.


extract_quotes_2(Body) ->
  lists:map(fun(El) -> case lists:member(hd("<span class=\"text\" itemprop=\"text\">"),El) of
                         true -> string:tokens(El, "<span class=\"text\" itemprop=\"text\">");
                         false -> El end end, string:tokens(Body, "<div class=\"quote\" itemscope itemtype=\"http://schema.org/CreativeWork\">")).