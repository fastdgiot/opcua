-module(opcua_nodeset_namespaces).


%%% EXPORTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% API Functions
-export([uri/1]).
-export([id/1]).
-export([all/0]).

%% Functions to be used only by opcua_nodeset
-export([setup/0]).
-export([store/1]).


%%% MACROS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-define(ETS_OPTS, [named_table, protected, {read_concurrency, true}]).
-define(DB_NAMESPACE_URIS, db_namespace_uris).
-define(DB_NAMESPACE_IDS, db_namespace_ids).


%%% API FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uri(Id) when is_integer(Id), Id > 0 ->
    case ets:lookup(?DB_NAMESPACE_URIS, Id) of
        [{_, Uri}] -> Uri;
        [] -> undefined
    end.

id(Uri) when is_binary(Uri) ->
    case ets:lookup(?DB_NAMESPACE_IDS, Uri) of
        [{_, Id}] -> Id;
        [] -> undefined
    end.

all() ->
    maps:from_list(ets:tab2list(?DB_NAMESPACE_URIS)).


%%% PROTECTED FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

setup() ->
    ets:new(?DB_NAMESPACE_URIS, ?ETS_OPTS),
    ets:new(?DB_NAMESPACE_IDS, ?ETS_OPTS),
    ok.

store({Id, Uri}) ->
    ets:insert(?DB_NAMESPACE_URIS, {Id, Uri}),
    ets:insert(?DB_NAMESPACE_IDS, {Uri, Id}),
    ok.