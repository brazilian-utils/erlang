%% @doc Utilities for the Brazilian CPF (Cadastro de Pessoas Físicas).
%%
%% A CPF is an 11-digit identifier assigned to individuals: a 9-digit
%% base number followed by 2 check digits. It is commonly displayed as
%% `"XXX.XXX.XXX-XX"'.
%%
%% All functions operate on UTF-8 binaries. Leading zeros are
%% significant, so a CPF is never handled as an integer.
-module(brutils_cpf).

-export([remove_symbols/1, is_valid/1]).

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

%% @doc Returns whether the given term has the shape of a valid CPF:
%% a binary of exactly 11 ASCII digits that is not a sequence of one
%% repeated digit (`<<"00000000000">>' and the like are reserved and
%% always invalid).
%%
%% Formatting symbols are not stripped, so a formatted CPF such as
%% `<<"821.785.374-64">>' is invalid; clean it with
%% {@link remove_symbols/1} first. The function is total: any
%% non-binary term returns `false' rather than raising.
-spec is_valid(term()) -> boolean().
is_valid(<<First, _/binary>> = Cpf) when byte_size(Cpf) =:= 11 ->
    all_digits(Cpf) andalso not repeated(Cpf, First);
is_valid(_) ->
    false.

%%--------------------------------------------------------------------
%% Internal
%%--------------------------------------------------------------------

-spec all_digits(binary()) -> boolean().
all_digits(<<C, Rest/binary>>) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(<<>>) -> true;
all_digits(_) -> false.

%% All bytes equal to the first one?
-spec repeated(binary(), byte()) -> boolean().
repeated(Cpf, First) ->
    Cpf =:= binary:copy(<<First>>, byte_size(Cpf)).
