%% CPF (Cadastro de Pessoas Físicas) utilities — see spec/01-cpf.md
-module(brutils_cpf).

-export([remove_symbols/1]).

%% Removes only the characters `.' and `-'; everything else is kept.
%% Pure character filter, no validation.
-spec remove_symbols(binary()) -> binary().
remove_symbols(Cpf) when is_binary(Cpf) ->
    << <<C>> || <<C>> <= Cpf, C =/= $., C =/= $- >>.
