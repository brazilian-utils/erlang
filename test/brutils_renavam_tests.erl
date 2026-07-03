%% @doc Tests for {@link brutils_renavam}.
-module(brutils_renavam_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% is_valid/1 — shape rejection (never raises, total over term())
%%
%% Unlike CNH, RENAVAM does NOT strip symbols: any non-digit
%% character anywhere makes the input invalid, like CPF/CNPJ/PIS.
%%--------------------------------------------------------------------

is_valid_rejects_non_binary_test() ->
    ?assertNot(brutils_renavam:is_valid(86769597308)),
    ?assertNot(brutils_renavam:is_valid("86769597308")),   % charlist
    ?assertNot(brutils_renavam:is_valid(undefined)),
    ?assertNot(brutils_renavam:is_valid(#{})),
    ?assertNot(brutils_renavam:is_valid(3.14)).

is_valid_rejects_wrong_length_test() ->
    ?assertNot(brutils_renavam:is_valid(<<>>)),
    ?assertNot(brutils_renavam:is_valid(<<"8676959730">>)),     % 10 digits
    ?assertNot(brutils_renavam:is_valid(<<"867695973080">>)).   % 12 digits

is_valid_does_not_strip_symbols_test() ->
    %% value pins, not equivalence pins: dressed and clean inputs
    %% genuinely differ in verdict here — that asymmetry is the
    %% contract (contrast with brutils_cnh)
    ?assertNot(brutils_renavam:is_valid(<<"12345678 901">>)),
    ?assertNot(brutils_renavam:is_valid(<<"867695973-08">>)),
    ?assertNot(brutils_renavam:is_valid(<<"1234567890a">>)).

is_valid_rejects_repeated_digits_test() ->
    %% pinned from the executed reference: all ten fail
    lists:foreach(
      fun(D) ->
              Renavam = binary:copy(<<D>>, 11),
              ?assertNot(brutils_renavam:is_valid(Renavam))
      end,
      lists:seq($0, $9)).

%%--------------------------------------------------------------------
%% is_valid/1 — check digit
%%--------------------------------------------------------------------

is_valid_accepts_valid_renavams_test() ->
    %% fixtures derived through the reference implementation
    Valid = [<<"86769597308">>,   % spec anchor, executed
             <<"52601815907">>,
             <<"83016613182">>,
             <<"60913909967">>,
             <<"03082462814">>,
             <<"94821993516">>,
             <<"79754323190">>,   % dv sum maps through >= 10 -> 0
             <<"00000000019">>],  % near-zero base
    lists:foreach(fun(R) -> ?assert(brutils_renavam:is_valid(R)) end, Valid).

is_valid_rejects_bad_check_digit_test() ->
    %% every wrong value for the last digit of a valid RENAVAM must fail
    Base = <<"5260181590">>,
    lists:foreach(
      fun(D) when D =:= $7 -> ok;
         (D) -> ?assertNot(brutils_renavam:is_valid(<<Base/binary, D>>))
      end,
      lists:seq($0, $9)).

is_valid_rejects_spec_negative_test() ->
    ?assertNot(brutils_renavam:is_valid(<<"12345678901">>)).

is_valid_zero_check_digit_covers_two_residues_test() ->
    %% check digit 0 is the image of TWO weighted-sum residues (rem 0
    %% and rem 1 both map to 0 through the >= 10 collapse), so two
    %% valid RENAVAMs with dv 0 can differ in a single base digit.
    %% Both values confirmed valid by the reference implementation.
    ?assert(brutils_renavam:is_valid(<<"79754323190">>)),
    ?assert(brutils_renavam:is_valid(<<"09754323190">>)).

is_valid_requires_reversed_base_test() ->
    %% regression guard for the algorithm's distinctive twist: the
    %% weighted sum runs over the REVERSED 10-digit base. This value
    %% has a correct check digit under a NON-reversed fold with the
    %% same weight table, but the reference rejects it — if the
    %% reversal is ever "simplified" away, this test fails.
    ?assertNot(brutils_renavam:is_valid(<<"48757491182">>)).
