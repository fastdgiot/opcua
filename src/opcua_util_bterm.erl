-module(opcua_util_bterm).


%%% EXPORTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% API Functions
-export([fold/3]).
-export([save/2]).


%%% MACROS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of bytes to use as binary term size header
-define(SIZE_HEADER, 32).


%%% API FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fold(FilePath, Fun, Acc) ->
    case file:open(FilePath, [read, raw, binary]) of
        {error, Reason} -> error({file_error, Reason, FilePath});
        {ok, File} ->
            try load_terms(File, Fun, file:read(File, 4), Acc)
            after file:close(File)
            end
    end.

save(FilePath, Terms) ->
    case file:open(FilePath, [write, raw, binary]) of
        {error, Reason} -> error({file_error, Reason, FilePath});
        {ok, File} ->
            try lists:foreach(fun(T) -> save_term(File, T) end, Terms)
            after file:close(File)
            end
    end.


%%% INTERNAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load_terms(_File, _Fun, eof, Acc) -> Acc;
load_terms(File, Fun, {ok, <<Size:?SIZE_HEADER>>}, Acc) ->
    {ok, Bin} = file:read(File, Size),
    Acc2 = Fun(binary_to_term(Bin), Acc),
    load_terms(File, Fun, file:read(File, 4), Acc2).

save_term(File, Term) ->
    Bin = term_to_binary(Term),
    file:write(File, [<<(byte_size(Bin)):?SIZE_HEADER>>, Bin]).