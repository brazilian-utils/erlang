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

%%--------------------------------------------------------------------
%% is_valid/1 — check digit
%%--------------------------------------------------------------------

is_valid_accepts_valid_pis_test() ->
    %% fixtures produced by the reference implementation; note the
    %% leading zero in the third one
    Valid = [<<"12056798818">>,
             <<"63544726985">>,
             <<"87317582025">>,
             <<"03002242154">>,
             <<"48517716822">>,
             <<"34723871722">>],
    lists:foreach(fun(P) -> ?assert(brutils_pis:is_valid(P)) end, Valid).

is_valid_repeated_digits_follow_the_checksum_test() ->
    %% PIS reserves nothing: all-zeros has weighted sum 0, so its
    %% check digit is 0 and it is genuinely VALID; the other nine
    %% repeated sequences fail the checksum. Pinned from the
    %% reference implementation.
    ?assert(brutils_pis:is_valid(<<"00000000000">>)),
    lists:foreach(
      fun(D) ->
              Pis = binary:copy(<<D>>, 11),
              ?assertNot(brutils_pis:is_valid(Pis))
      end,
      lists:seq($1, $9)).

is_valid_rejects_bad_check_digit_test() ->
    %% every wrong value for the last digit of a valid PIS must fail
    Base = <<"1205679881">>,
    lists:foreach(
      fun(D) when D =:= $8 -> ok;
         (D) -> ?assertNot(brutils_pis:is_valid(<<Base/binary, D>>))
      end,
      lists:seq($0, $9)).

is_valid_rejects_borrowed_cpf_docstring_example_test() ->
    %% the reference docstring reuses a CPF value as its example;
    %% executing the reference shows it is NOT a valid PIS
    ?assertNot(brutils_pis:is_valid(<<"82178537464">>)).
