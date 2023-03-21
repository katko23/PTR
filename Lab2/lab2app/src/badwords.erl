%%%-------------------------------------------------------------------
%%% @author KATCO
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Mar 2023 2:01 AM
%%%-------------------------------------------------------------------
-module(badwords).
-author("KATCO").

%% API
-export([check/1]).

split_string(String) ->
  string:tokens(String, " \t\n\r\f.").

check(Phrase) ->
  Words = split_string(Phrase),
  ListofWords = lists:map(fun(Element) ->
              Word = string:to_lower(Element),
              case check_word(Word) of
                true ->
                  Len = length(Word),
                  lists:duplicate(Len, $*);
                false -> Element
              end
            end, Words),
  string:join(ListofWords, " ")
.


check_word(Word) ->
  BadWords = [
    "arse",
    "arsehead",
    "arsehole",
    "ass",
    "asshole",
    "bastard",
    "bitch",
    "bloody",
    "bollocks",
    "brotherfucker",
    "bugger",
    "bullshit",
    "child-fucker",
    "childfucker",
    "cock",
    "cocksucker",
    "crap",
    "cunt",
    "damn",
    "dick",
    "dickhead",
    "dyke",
    "fatherfucker",
    "frigger",
    "fuck",
    "goddamn",
    "godsdamn",
    "hell",
    "horseshit",
    "kike",
    "motherfucker",
    "nigga",
    "nigra",
    "piss",
    "prick",
    "pussy",
    "shit",
    "shite",
    "sisterfucker",
    "slut",
    "spastic",
    "turd",
    "twat",
    "wanker",
    "whore",
    "wtf"
    ],
  lists:member(Word, BadWords).