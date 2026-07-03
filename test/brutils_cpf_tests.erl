%% @doc Tests for {@link brutils_cpf}.
-module(brutils_cpf_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% remove_symbols/1
%%--------------------------------------------------------------------

remove_symbols_strips_dots_and_dashes_test() ->
    ?assertEqual(<<"12345678901">>,
                 brutils_cpf:remove_symbols(<<"123.456.789-01">>)),
    ?assertEqual(<<"98765432101">>,
                 brutils_cpf:remove_symbols(<<"987-654-321.01">>)).

remove_symbols_keeps_everything_else_test() ->
    %% only $. and $- are stripped: letters, slashes, spaces survive
    ?assertEqual(<<"abc//1">>, brutils_cpf:remove_symbols(<<"abc//1">>)),
    ?assertEqual(<<"1 23">>, brutils_cpf:remove_symbols(<<"1 2-3">>)).

remove_symbols_empty_test() ->
    ?assertEqual(<<>>, brutils_cpf:remove_symbols(<<>>)).

remove_symbols_already_clean_test() ->
    ?assertEqual(<<"12345678901">>,
                 brutils_cpf:remove_symbols(<<"12345678901">>)).

remove_symbols_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_cpf:remove_symbols("123.456.789-01")),
    ?assertError(function_clause, brutils_cpf:remove_symbols(12345678901)).

%%--------------------------------------------------------------------
%% is_valid/1 — shape rejection (never raises, total over term())
%%--------------------------------------------------------------------

is_valid_rejects_non_binary_test() ->
    ?assertNot(brutils_cpf:is_valid(82178537464)),
    ?assertNot(brutils_cpf:is_valid("82178537464")),   % charlist
    ?assertNot(brutils_cpf:is_valid(undefined)),
    ?assertNot(brutils_cpf:is_valid(#{})),
    ?assertNot(brutils_cpf:is_valid(3.14)).

is_valid_rejects_wrong_length_test() ->
    ?assertNot(brutils_cpf:is_valid(<<>>)),
    ?assertNot(brutils_cpf:is_valid(<<"8217853746">>)),     % 10 digits
    ?assertNot(brutils_cpf:is_valid(<<"821785374640">>)).   % 12 digits

is_valid_rejects_non_digit_chars_test() ->
    ?assertNot(brutils_cpf:is_valid(<<"8217853746a">>)),
    ?assertNot(brutils_cpf:is_valid(<<"8217853746 ">>)),
    ?assertNot(brutils_cpf:is_valid(<<"-2178537464">>)).

is_valid_rejects_formatted_input_test() ->
    %% symbols are not stripped before validation
    ?assertNot(brutils_cpf:is_valid(<<"821.785.374-64">>)).

is_valid_rejects_repeated_digits_test() ->
    lists:foreach(
      fun(D) ->
              Cpf = binary:copy(<<D>>, 11),
              ?assertNot(brutils_cpf:is_valid(Cpf))
      end,
      lists:seq($0, $9)).
