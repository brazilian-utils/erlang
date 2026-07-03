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
