%% @doc Utilities for the Brazilian CPF (Cadastro de Pessoas Físicas).
%%
%% A CPF is an 11-digit identifier assigned to individuals: a 9-digit
%% base number followed by 2 check digits. It is commonly displayed as
%% `"XXX.XXX.XXX-XX"'.
%%
%% All functions operate on UTF-8 binaries. Leading zeros are
%% significant, so a CPF is never handled as an integer.
-module(brutils_cpf).

-export([remove_symbols/1]).

%% @doc Removes the formatting symbols `.' and `-' from a CPF string.
%%
%% Only those two characters are removed; any other character (letters,
%% spaces, slashes, ...) is kept unchanged. This is a pure character
%% filter: it does not validate the input.
%%
%% ```
%% 1> brutils_cpf:remove_symbols(<<"123.456.789-01">>).
%% <<"12345678901">>
%% 2> brutils_cpf:remove_symbols(<<"abc//1">>).
%% <<"abc//1">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Cpf) when is_binary(Cpf) ->
    << <<C>> || <<C>> <= Cpf, C =/= $., C =/= $- >>.
