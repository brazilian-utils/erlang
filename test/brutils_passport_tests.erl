%% @doc Tests for {@link brutils_passport}.
-module(brutils_passport_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% remove_symbols/1
%%--------------------------------------------------------------------

remove_symbols_strips_dash_dot_space_test() ->
    ?assertEqual(<<"Ab123456">>,
                 brutils_passport:remove_symbols(<<"Ab -. 123456">>)),
    ?assertEqual(<<"AB123456">>,
                 brutils_passport:remove_symbols(<<"AB-123.456">>)).

remove_symbols_preserves_case_test() ->
    %% this function does NOT uppercase — that's format/1's job
    ?assertEqual(<<"ab123456">>,
                 brutils_passport:remove_symbols(<<"ab-123456">>)).

remove_symbols_keeps_everything_else_test() ->
    %% only $-, $. and space go: underscores and slashes survive
    %% (the strip set differs from CPF/CNPJ/phone — don't borrow theirs)
    ?assertEqual(<<"ab_123/456">>,
                 brutils_passport:remove_symbols(<<"ab_123/456">>)).

remove_symbols_empty_test() ->
    ?assertEqual(<<>>, brutils_passport:remove_symbols(<<>>)).

remove_symbols_already_clean_test() ->
    ?assertEqual(<<"AB123456">>,
                 brutils_passport:remove_symbols(<<"AB123456">>)).

remove_symbols_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_passport:remove_symbols("AB-123456")),
    ?assertError(function_clause, brutils_passport:remove_symbols(123456)).
