%% @doc Property-based tests for {@link brutils_renavam}.
%%
%% The RENAVAM API has no generator, so corruption properties are
%% anchored on known-valid fixtures (derived from the reference
%% implementation); the exactly-one-check-digit property needs no
%% fixtures and runs over arbitrary bases.
-module(prop_brutils_renavam).

-include_lib("proper/include/proper.hrl").

%%--------------------------------------------------------------------
%% Generators
%%--------------------------------------------------------------------

fixture() ->
    oneof([<<"86769597308">>,
           <<"52601815907">>,
           <<"83016613182">>,
           <<"60913909967">>,
           <<"03082462814">>,
           <<"94821993516">>,
           <<"79754323190">>,
           <<"00000000019">>]).

%% Fixtures whose check digit is nonzero — see
%% prop_corrupt_base_invalid for why the dv=0 one is excluded.
nonzero_dv_fixture() ->
    ?SUCHTHAT(F, fixture(), binary:last(F) =/= $0).

digit() ->
    integer($0, $9).

non_digit() ->
    ?SUCHTHAT(C, byte(), C < $0 orelse C > $9).

%%--------------------------------------------------------------------
%% Properties
%%--------------------------------------------------------------------

%% The check digit is a pure function of the base: for any 10-digit
%% base, exactly one final digit validates. Sole exception: the
%% all-zeros base, whose computed check digit is 0 — making the full
%% value the repeated sequence <<"00000000000">>, which the
%% repeated-digit rule rejects, leaving that base with zero valid
%% check digits.
prop_exactly_one_dv_valid() ->
    ?FORALL(Digits,
            ?SUCHTHAT(Ds, vector(10, digit()),
                      Ds =/= lists:duplicate(10, $0)),
            begin
                Base = list_to_binary(Digits),
                Valid = [D || D <- lists:seq($0, $9),
                              brutils_renavam:is_valid(<<Base/binary, D>>)],
                length(Valid) =:= 1
            end).

%% Replacing the check digit of a valid RENAVAM with any different
%% digit invalidates it.
prop_corrupt_dv_invalid() ->
    ?FORALL({Renavam, D}, {fixture(), digit()},
            begin
                <<Base:10/binary, Old>> = Renavam,
                D =:= Old
                    orelse not brutils_renavam:is_valid(<<Base/binary, D>>)
            end).

%% Changing any single base digit invalidates — but only for values
%% whose check digit is nonzero. Check digit 0 covers TWO residue
%% classes (weighted sums of rem 0 and rem 1 both map to 0), so
%% single-digit changes that shift the sum between those classes
%% preserve validity; the reference implementation confirms such
%% survivors are genuinely valid. dv=0 fixtures are therefore
%% excluded here — the collapse itself is pinned in the eunit suite.
prop_corrupt_base_invalid() ->
    ?FORALL({Renavam, Pos, D}, {nonzero_dv_fixture(), integer(0, 9), digit()},
            begin
                <<Before:Pos/binary, Old, After/binary>> = Renavam,
                Corrupted = <<Before/binary, D, After/binary>>,
                D =:= Old orelse not brutils_renavam:is_valid(Corrupted)
            end).

%% Splicing any non-digit byte into a valid RENAVAM invalidates it:
%% symbols are NOT stripped (opposite polarity from the CNH property).
prop_symbol_injection_invalidates() ->
    ?FORALL({Renavam, Pos, Byte}, {fixture(), integer(0, 11), non_digit()},
            begin
                <<Before:Pos/binary, After/binary>> = Renavam,
                not brutils_renavam:is_valid(
                      <<Before/binary, Byte, After/binary>>)
            end).

%% is_valid/1 is total: any term yields a boolean, and non-binaries
%% always yield false.
prop_non_binary_false() ->
    ?FORALL(Term, any(),
            case brutils_renavam:is_valid(Term) of
                B when is_boolean(B) -> is_binary(Term) orelse not B
            end).

%% All-digit binaries of any length other than 11 are invalid.
prop_wrong_length_invalid() ->
    ?FORALL(Digits, ?SUCHTHAT(L, list(digit()), length(L) =/= 11),
            not brutils_renavam:is_valid(list_to_binary(Digits))).
