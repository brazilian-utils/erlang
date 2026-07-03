%% @doc Property-based tests for {@link brutils_cep}.
-module(prop_brutils_cep).

-include_lib("proper/include/proper.hrl").

%%--------------------------------------------------------------------
%% Generators
%%--------------------------------------------------------------------

digit() ->
    integer($0, $9).

non_digit() ->
    ?SUCHTHAT(C, byte(), C < $0 orelse C > $9).

%% An 8-byte binary with at least one non-digit byte.
almost_cep() ->
    ?LET({Digits, Bad, Pos},
         {vector(7, digit()), non_digit(), integer(0, 7)},
         begin
             {Before, After} = lists:split(Pos, Digits),
             list_to_binary(Before ++ [Bad] ++ After)
         end).

%%--------------------------------------------------------------------
%% Properties
%%--------------------------------------------------------------------

%% Every generated CEP is valid.
prop_generate_is_valid() ->
    ?FORALL(_, integer(),
            brutils_cep:is_valid(brutils_cep:generate())).

%% Every generated CEP has exactly 8 bytes.
prop_generate_size() ->
    ?FORALL(_, integer(),
            byte_size(brutils_cep:generate()) =:= 8).

%% Formatting a generated CEP succeeds, and stripping the symbols
%% recovers the original raw CEP.
prop_format_roundtrip() ->
    ?FORALL(_, integer(),
            begin
                Cep = brutils_cep:generate(),
                {ok, Formatted} = brutils_cep:format(Cep),
                brutils_cep:remove_symbols(Formatted) =:= Cep
            end).

%% The no-checksum contract as a theorem: EVERY 8-digit binary is a
%% valid CEP. (For every other identifier in this library this
%% property would be false; for CEP it is the whole rule.)
prop_all_digit_8_is_valid() ->
    ?FORALL(Digits, vector(8, digit()),
            brutils_cep:is_valid(list_to_binary(Digits))).

%% Any 8-byte binary containing a non-digit byte is invalid.
prop_non_digit_invalid() ->
    ?FORALL(Bin, almost_cep(),
            not brutils_cep:is_valid(Bin)).

%% All-digit binaries of any length other than 8 are invalid.
prop_wrong_length_invalid() ->
    ?FORALL(Digits, ?SUCHTHAT(L, list(digit()), length(L) =/= 8),
            not brutils_cep:is_valid(list_to_binary(Digits))).

%% is_valid/1 is total: any term yields a boolean, and non-binaries
%% always yield false.
prop_non_binary_false() ->
    ?FORALL(Term, any(),
            case brutils_cep:is_valid(Term) of
                B when is_boolean(B) -> is_binary(Term) orelse not B
            end).
