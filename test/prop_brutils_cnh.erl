%% @doc Property-based tests for {@link brutils_cnh}.
%%
%% The CNH API has no generator, so these properties are anchored on
%% known-valid fixtures (derived from the reference implementation)
%% rather than on generated values.
-module(prop_brutils_cnh).

-include_lib("proper/include/proper.hrl").

%%--------------------------------------------------------------------
%% Generators
%%--------------------------------------------------------------------

fixture() ->
    oneof([<<"98765432100">>,
           <<"10433218100">>,
           <<"96001338941">>,
           <<"08386379499">>,
           <<"02654235141">>,
           <<"81618495905">>,
           <<"62704828170">>]).

digit() ->
    integer($0, $9).

non_digit() ->
    ?SUCHTHAT(C, byte(), C < $0 orelse C > $9).

%% A fixture with random non-digit bytes spliced in at random
%% positions.
dressed_fixture() ->
    ?LET({Cnh, Junk}, {fixture(), list({integer(0, 11), non_digit()})},
         lists:foldl(
           fun({Pos, Byte}, Acc) ->
                   At = min(Pos, byte_size(Acc)),
                   <<Before:At/binary, After/binary>> = Acc,
                   <<Before/binary, Byte, After/binary>>
           end,
           Cnh, Junk)).

%%--------------------------------------------------------------------
%% Properties
%%--------------------------------------------------------------------

%% Splicing any amount of non-digit junk into a valid CNH never
%% changes the verdict: symbols are stripped before validation.
prop_valid_cnh_survives_symbol_injection() ->
    ?FORALL(Dressed, dressed_fixture(),
            brutils_cnh:is_valid(Dressed)).

%% Replacing either check digit with any different digit invalidates.
prop_corrupt_dv_invalid() ->
    ?FORALL({Cnh, Pos, D}, {fixture(), oneof([9, 10]), digit()},
            begin
                <<Before:Pos/binary, Old, After/binary>> = Cnh,
                Corrupted = <<Before/binary, D, After/binary>>,
                D =:= Old orelse not brutils_cnh:is_valid(Corrupted)
            end).

%% Changing any single base digit (positions 0..8) invalidates —
%% both check-digit sums weigh every base digit with nonzero weight.
prop_corrupt_base_invalid() ->
    ?FORALL({Cnh, Pos, D}, {fixture(), integer(0, 8), digit()},
            begin
                <<Before:Pos/binary, Old, After/binary>> = Cnh,
                Corrupted = <<Before/binary, D, After/binary>>,
                D =:= Old orelse not brutils_cnh:is_valid(Corrupted)
            end).

%% is_valid/1 is total: any term yields a boolean, and non-binaries
%% always yield false.
prop_non_binary_false() ->
    ?FORALL(Term, any(),
            case brutils_cnh:is_valid(Term) of
                B when is_boolean(B) -> is_binary(Term) orelse not B
            end).

%% All-digit binaries of any length other than 11 are invalid.
prop_wrong_length_invalid() ->
    ?FORALL(Digits, ?SUCHTHAT(L, list(digit()), length(L) =/= 11),
            not brutils_cnh:is_valid(list_to_binary(Digits))).
