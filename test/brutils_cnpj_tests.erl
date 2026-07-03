%% @doc Tests for {@link brutils_cnpj}.
-module(brutils_cnpj_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% remove_symbols/1
%%--------------------------------------------------------------------

remove_symbols_strips_dots_slashes_and_dashes_test() ->
    ?assertEqual(<<"12345678901">>,
                 brutils_cnpj:remove_symbols(<<"12.345/6789-01">>)),
    ?assertEqual(<<"98765432101">>,
                 brutils_cnpj:remove_symbols(<<"98/76.543-2101">>)),
    ?assertEqual(<<"03560714000142">>,
                 brutils_cnpj:remove_symbols(<<"03.560.714/0001-42">>)).

remove_symbols_keeps_everything_else_test() ->
    %% only $., $/ and $- are stripped: letters, spaces, other symbols survive
    ?assertEqual(<<"NX9K79E2AB1200">>,
                 brutils_cnpj:remove_symbols(<<"NX.9K7.9E2/AB12-00">>)),
    ?assertEqual(<<"ab c!">>, brutils_cnpj:remove_symbols(<<"a-b c!">>)).

remove_symbols_empty_test() ->
    ?assertEqual(<<>>, brutils_cnpj:remove_symbols(<<>>)).

remove_symbols_already_clean_test() ->
    ?assertEqual(<<"03560714000142">>,
                 brutils_cnpj:remove_symbols(<<"03560714000142">>)).

remove_symbols_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_cnpj:remove_symbols("03.560.714/0001-42")),
    ?assertError(function_clause, brutils_cnpj:remove_symbols(3560714000142)).

%%--------------------------------------------------------------------
%% is_valid/1 — shape rejection (never raises, total over term())
%%--------------------------------------------------------------------

is_valid_rejects_non_binary_test() ->
    ?assertNot(brutils_cnpj:is_valid(3560714000142)),
    ?assertNot(brutils_cnpj:is_valid("03560714000142")),   % charlist
    ?assertNot(brutils_cnpj:is_valid(undefined)),
    ?assertNot(brutils_cnpj:is_valid(#{})),
    ?assertNot(brutils_cnpj:is_valid(3.14)).

is_valid_rejects_wrong_length_test() ->
    ?assertNot(brutils_cnpj:is_valid(<<>>)),
    ?assertNot(brutils_cnpj:is_valid(<<"0356071400014">>)),     % 13 chars
    ?assertNot(brutils_cnpj:is_valid(<<"035607140001420">>)).   % 15 chars

is_valid_rejects_lowercase_letters_test() ->
    %% alphanumeric CNPJs are uppercase only — lowercase is never folded
    ?assertNot(brutils_cnpj:is_valid(<<"nx9k79e2ab1200">>)),
    ?assertNot(brutils_cnpj:is_valid(<<"0356071400a142">>)).

is_valid_rejects_letters_in_check_digit_positions_test() ->
    %% chars 13-14 must be digits even in the alphanumeric format
    ?assertNot(brutils_cnpj:is_valid(<<"035607140001A2">>)),
    ?assertNot(brutils_cnpj:is_valid(<<"0356071400014A">>)).

is_valid_rejects_formatted_input_test() ->
    %% symbols are not stripped before validation
    ?assertNot(brutils_cnpj:is_valid(<<"03.560.714/0001-42">>)).

is_valid_rejects_other_symbols_test() ->
    ?assertNot(brutils_cnpj:is_valid(<<"0011-22200013!">>)),
    ?assertNot(brutils_cnpj:is_valid(<<"03560714 00142">>)).

is_valid_rejects_repeated_chars_test() ->
    lists:foreach(
      fun(D) ->
              Cnpj = binary:copy(<<D>>, 14),
              ?assertNot(brutils_cnpj:is_valid(Cnpj))
      end,
      lists:seq($0, $9) ++ [$A, $Z]).
