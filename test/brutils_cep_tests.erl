%% @doc Tests for {@link brutils_cep}.
-module(brutils_cep_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% remove_symbols/1
%%--------------------------------------------------------------------

remove_symbols_strips_dots_and_dashes_test() ->
    ?assertEqual(<<"123456789">>,
                 brutils_cep:remove_symbols(<<"123-45.678.9">>)),
    ?assertEqual(<<"01310200">>,
                 brutils_cep:remove_symbols(<<"01310-200">>)).

remove_symbols_keeps_everything_else_test() ->
    %% only $. and $- are stripped: letters survive (the reference's
    %% own documented example), as do spaces and slashes
    ?assertEqual(<<"abcxyz">>, brutils_cep:remove_symbols(<<"abc.xyz">>)),
    ?assertEqual(<<"01310 200/">>,
                 brutils_cep:remove_symbols(<<"01310 200/">>)).

remove_symbols_empty_test() ->
    ?assertEqual(<<>>, brutils_cep:remove_symbols(<<>>)).

remove_symbols_already_clean_test() ->
    ?assertEqual(<<"01310200">>,
                 brutils_cep:remove_symbols(<<"01310200">>)).

remove_symbols_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_cep:remove_symbols("01310-200")),
    ?assertError(function_clause, brutils_cep:remove_symbols(1310200)).

%%--------------------------------------------------------------------
%% is_valid/1
%%
%% A CEP has NO check digit: being a binary of exactly 8 ASCII digits
%% is the entire contract. Validity says nothing about existence.
%%--------------------------------------------------------------------

is_valid_accepts_8_digit_binaries_test() ->
    ?assert(brutils_cep:is_valid(<<"01310200">>)),
    ?assert(brutils_cep:is_valid(<<"12345678">>)).

is_valid_accepts_repeated_digits_test() ->
    %% pinned from the executed reference: with no checksum and no
    %% reservation rule, ALL repeated sequences are valid — the
    %% inverse of the CPF/CNH pins; do not "fix" this
    lists:foreach(
      fun(D) ->
              Cep = binary:copy(<<D>>, 8),
              ?assert(brutils_cep:is_valid(Cep))
      end,
      lists:seq($0, $9)).

is_valid_rejects_non_binary_test() ->
    ?assertNot(brutils_cep:is_valid(1310200)),
    ?assertNot(brutils_cep:is_valid("01310200")),   % charlist
    ?assertNot(brutils_cep:is_valid(undefined)),
    ?assertNot(brutils_cep:is_valid(#{})),
    ?assertNot(brutils_cep:is_valid(3.14)).

is_valid_rejects_wrong_length_test() ->
    ?assertNot(brutils_cep:is_valid(<<>>)),
    ?assertNot(brutils_cep:is_valid(<<"1234567">>)),     % 7 digits
    ?assertNot(brutils_cep:is_valid(<<"123456789">>)).   % 9 digits

is_valid_rejects_non_digit_chars_test() ->
    ?assertNot(brutils_cep:is_valid(<<"abcdefgh">>)),
    ?assertNot(brutils_cep:is_valid(<<"0131020a">>)),
    ?assertNot(brutils_cep:is_valid(<<"01310 20">>)).

is_valid_rejects_formatted_input_test() ->
    %% symbols are not stripped before validation
    ?assertNot(brutils_cep:is_valid(<<"01310-200">>)).

%%--------------------------------------------------------------------
%% format/1
%%--------------------------------------------------------------------

format_valid_cep_test() ->
    %% grouping is 5-3 with a dash; leading zeros survive
    ?assertEqual({ok, <<"01310-200">>},
                 brutils_cep:format(<<"01310200">>)),
    ?assertEqual({ok, <<"12345-678">>},
                 brutils_cep:format(<<"12345678">>)).

format_invalid_cep_test() ->
    ?assertEqual({error, invalid}, brutils_cep:format(<<"1234567">>)),
    ?assertEqual({error, invalid}, brutils_cep:format(<<"0131020a">>)),
    ?assertEqual({error, invalid}, brutils_cep:format(<<>>)).

format_already_formatted_is_invalid_test() ->
    %% format/1 does not strip symbols before validating
    ?assertEqual({error, invalid}, brutils_cep:format(<<"01310-200">>)).

format_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_cep:format(1310200)),
    ?assertError(function_clause, brutils_cep:format("01310200")).

%%--------------------------------------------------------------------
%% generate/0
%%--------------------------------------------------------------------

generate_produces_valid_ceps_test() ->
    %% every 8-digit string is valid, so this is trivially strong
    lists:foreach(
      fun(_) ->
              Cep = brutils_cep:generate(),
              ?assertEqual(8, byte_size(Cep)),
              ?assert(brutils_cep:is_valid(Cep))
      end,
      lists:seq(1, 100)).

generate_is_random_test() ->
    Ceps = [brutils_cep:generate() || _ <- lists:seq(1, 100)],
    ?assert(length(lists:usort(Ceps)) > 1).
