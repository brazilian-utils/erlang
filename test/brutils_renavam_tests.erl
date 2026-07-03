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
