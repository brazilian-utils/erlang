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

%%--------------------------------------------------------------------
%% is_valid/1 — shape rejection (never raises, total over term())
%%--------------------------------------------------------------------

is_valid_rejects_non_binary_test() ->
    ?assertNot(brutils_cnpj:is_valid(3560714000142)),
    ?assertNot(brutils_cnpj:is_valid("03560714000142")),   % charlist
    ?assertNot(brutils_cnpj:is_valid(undefined)),
    ?assertNot(brutils_cnpj:is_valid(#{})),
    ?assertNot(brutils_cnpj:is_valid(3.14)).

is_valid_rejects_wrong_length_test() ->
    ?assertNot(brutils_cnpj:is_valid(<<>>)),
    ?assertNot(brutils_cnpj:is_valid(<<"0356071400014">>)),     % 13 chars
    ?assertNot(brutils_cnpj:is_valid(<<"035607140001420">>)).   % 15 chars

is_valid_rejects_lowercase_letters_test() ->
    %% alphanumeric CNPJs are uppercase only — lowercase is never folded
    ?assertNot(brutils_cnpj:is_valid(<<"nx9k79e2ab1200">>)),
    ?assertNot(brutils_cnpj:is_valid(<<"0356071400a142">>)).

is_valid_rejects_letters_in_check_digit_positions_test() ->
    %% chars 13-14 must be digits even in the alphanumeric format
    ?assertNot(brutils_cnpj:is_valid(<<"035607140001A2">>)),
    ?assertNot(brutils_cnpj:is_valid(<<"0356071400014A">>)).

is_valid_rejects_formatted_input_test() ->
    %% symbols are not stripped before validation
    ?assertNot(brutils_cnpj:is_valid(<<"03.560.714/0001-42">>)).

is_valid_rejects_other_symbols_test() ->
    ?assertNot(brutils_cnpj:is_valid(<<"0011-22200013!">>)),
    ?assertNot(brutils_cnpj:is_valid(<<"03560714 00142">>)).

is_valid_rejects_repeated_chars_test() ->
    lists:foreach(
      fun(D) ->
              Cnpj = binary:copy(<<D>>, 14),
              ?assertNot(brutils_cnpj:is_valid(Cnpj))
      end,
      lists:seq($0, $9) ++ [$A, $Z]).

%%--------------------------------------------------------------------
%% is_valid/1 — check digits (numeric CNPJs)
%%--------------------------------------------------------------------

is_valid_accepts_valid_cnpjs_test() ->
    %% 12345678901230 and 98765432100141 embed the reference checksum
    %% vectors ("123456789012" -> "30", "987654321001" -> "41"); the
    %% rest are fixtures produced by the reference implementation.
    Valid = [<<"03560714000142">>,
             <<"12345678901230">>,
             <<"98765432100141">>,
             <<"64426433000196">>,
             <<"98071092000103">>,
             <<"50696019000192">>,
             <<"33562977123407">>],
    lists:foreach(fun(C) -> ?assert(brutils_cnpj:is_valid(C)) end, Valid).

is_valid_rejects_bad_check_digits_test() ->
    ?assertNot(brutils_cnpj:is_valid(<<"00111222000133">>)).

is_valid_rejects_bad_second_check_digit_test() ->
    %% every wrong value for the last digit of a valid CNPJ must fail
    Base = <<"0356071400014">>,
    lists:foreach(
      fun(D) when D =:= $2 -> ok;
         (D) -> ?assertNot(brutils_cnpj:is_valid(<<Base/binary, D>>))
      end,
      lists:seq($0, $9)).

is_valid_rejects_bad_first_check_digit_test() ->
    %% corrupt the 13th char ($4 in 03560714000142), keep the rest
    lists:foreach(
      fun(D) when D =:= $4 -> ok;
         (D) ->
              Cnpj = <<"035607140001", D, "2">>,
              ?assertNot(brutils_cnpj:is_valid(Cnpj))
      end,
      lists:seq($0, $9)).

%%--------------------------------------------------------------------
%% is_valid/1 — check digits (alphanumeric CNPJs)
%%--------------------------------------------------------------------

%% Fixtures produced by the reference implementation; character values
%% are ASCII-based (`C - $0'), so letters weigh 17..42 in the checksum.
alphanumeric_fixtures() ->
    [<<"6Q4E392H000190">>,
     <<"534M1541000164">>,
     <<"K379QJ73000104">>,
     <<"08W10Q81000153">>,
     <<"715K130N000173">>,
     <<"8577HE6NAB1249">>].   % alphanumeric branch (AB12)

is_valid_accepts_alphanumeric_cnpjs_test() ->
    lists:foreach(fun(C) -> ?assert(brutils_cnpj:is_valid(C)) end,
                  alphanumeric_fixtures()).

is_valid_rejects_lowercased_alphanumeric_test() ->
    lists:foreach(
      fun(C) ->
              ?assertNot(brutils_cnpj:is_valid(string:lowercase(C)))
      end,
      alphanumeric_fixtures()).

is_valid_rejects_bad_alphanumeric_second_check_digit_test() ->
    Base = <<"6Q4E392H00019">>,
    lists:foreach(
      fun(D) when D =:= $0 -> ok;
         (D) -> ?assertNot(brutils_cnpj:is_valid(<<Base/binary, D>>))
      end,
      lists:seq($0, $9)).

is_valid_rejects_bad_alphanumeric_first_check_digit_test() ->
    %% corrupt the 13th char ($9 in 6Q4E392H000190), keep the rest
    lists:foreach(
      fun(D) when D =:= $9 -> ok;
         (D) ->
              Cnpj = <<"6Q4E392H0001", D, "0">>,
              ?assertNot(brutils_cnpj:is_valid(Cnpj))
      end,
      lists:seq($0, $9)).

is_valid_rejects_corrupted_alphanumeric_base_test() ->
    %% swapping one base letter for another changes the checksum
    ?assertNot(brutils_cnpj:is_valid(<<"6Q4E392I000190">>)),   % H -> I
    ?assertNot(brutils_cnpj:is_valid(<<"7Q4E392H000190">>)).   % 6 -> 7

%%--------------------------------------------------------------------
%% format/1
%%--------------------------------------------------------------------

format_valid_cnpj_test() ->
    ?assertEqual({ok, <<"03.560.714/0001-42">>},
                 brutils_cnpj:format(<<"03560714000142">>)),
    ?assertEqual({ok, <<"64.426.433/0001-96">>},
                 brutils_cnpj:format(<<"64426433000196">>)).

format_valid_alphanumeric_cnpj_test() ->
    ?assertEqual({ok, <<"6Q.4E3.92H/0001-90">>},
                 brutils_cnpj:format(<<"6Q4E392H000190">>)),
    ?assertEqual({ok, <<"85.77H.E6N/AB12-49">>},
                 brutils_cnpj:format(<<"8577HE6NAB1249">>)).

format_invalid_cnpj_test() ->
    ?assertEqual({error, invalid}, brutils_cnpj:format(<<"00111222000133">>)),
    ?assertEqual({error, invalid}, brutils_cnpj:format(<<"11111111111111">>)),
    ?assertEqual({error, invalid}, brutils_cnpj:format(<<"0356071400014">>)),
    ?assertEqual({error, invalid}, brutils_cnpj:format(<<>>)).

format_already_formatted_is_invalid_test() ->
    %% format/1 does not strip symbols before validating
    ?assertEqual({error, invalid},
                 brutils_cnpj:format(<<"03.560.714/0001-42">>)).

format_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_cnpj:format(3560714000142)),
    ?assertError(function_clause, brutils_cnpj:format("03560714000142")).
