%% @doc Tests for {@link brutils_license_plate}.
-module(brutils_license_plate_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% remove_symbols/1
%%--------------------------------------------------------------------

remove_symbols_strips_dash_only_test() ->
    ?assertEqual(<<"ABC123">>,
                 brutils_license_plate:remove_symbols(<<"ABC-123">>)),
    ?assertEqual(<<"ABC1234">>,
                 brutils_license_plate:remove_symbols(<<"ABC-12-34">>)).

remove_symbols_keeps_everything_else_test() ->
    %% the narrowest strip set in the library: ONLY the dash goes —
    %% dots, spaces and letter case all survive
    ?assertEqual(<<"abc.12 3">>,
                 brutils_license_plate:remove_symbols(<<"abc.12 3">>)),
    ?assertEqual(<<"abc1d23">>,
                 brutils_license_plate:remove_symbols(<<"abc1d23">>)).

remove_symbols_empty_test() ->
    ?assertEqual(<<>>, brutils_license_plate:remove_symbols(<<>>)).

remove_symbols_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause,
                 brutils_license_plate:remove_symbols("ABC-123")),
    ?assertError(function_clause,
                 brutils_license_plate:remove_symbols(1234)).
