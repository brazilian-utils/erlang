%% @doc Tests for the {@link brutils} facade.
%%
%% The facade only delegates, so these tests pin the wiring (name,
%% arity, delegation target) — the behavior itself is covered by each
%% domain module's own suite.
-module(brutils_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% CPF
%%--------------------------------------------------------------------

is_valid_cpf_test() ->
    ?assert(brutils:is_valid_cpf(<<"82178537464">>)),
    ?assertNot(brutils:is_valid_cpf(<<"11111111111">>)),
    ?assertNot(brutils:is_valid_cpf(82178537464)).

format_cpf_test() ->
    ?assertEqual({ok, <<"821.785.374-64">>},
                 brutils:format_cpf(<<"82178537464">>)),
    ?assertEqual({error, invalid}, brutils:format_cpf(<<"123">>)).

remove_symbols_cpf_test() ->
    ?assertEqual(<<"12345678901">>,
                 brutils:remove_symbols_cpf(<<"123.456.789-01">>)).

generate_cpf_test() ->
    Cpf = brutils:generate_cpf(),
    ?assertEqual(11, byte_size(Cpf)),
    ?assert(brutils:is_valid_cpf(Cpf)).
