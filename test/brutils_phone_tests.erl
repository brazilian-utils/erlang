%% @doc Tests for {@link brutils_phone}.
-module(brutils_phone_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% remove_symbols/1
%%--------------------------------------------------------------------

remove_symbols_strips_phone_punctuation_test() ->
    %% removes exactly ( ) - + and space
    ?assertEqual(<<"5511994029275">>,
                 brutils_phone:remove_symbols(<<"+55 (11) 99402-9275">>)),
    ?assertEqual(<<"1635014415">>,
                 brutils_phone:remove_symbols(<<"(16) 3501-4415">>)).

remove_symbols_keeps_dots_test() ->
    %% parity quirk: dots are NOT removed — a dotted number stays
    %% dotted (and will fail validation)
    ?assertEqual(<<"11.99402.9275">>,
                 brutils_phone:remove_symbols(<<"11.99402.9275">>)).

remove_symbols_keeps_letters_test() ->
    ?assertEqual(<<"11abc99">>,
                 brutils_phone:remove_symbols(<<"(11) abc-99+">>)).

remove_symbols_empty_test() ->
    ?assertEqual(<<>>, brutils_phone:remove_symbols(<<>>)).

remove_symbols_already_clean_test() ->
    ?assertEqual(<<"11994029275">>,
                 brutils_phone:remove_symbols(<<"11994029275">>)).

remove_symbols_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_phone:remove_symbols("11994029275")),
    ?assertError(function_clause, brutils_phone:remove_symbols(11994029275)).

%%--------------------------------------------------------------------
%% is_valid/1,2
%%--------------------------------------------------------------------

is_valid_accepts_both_shapes_test() ->
    ?assert(brutils_phone:is_valid(<<"11994029275">>)),   % mobile, 11
    ?assert(brutils_phone:is_valid(<<"1635014415">>)).    % landline, 10

is_valid_typed_matches_shape_test() ->
    ?assert(brutils_phone:is_valid(<<"11994029275">>, mobile)),
    ?assert(brutils_phone:is_valid(<<"1635014415">>, landline)),
    %% cross-type rejection
    ?assertNot(brutils_phone:is_valid(<<"11994029275">>, landline)),
    ?assertNot(brutils_phone:is_valid(<<"1635014415">>, mobile)).

is_valid_rejects_zero_in_ddd_test() ->
    %% either DDD digit being 0 invalidates, both shapes
    ?assertNot(brutils_phone:is_valid(<<"01994029275">>)),
    ?assertNot(brutils_phone:is_valid(<<"10994029275">>)),
    ?assertNot(brutils_phone:is_valid(<<"0635014415">>)),
    ?assertNot(brutils_phone:is_valid(<<"6035014415">>)).

is_valid_mobile_third_digit_must_be_9_test() ->
    ?assertNot(brutils_phone:is_valid(<<"11894029275">>)),
    ?assertNot(brutils_phone:is_valid(<<"11094029275">>)).

is_valid_landline_third_digit_boundaries_test() ->
    %% 2..5 valid, 1 and 6 invalid
    lists:foreach(
      fun(D) ->
              ?assert(brutils_phone:is_valid(<<"16", D, "5014415">>))
      end,
      [$2, $3, $4, $5]),
    ?assertNot(brutils_phone:is_valid(<<"1615014415">>)),
    ?assertNot(brutils_phone:is_valid(<<"1665014415">>)).

is_valid_rejects_wrong_length_test() ->
    ?assertNot(brutils_phone:is_valid(<<>>)),
    ?assertNot(brutils_phone:is_valid(<<"1199402927">>)),     % 10, mobile-shaped
    ?assertNot(brutils_phone:is_valid(<<"119940292751">>)),   % 12
    ?assertNot(brutils_phone:is_valid(<<"163501441">>)),      % 9
    ?assertNot(brutils_phone:is_valid(<<"16350144150">>)).    % 11, landline-shaped

is_valid_rejects_formatted_input_test() ->
    %% symbols are not stripped before validation
    ?assertNot(brutils_phone:is_valid(<<"(11)99402-9275">>)).

is_valid_rejects_non_binary_test() ->
    ?assertNot(brutils_phone:is_valid(11994029275)),
    ?assertNot(brutils_phone:is_valid("11994029275")),   % charlist
    ?assertNot(brutils_phone:is_valid(undefined)),
    ?assertNot(brutils_phone:is_valid(#{})).

is_valid_unknown_type_is_out_of_contract_test() ->
    %% deliberate tightening vs the reference, which accepts any
    %% string as the type and silently falls through to the either-or
    %% check; the Erlang port restricts to mobile | landline
    ?assertError(function_clause,
                 brutils_phone:is_valid(<<"11994029275">>, cellphone)),
    ?assertError(function_clause,
                 brutils_phone:is_valid(<<"11994029275">>, "mobile")).

%%--------------------------------------------------------------------
%% format/1
%%--------------------------------------------------------------------

format_mobile_test() ->
    %% (DD) prefix with NO space after the parenthesis; 5-4 split
    ?assertEqual({ok, <<"(11)99402-9275">>},
                 brutils_phone:format(<<"11994029275">>)).

format_landline_test() ->
    %% 4-4 split — the dash sits before the last four digits
    ?assertEqual({ok, <<"(16)3501-4415">>},
                 brutils_phone:format(<<"1635014415">>)).

format_invalid_phone_test() ->
    ?assertEqual({error, invalid}, brutils_phone:format(<<"333333">>)),
    ?assertEqual({error, invalid}, brutils_phone:format(<<"01994029275">>)),
    ?assertEqual({error, invalid}, brutils_phone:format(<<>>)).

format_already_formatted_is_invalid_test() ->
    ?assertEqual({error, invalid},
                 brutils_phone:format(<<"(11)99402-9275">>)).

format_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_phone:format(11994029275)),
    ?assertError(function_clause, brutils_phone:format("11994029275")).
