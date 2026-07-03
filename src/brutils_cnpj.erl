%% @doc Utilities for the Brazilian CNPJ (Cadastro Nacional da Pessoa
%% Jurídica).
%%
%% A CNPJ is a 14-character company identifier: an 8-character root, a
%% 4-character branch number (usually `0001') and 2 numeric check
%% digits. It is commonly displayed as `"XX.XXX.XXX/XXXX-XX"'. Since
%% the 2026 Receita Federal change the first 12 characters may be
%% alphanumeric (digits and uppercase letters); the check digits are
%% always numeric.
%%
%% All functions operate on UTF-8 binaries. Leading zeros are
%% significant, so a CNPJ is never handled as an integer.
-module(brutils_cnpj).

-export([remove_symbols/1]).

%% @doc Removes the formatting symbols `.', `/' and `-' from a CNPJ
%% string.
%%
%% Only those three characters are removed; any other character
%% (letters, spaces, ...) is kept unchanged. This is a pure character
%% filter: it does not validate the input.
%%
%% ```
%% 1> brutils_cnpj:remove_symbols(<<"03.560.714/0001-42">>).
%% <<"03560714000142">>
%% 2> brutils_cnpj:remove_symbols(<<"a-b c!">>).
%% <<"ab c!">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Cnpj) when is_binary(Cnpj) ->
    << <<C>> || <<C>> <= Cnpj, C =/= $., C =/= $/, C =/= $- >>.
