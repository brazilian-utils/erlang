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

-export([remove_symbols/1, is_valid/1]).

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

%% @doc Returns whether the given term has the shape of a valid CNPJ:
%% a 14-character binary whose first 12 characters are digits or
%% uppercase letters, whose last 2 characters (the check digits) are
%% digits, and which is not a sequence of one repeated character.
%%
%% Lowercase letters are always invalid — they are never case-folded.
%% Formatting symbols are not stripped, so a formatted CNPJ such as
%% `<<"03.560.714/0001-42">>' is invalid; clean it with
%% {@link remove_symbols/1} first. The function is total: any
%% non-binary term returns `false' rather than raising.
-spec is_valid(term()) -> boolean().
is_valid(<<First, _/binary>> = Cnpj) when byte_size(Cnpj) =:= 14 ->
    <<Base12:12/binary, Dvs:2/binary>> = Cnpj,
    alphanumeric(Base12)
        andalso all_digits(Dvs)
        andalso not repeated(Cnpj, First);
is_valid(_) ->
    false.

%%--------------------------------------------------------------------
%% Internal
%%--------------------------------------------------------------------

%% Every byte is a digit or an uppercase letter?
-spec alphanumeric(binary()) -> boolean().
alphanumeric(<<C, Rest/binary>>) when C >= $0, C =< $9; C >= $A, C =< $Z ->
    alphanumeric(Rest);
alphanumeric(<<>>) -> true;
alphanumeric(_) -> false.

-spec all_digits(binary()) -> boolean().
all_digits(<<C, Rest/binary>>) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(<<>>) -> true;
all_digits(_) -> false.

%% All bytes equal to the first one?
-spec repeated(binary(), byte()) -> boolean().
repeated(Cnpj, First) ->
    Cnpj =:= binary:copy(<<First>>, byte_size(Cnpj)).
