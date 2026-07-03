%% @doc Utilities for the Brazilian CEP (Código de Endereçamento
%% Postal).
%%
%% A CEP is an 8-digit postal code, commonly displayed as
%% `"NNNNN-NNN"'. It carries no check digit: validation is purely
%% structural and says nothing about whether the code exists.
%%
%% All functions operate on UTF-8 binaries. Leading zeros are
%% significant, so a CEP is never handled as an integer.
-module(brutils_cep).

-export([remove_symbols/1]).

%% @doc Removes the formatting symbols `.' and `-' from a CEP string.
%%
%% Only those two characters are removed; any other character
%% (letters, spaces, slashes, ...) is kept unchanged. This is a pure
%% character filter: it does not validate the input.
%%
%% ```
%% 1> brutils_cep:remove_symbols(<<"01310-200">>).
%% <<"01310200">>
%% 2> brutils_cep:remove_symbols(<<"abc.xyz">>).
%% <<"abcxyz">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Cep) when is_binary(Cep) ->
    << <<C>> || <<C>> <= Cep, C =/= $., C =/= $- >>.
