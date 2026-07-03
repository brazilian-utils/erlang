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

%%--------------------------------------------------------------------
%% is_valid/1
%%--------------------------------------------------------------------

is_valid_accepts_conforming_passports_test() ->
    ?assert(brutils_passport:is_valid(<<"AB123456">>)),
    ?assert(brutils_passport:is_valid(<<"UE786447">>)),   % reference-generated
    %% corners: no reserved values exist — pin the absence
    ?assert(brutils_passport:is_valid(<<"AA000000">>)),
    ?assert(brutils_passport:is_valid(<<"ZZ999999">>)).

is_valid_rejects_mixed_case_despite_reference_docstring_test() ->
    %% the reference docstring claims is_valid("Ab123456") is True,
    %% but its regex is case-sensitive and the CODE returns False —
    %% executed and confirmed; the port follows the code
    ?assertNot(brutils_passport:is_valid(<<"Ab123456">>)),
    ?assertNot(brutils_passport:is_valid(<<"ab123456">>)),
    ?assertNot(brutils_passport:is_valid(<<"aB123456">>)).

is_valid_rejects_position_swaps_test() ->
    ?assertNot(brutils_passport:is_valid(<<"12345678">>)),   % all digits
    ?assertNot(brutils_passport:is_valid(<<"1B123456">>)),   % digit in letter slot
    ?assertNot(brutils_passport:is_valid(<<"A1123456">>)),
    ?assertNot(brutils_passport:is_valid(<<"ABA23456">>)),   % letter in digit slot
    ?assertNot(brutils_passport:is_valid(<<"AB12345A">>)),
    ?assertNot(brutils_passport:is_valid(<<"ABC12345">>)).

is_valid_rejects_wrong_length_test() ->
    ?assertNot(brutils_passport:is_valid(<<>>)),
    ?assertNot(brutils_passport:is_valid(<<"AB12345">>)),     % 7
    ?assertNot(brutils_passport:is_valid(<<"AB1234567">>)).   % 9

is_valid_rejects_symbols_test() ->
    %% no stripping — clean with remove_symbols/1 or use format/1
    ?assertNot(brutils_passport:is_valid(<<"AB-123456">>)),
    ?assertNot(brutils_passport:is_valid(<<"AB 123456">>)).

is_valid_rejects_non_binary_test() ->
    ?assertNot(brutils_passport:is_valid(12345678)),
    ?assertNot(brutils_passport:is_valid("AB123456")),   % charlist
    ?assertNot(brutils_passport:is_valid(undefined)),
    ?assertNot(brutils_passport:is_valid(#{})).

%%--------------------------------------------------------------------
%% format/1 — the normalizing formatter: uppercases and strips
%% symbols BEFORE validating (unlike every other format/1 in this
%% library, which validates raw input as-is)
%%--------------------------------------------------------------------

format_normalizes_dressed_lowercase_test() ->
    ?assertEqual({ok, <<"AB123456">>},
                 brutils_passport:format(<<"ab-123456">>)),
    ?assertEqual({ok, <<"AB123456">>},
                 brutils_passport:format(<<"Ab123456">>)),
    ?assertEqual({ok, <<"AB123456">>},
                 brutils_passport:format(<<"a b. 12-3456">>)).

format_and_is_valid_asymmetry_test() ->
    %% the whole contract in two lines: the same input is invalid raw
    %% but formats fine — lenient format, strict validate
    ?assertNot(brutils_passport:is_valid(<<"ab-123456">>)),
    ?assertEqual({ok, <<"AB123456">>},
                 brutils_passport:format(<<"ab-123456">>)).

format_passes_through_clean_input_test() ->
    ?assertEqual({ok, <<"AB123456">>},
                 brutils_passport:format(<<"AB123456">>)).

format_invalid_passport_test() ->
    ?assertEqual({error, invalid}, brutils_passport:format(<<"111111">>)),
    ?assertEqual({error, invalid}, brutils_passport:format(<<"ABC12345">>)),
    ?assertEqual({error, invalid}, brutils_passport:format(<<>>)).

format_multibyte_input_is_invalid_test() ->
    %% executed against the reference: a non-ASCII letter never
    %% becomes valid through normalization
    ?assertEqual({error, invalid},
                 brutils_passport:format(<<"áb123456"/utf8>>)).

format_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_passport:format(12345678)),
    ?assertError(function_clause, brutils_passport:format("ab-123456")).

%%--------------------------------------------------------------------
%% generate/0
%%--------------------------------------------------------------------

generate_produces_valid_passports_test() ->
    lists:foreach(
      fun(_) ->
              Passport = brutils_passport:generate(),
              ?assertEqual(8, byte_size(Passport)),
              ?assert(brutils_passport:is_valid(Passport))
      end,
      lists:seq(1, 100)).

generate_is_random_test() ->
    Passports = [brutils_passport:generate() || _ <- lists:seq(1, 100)],
    ?assert(length(lists:usort(Passports)) > 1).
