%% @doc Validation for the Brazilian RENAVAM (Registro Nacional de
%% Veículos Automotores) vehicle registration number.
%%
%% A RENAVAM has 11 digits: a 10-digit base followed by 1 check
%% digit. Symbols are NOT stripped before validation — any non-digit
%% character makes the input invalid (unlike the CNH validator in
%% this library).
-module(brutils_renavam).

-export([is_valid/1]).

%% @doc Returns whether the given term is a valid RENAVAM: a binary
%% of exactly 11 ASCII digits, not a sequence of one repeated digit,
%% whose check digit (the last one) matches the one computed from
%% its 10-digit base.
%%
%% No cleaning is performed — spaces, dashes or letters anywhere make
%% the input invalid. Only the format is verified — the RENAVAM is
%% not checked for existence. The function is total: any non-binary
%% term returns `false' rather than raising.
%%
%% ```
%% 1> brutils_renavam:is_valid(<<"86769597308">>).
%% true
%% 2> brutils_renavam:is_valid(<<"12345678901">>).
%% false
%% '''
-spec is_valid(term()) -> boolean().
is_valid(<<First, _/binary>> = Renavam) when byte_size(Renavam) =:= 11 ->
    all_digits(Renavam)
        andalso not repeated(Renavam, First)
        andalso checksum_ok(Renavam);
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
repeated(Renavam, First) ->
    Renavam =:= binary:copy(<<First>>, byte_size(Renavam)).

%% Weights applied to the REVERSED 10-digit base, left to right.
-define(WEIGHTS, [2, 3, 4, 5, 6, 7, 8, 9, 2, 3]).

%% The check digit (byte 11) matches the one computed from the
%% 10-digit base. The weighted sum runs over the base digits in
%% REVERSE order — dropping the reversal yields an algorithm that
%% accepts a different set of values.
-spec checksum_ok(binary()) -> boolean().
checksum_ok(<<Base10:10/binary, Dv>>) ->
    Reversed = lists:reverse(binary_to_list(Base10)),
    Sum = lists:sum([(C - $0) * W || {C, W} <- lists:zip(Reversed, ?WEIGHTS)]),
    Dv =:= $0 + dv(11 - (Sum rem 11)).

%% Cap the 11-complement into a check digit: 10 and 11 map to 0.
-spec dv(1..11) -> 0..9.
dv(D) when D >= 10 -> 0;
dv(D) -> D.
