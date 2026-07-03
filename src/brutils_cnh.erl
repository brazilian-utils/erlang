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

%% @doc Returns whether the given term is a valid CNH after stripping
%% every non-digit character: exactly 11 digits remain, they are not
%% a sequence of one repeated digit, and both check digits (the last
%% two) match the ones computed from the 9-digit base.
%%
%% Letters and symbols are removed, not rejected — an input like
%% `<<"A2C45678901">>' fails because only 9 digits remain, not
%% because it contains letters. Only the format is verified — the CNH
%% is not checked for existence. The function is total: any
%% non-binary term returns `false' rather than raising.
%%
%% ```
%% 1> brutils_cnh:is_valid(<<"98765432100">>).
%% true
%% 2> brutils_cnh:is_valid(<<"987654321-00">>).
%% true
%% 3> brutils_cnh:is_valid(<<"12345678901">>).
%% false
%% '''
-spec is_valid(term()) -> boolean().
is_valid(Cnh) when is_binary(Cnh) ->
    case strip_non_digits(Cnh) of
        <<First, _/binary>> = Digits when byte_size(Digits) =:= 11 ->
            not repeated(Digits, First) andalso checksum_ok(Digits);
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

%% Both check digits (bytes 10 and 11) match the ones computed from
%% the 9-digit base. The two digits use opposite weight ladders over
%% the same base: descending 9..1 for the first, ascending 1..9 for
%% the second.
%%
%% The reference implementation adjusts the second digit when the
%% first exceeds 9, but a `rem 11' value capped to 0..9 never can —
%% that branch is unreachable and is deliberately not ported.
-spec checksum_ok(binary()) -> boolean().
checksum_ok(<<Base9:9/binary, V1, V2>>) ->
    V1 =:= $0 + dv(weighted_sum(Base9, 9, -1, 0))
        andalso V2 =:= $0 + dv(weighted_sum(Base9, 1, 1, 0)).

%% Cap a `rem 11' result into a check digit: 10 maps to 0.
-spec dv(0..10) -> 0..9.
dv(R) when R > 9 -> 0;
dv(R) -> R.

%% Weighted sum of the base digits mod 11, with the weight moving by
%% `Step' (+1 or -1) per digit.
-spec weighted_sum(binary(), integer(), -1 | 1, non_neg_integer()) ->
        0..10.
weighted_sum(<<C, Rest/binary>>, Weight, Step, Acc) ->
    weighted_sum(Rest, Weight + Step, Step, Acc + (C - $0) * Weight);
weighted_sum(<<>>, _Weight, _Step, Acc) ->
    Acc rem 11.
