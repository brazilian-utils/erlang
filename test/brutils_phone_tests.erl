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
