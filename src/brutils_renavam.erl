%% @doc Validation for the Brazilian RENAVAM (Registro Nacional de
%% Veículos Automotores) vehicle registration number.
%%
%% A RENAVAM has 11 digits: a 10-digit base followed by 1 check
%% digit. Symbols are NOT stripped before validation — any non-digit
%% character makes the input invalid (unlike the CNH validator in
%% this library).
-module(brutils_renavam).

-export([is_valid/1]).

%% @doc Returns whether the given term has the shape of a valid
%% RENAVAM: a binary of exactly 11 ASCII digits that is not a
%% sequence of one repeated digit.
%%
%% No cleaning is performed — spaces, dashes or letters anywhere make
%% the input invalid. The function is total: any non-binary term
%% returns `false' rather than raising.
-spec is_valid(term()) -> boolean().
is_valid(<<First, _/binary>> = Renavam) when byte_size(Renavam) =:= 11 ->
    all_digits(Renavam) andalso not repeated(Renavam, First);
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
