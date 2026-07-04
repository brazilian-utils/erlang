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

%%--------------------------------------------------------------------
%% Phone
%%--------------------------------------------------------------------

is_valid_phone_test() ->
    ?assert(brutils:is_valid_phone(<<"11994029275">>)),
    ?assert(brutils:is_valid_phone(<<"1635014415">>)),
    ?assertNot(brutils:is_valid_phone(<<"333333">>)),
    ?assertNot(brutils:is_valid_phone(11994029275)).

is_valid_phone_typed_test() ->
    ?assert(brutils:is_valid_phone(<<"11994029275">>, mobile)),
    ?assertNot(brutils:is_valid_phone(<<"11994029275">>, landline)).

format_phone_test() ->
    ?assertEqual({ok, <<"(11)99402-9275">>},
                 brutils:format_phone(<<"11994029275">>)),
    ?assertEqual({error, invalid}, brutils:format_phone(<<"333333">>)).

remove_symbols_phone_test() ->
    ?assertEqual(<<"5511994029275">>,
                 brutils:remove_symbols_phone(<<"+55 (11) 99402-9275">>)).

remove_international_dialing_code_test() ->
    ?assertEqual(<<"11994029275">>,
                 brutils:remove_international_dialing_code(<<"5511994029275">>)),
    ?assertEqual(<<"1635014415">>,
                 brutils:remove_international_dialing_code(<<"1635014415">>)).

generate_phone_test() ->
    ?assert(brutils:is_valid_phone(brutils:generate_phone())),
    ?assert(brutils:is_valid_phone(brutils:generate_phone(mobile), mobile)),
    ?assert(brutils:is_valid_phone(brutils:generate_phone(landline), landline)).

%%--------------------------------------------------------------------
%% Passport
%%--------------------------------------------------------------------

is_valid_passport_test() ->
    ?assert(brutils:is_valid_passport(<<"AB123456">>)),
    ?assertNot(brutils:is_valid_passport(<<"Ab123456">>)),   % case-sensitive
    ?assertNot(brutils:is_valid_passport(12345678)).

format_passport_test() ->
    %% the lenient-format / strict-validate asymmetry survives the facade
    ?assertNot(brutils:is_valid_passport(<<"ab-123456">>)),
    ?assertEqual({ok, <<"AB123456">>},
                 brutils:format_passport(<<"ab-123456">>)),
    ?assertEqual({error, invalid}, brutils:format_passport(<<"111111">>)).

remove_symbols_passport_test() ->
    ?assertEqual(<<"Ab123456">>,
                 brutils:remove_symbols_passport(<<"Ab -. 123456">>)).

generate_passport_test() ->
    Passport = brutils:generate_passport(),
    ?assertEqual(8, byte_size(Passport)),
    ?assert(brutils:is_valid_passport(Passport)).

%%--------------------------------------------------------------------
%% License plate
%%--------------------------------------------------------------------

is_valid_license_plate_test() ->
    ?assert(brutils:is_valid_license_plate(<<"ABC1234">>)),
    ?assert(brutils:is_valid_license_plate(<<"abc1d23">>)),
    ?assertNot(brutils:is_valid_license_plate(<<"ABC-1234">>)),
    ?assertNot(brutils:is_valid_license_plate(1234567)).

is_valid_license_plate_typed_test() ->
    ?assert(brutils:is_valid_license_plate(<<"ABC1234">>, old_format)),
    ?assertNot(brutils:is_valid_license_plate(<<"ABC1234">>, mercosul)).

format_license_plate_test() ->
    ?assertEqual({ok, <<"ABC-1234">>},
                 brutils:format_license_plate(<<"abc1234">>)),
    ?assertEqual({error, invalid}, brutils:format_license_plate(<<"ABC123">>)).

remove_symbols_license_plate_test() ->
    ?assertEqual(<<"ABC123">>,
                 brutils:remove_symbols_license_plate(<<"ABC-123">>)).

convert_license_plate_to_mercosul_test() ->
    %% the facade name matches the reference's export exactly
    ?assertEqual({ok, <<"ABC4F67">>},
                 brutils:convert_license_plate_to_mercosul(<<"ABC4567">>)),
    ?assertEqual({error, invalid},
                 brutils:convert_license_plate_to_mercosul(<<"ABC1D23">>)).

get_format_license_plate_test() ->
    ?assertEqual({ok, old_format},
                 brutils:get_format_license_plate(<<"ABC1234">>)),
    ?assertEqual({ok, mercosul},
                 brutils:get_format_license_plate(<<"ABC1D23">>)).

generate_license_plate_test() ->
    {ok, Default} = brutils:generate_license_plate(),
    ?assert(brutils:is_valid_license_plate(Default, mercosul)),
    {ok, Old} = brutils:generate_license_plate(<<"LLLNNNN">>),
    ?assert(brutils:is_valid_license_plate(Old, old_format)),
    ?assertEqual({error, invalid},
                 brutils:generate_license_plate(<<"XXXXXXX">>)).
