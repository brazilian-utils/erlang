%% @doc Tests for {@link brutils_pis}.
-module(brutils_pis_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% remove_symbols/1
%%--------------------------------------------------------------------

remove_symbols_strips_dots_and_dashes_test() ->
    ?assertEqual(<<"12056798818">>,
                 brutils_pis:remove_symbols(<<"120.56798.81-8">>)),
    ?assertEqual(<<"12345678909">>,
                 brutils_pis:remove_symbols(<<"123.456.789-09">>)).

remove_symbols_keeps_everything_else_test() ->
    %% only $. and $- are stripped: slashes, spaces, letters survive
    ?assertEqual(<<"120/56798 81a">>,
                 brutils_pis:remove_symbols(<<"120/567.98 81-a">>)).

remove_symbols_empty_test() ->
    ?assertEqual(<<>>, brutils_pis:remove_symbols(<<>>)).

remove_symbols_already_clean_test() ->
    ?assertEqual(<<"12056798818">>,
                 brutils_pis:remove_symbols(<<"12056798818">>)).

remove_symbols_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_pis:remove_symbols("120.56798.81-8")),
    ?assertError(function_clause, brutils_pis:remove_symbols(12056798818)).

%%--------------------------------------------------------------------
%% is_valid/1 — shape rejection (never raises, total over term())
%%
%% Note: no repeated-digit tests here on purpose — PIS does not
%% reserve them; their fate is decided by the checksum alone and is
%% pinned in the check-digit section.
%%--------------------------------------------------------------------

is_valid_rejects_non_binary_test() ->
    ?assertNot(brutils_pis:is_valid(12056798818)),
    ?assertNot(brutils_pis:is_valid("12056798818")),   % charlist
    ?assertNot(brutils_pis:is_valid(undefined)),
    ?assertNot(brutils_pis:is_valid(#{})),
    ?assertNot(brutils_pis:is_valid(3.14)).

is_valid_rejects_wrong_length_test() ->
    ?assertNot(brutils_pis:is_valid(<<>>)),
    ?assertNot(brutils_pis:is_valid(<<"1205679881">>)),     % 10 digits
    ?assertNot(brutils_pis:is_valid(<<"120567988180">>)).   % 12 digits

is_valid_rejects_non_digit_chars_test() ->
    ?assertNot(brutils_pis:is_valid(<<"1205679881a">>)),
    ?assertNot(brutils_pis:is_valid(<<"1205679881 ">>)),
    ?assertNot(brutils_pis:is_valid(<<"-1205679881">>)).

is_valid_rejects_formatted_input_test() ->
    %% symbols are not stripped before validation
    ?assertNot(brutils_pis:is_valid(<<"120.56798.81-8">>)).
