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
