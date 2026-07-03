%% @doc Validation for the Brazilian CNH (Carteira Nacional de
%% Habilitação) registration number, 2022 layout.
%%
%% A CNH registration number has 11 digits: a 9-digit base followed by
%% 2 check digits. Only the layout introduced in 2022 is supported;
%% earlier CNH layouts are out of scope.
%%
%% Unlike the CPF/CNPJ/PIS validators in this library, `is_valid/1'
%% strips every non-digit character before validating, so formatted
%% input such as `<<"987654321-00">>' is accepted.
-module(brutils_cnh).

-export([is_valid/1]).

%% @doc Returns whether the given term has the shape of a valid CNH
%% after stripping every non-digit character: exactly 11 digits
%% remain, and they are not a sequence of one repeated digit.
%%
%% Letters and symbols are removed, not rejected — an input like
%% `<<"A2C45678901">>' fails because only 9 digits remain, not
%% because it contains letters. The function is total: any non-binary
%% term returns `false' rather than raising.
-spec is_valid(term()) -> boolean().
is_valid(Cnh) when is_binary(Cnh) ->
    case strip_non_digits(Cnh) of
        <<First, _/binary>> = Digits when byte_size(Digits) =:= 11 ->
            not repeated(Digits, First);
        _ ->
            false
    end;
is_valid(_) ->
    false.

%%--------------------------------------------------------------------
%% Internal
%%--------------------------------------------------------------------

-spec strip_non_digits(binary()) -> binary().
strip_non_digits(Bin) ->
    << <<C>> || <<C>> <= Bin, C >= $0, C =< $9 >>.

%% All bytes equal to the first one?
-spec repeated(binary(), byte()) -> boolean().
repeated(Digits, First) ->
    Digits =:= binary:copy(<<First>>, byte_size(Digits)).
