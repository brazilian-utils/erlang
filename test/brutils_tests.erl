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

%%--------------------------------------------------------------------
%% CNPJ
%%--------------------------------------------------------------------

is_valid_cnpj_test() ->
    ?assert(brutils:is_valid_cnpj(<<"03560714000142">>)),
    ?assert(brutils:is_valid_cnpj(<<"6Q4E392H000190">>)),   % alphanumeric
    ?assertNot(brutils:is_valid_cnpj(<<"00111222000133">>)),
    ?assertNot(brutils:is_valid_cnpj(3560714000142)).

format_cnpj_test() ->
    ?assertEqual({ok, <<"03.560.714/0001-42">>},
                 brutils:format_cnpj(<<"03560714000142">>)),
    ?assertEqual({error, invalid}, brutils:format_cnpj(<<"123">>)).

remove_symbols_cnpj_test() ->
    ?assertEqual(<<"03560714000142">>,
                 brutils:remove_symbols_cnpj(<<"03.560.714/0001-42">>)).

generate_cnpj_test() ->
    Cnpj = brutils:generate_cnpj(),
    ?assertEqual(14, byte_size(Cnpj)),
    ?assert(brutils:is_valid_cnpj(Cnpj)).

generate_cnpj_with_branch_test() ->
    Cnpj = brutils:generate_cnpj(42),
    ?assertEqual(<<"0042">>, binary:part(Cnpj, 8, 4)),
    ?assert(brutils:is_valid_cnpj(Cnpj)).

generate_cnpj_alphanumeric_test() ->
    Cnpj = brutils:generate_cnpj(<<"AB12">>, true),
    ?assertEqual(<<"AB12">>, binary:part(Cnpj, 8, 4)),
    ?assert(brutils:is_valid_cnpj(Cnpj)).

%%--------------------------------------------------------------------
%% PIS
%%--------------------------------------------------------------------

is_valid_pis_test() ->
    ?assert(brutils:is_valid_pis(<<"12056798818">>)),
    ?assertNot(brutils:is_valid_pis(<<"12056798810">>)),
    ?assertNot(brutils:is_valid_pis(12056798818)).

format_pis_test() ->
    ?assertEqual({ok, <<"120.56798.81-8">>},
                 brutils:format_pis(<<"12056798818">>)),
    ?assertEqual({error, invalid}, brutils:format_pis(<<"123">>)).

remove_symbols_pis_test() ->
    ?assertEqual(<<"12056798818">>,
                 brutils:remove_symbols_pis(<<"120.56798.81-8">>)).

generate_pis_test() ->
    Pis = brutils:generate_pis(),
    ?assertEqual(11, byte_size(Pis)),
    ?assert(brutils:is_valid_pis(Pis)).

%%--------------------------------------------------------------------
%% CNH
%%--------------------------------------------------------------------

is_valid_cnh_test() ->
    ?assert(brutils:is_valid_cnh(<<"98765432100">>)),
    ?assert(brutils:is_valid_cnh(<<"987654321-00">>)),   % symbols stripped
    ?assertNot(brutils:is_valid_cnh(<<"12345678901">>)),
    ?assertNot(brutils:is_valid_cnh(98765432100)).

%%--------------------------------------------------------------------
%% RENAVAM
%%--------------------------------------------------------------------

is_valid_renavam_test() ->
    ?assert(brutils:is_valid_renavam(<<"86769597308">>)),
    ?assertNot(brutils:is_valid_renavam(<<"867695973-08">>)),  % NOT stripped
    ?assertNot(brutils:is_valid_renavam(<<"12345678901">>)),
    ?assertNot(brutils:is_valid_renavam(86769597308)).

%%--------------------------------------------------------------------
%% CEP
%%--------------------------------------------------------------------

is_valid_cep_test() ->
    ?assert(brutils:is_valid_cep(<<"01310200">>)),
    ?assertNot(brutils:is_valid_cep(<<"01310-200">>)),
    ?assertNot(brutils:is_valid_cep(1310200)).

format_cep_test() ->
    ?assertEqual({ok, <<"01310-200">>},
                 brutils:format_cep(<<"01310200">>)),
    ?assertEqual({error, invalid}, brutils:format_cep(<<"123">>)).

remove_symbols_cep_test() ->
    ?assertEqual(<<"01310200">>,
                 brutils:remove_symbols_cep(<<"01310-200">>)).

generate_cep_test() ->
    Cep = brutils:generate_cep(),
    ?assertEqual(8, byte_size(Cep)),
    ?assert(brutils:is_valid_cep(Cep)).
