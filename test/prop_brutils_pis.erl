%% @doc Property-based tests for {@link brutils_pis}.
-module(prop_brutils_pis).

-include_lib("proper/include/proper.hrl").

%%--------------------------------------------------------------------
%% Generators
%%--------------------------------------------------------------------

digit() ->
    integer($0, $9).

non_digit() ->
    ?SUCHTHAT(C, byte(), C < $0 orelse C > $9).

%% An 11-byte binary with at least one non-digit byte.
almost_pis() ->
    ?LET({Digits, Bad, Pos},
         {vector(10, digit()), non_digit(), integer(0, 10)},
         begin
             {Before, After} = lists:split(Pos, Digits),
             list_to_binary(Before ++ [Bad] ++ After)
         end).

%%--------------------------------------------------------------------
%% Properties
%%--------------------------------------------------------------------

%% Every generated PIS is valid.
prop_generate_is_valid() ->
    ?FORALL(_, integer(),
            brutils_pis:is_valid(brutils_pis:generate())).

%% Every generated PIS has exactly 11 bytes.
prop_generate_size() ->
    ?FORALL(_, integer(),
            byte_size(brutils_pis:generate()) =:= 11).

%% Formatting a generated PIS succeeds, and stripping the symbols
%% recovers the original raw PIS.
prop_format_roundtrip() ->
    ?FORALL(_, integer(),
            begin
                Pis = brutils_pis:generate(),
                {ok, Formatted} = brutils_pis:format(Pis),
                brutils_pis:remove_symbols(Formatted) =:= Pis
            end).

%% The check digit is a pure function of the base: for any 10-digit
%% base, exactly one of the ten digits makes the full value valid.
prop_exactly_one_dv_valid() ->
    ?FORALL(Digits, vector(10, digit()),
            begin
                Base = list_to_binary(Digits),
                Valid = [D || D <- lists:seq($0, $9),
                              brutils_pis:is_valid(<<Base/binary, D>>)],
                length(Valid) =:= 1
            end).

%% Any 11-byte binary containing a non-digit byte is invalid.
prop_non_digit_invalid() ->
    ?FORALL(Bin, almost_pis(),
            not brutils_pis:is_valid(Bin)).
