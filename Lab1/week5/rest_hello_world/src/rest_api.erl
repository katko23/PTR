-module(rest_api).
-behaviour(cowboy_rest).

-export([init/2]).
-export([
    allowed_methods/2,
    content_types_accepted/2,
    content_types_provided/2,
    handle_delete/2,
    handle_get/2,
    handle_post/2,
    handle_put/2,
    handle_patch/2,
    to_json/2,
    movies/0
]).




-record(movie, {
    id :: integer(),
    title :: string(),
    release_year :: integer(),
    director :: string()
}).

-export_record([movie/4]).

movies() ->
    [
        #movie{id=1, title="The Godfather", director="Francis Ford Coppola", release_year=1972},
        #movie{id=2, title="The Shawshank Redemption", director="Frank Darabont", release_year=1994},
        #movie{id=3, title="The Dark Knight", director="Christopher Nolan", release_year=2008},
        #movie{id=4, title="Pulp Fiction", director="Quentin Tarantino", release_year=1994},
        #movie{id=5, title="Forrest Gump", director="Robert Zemeckis", release_year=1994},
        #movie{id=6, title="Fight Club", director="David Fincher", release_year=1999},
        #movie{id=7, title="The Lord of the Rings: The Fellowship of the Ring", director="Peter Jackson", release_year=2001},
        #movie{id=8, title="The Matrix", director="Lana and Lilly Wachowski", release_year=1999},
        #movie{id=9, title="The Silence of the Lambs", director="Jonathan Demme", release_year=1991},
        #movie{id=10, title="Goodfellas", director="Martin Scorsese", release_year=1990}
    ].
    
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
