%% @doc Utilities for the Brazilian PIS/PASEP (Programa de Integração
%% Social) number.
%%
%% A PIS is an 11-digit identifier assigned to workers: a 10-digit
%% base number followed by 1 check digit. It is commonly displayed as
%% `"NNN.NNNNN.NN-N"'.
%%
%% All functions operate on UTF-8 binaries. Leading zeros are
%% significant, so a PIS is never handled as an integer.
-module(brutils_pis).

-export([remove_symbols/1]).

%% @doc Removes the formatting symbols `.' and `-' from a PIS string.
%%
%% Only those two characters are removed; any other character
%% (letters, spaces, slashes, ...) is kept unchanged. This is a pure
%% character filter: it does not validate the input.
%%
%% ```
%% 1> brutils_pis:remove_symbols(<<"120.56798.81-8">>).
%% <<"12056798818">>
%% 2> brutils_pis:remove_symbols(<<"120/567.98 81-a">>).
%% <<"120/56798 81a">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Pis) when is_binary(Pis) ->
    << <<C>> || <<C>> <= Pis, C =/= $., C =/= $- >>.
