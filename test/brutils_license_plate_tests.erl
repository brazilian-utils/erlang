%% @doc Tests for {@link brutils_license_plate}.
-module(brutils_license_plate_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% remove_symbols/1
%%--------------------------------------------------------------------

remove_symbols_strips_dash_only_test() ->
    ?assertEqual(<<"ABC123">>,
                 brutils_license_plate:remove_symbols(<<"ABC-123">>)),
    ?assertEqual(<<"ABC1234">>,
                 brutils_license_plate:remove_symbols(<<"ABC-12-34">>)).

remove_symbols_keeps_everything_else_test() ->
    %% the narrowest strip set in the library: ONLY the dash goes —
    %% dots, spaces and letter case all survive
    ?assertEqual(<<"abc.12 3">>,
                 brutils_license_plate:remove_symbols(<<"abc.12 3">>)),
    ?assertEqual(<<"abc1d23">>,
                 brutils_license_plate:remove_symbols(<<"abc1d23">>)).

remove_symbols_empty_test() ->
    ?assertEqual(<<>>, brutils_license_plate:remove_symbols(<<>>)).

remove_symbols_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause,
                 brutils_license_plate:remove_symbols("ABC-123")),
    ?assertError(function_clause,
                 brutils_license_plate:remove_symbols(1234)).

%%--------------------------------------------------------------------
%% is_valid/1,2
%%--------------------------------------------------------------------

is_valid_accepts_both_shapes_and_cases_test() ->
    ?assert(brutils_license_plate:is_valid(<<"ABC1234">>)),
    ?assert(brutils_license_plate:is_valid(<<"abc1234">>)),
    ?assert(brutils_license_plate:is_valid(<<"ABC1D23">>)),
    ?assert(brutils_license_plate:is_valid(<<"abc1d23">>)).

is_valid_trims_surrounding_whitespace_test() ->
    %% parity quirk (executed): the reference strips surrounding
    %% whitespace inside its validators — padded plates are valid.
    %% The port trims the ASCII whitespace set.
    ?assert(brutils_license_plate:is_valid(<<"  ABC1234 ">>)),
    ?assert(brutils_license_plate:is_valid(<<"\tABC1D23\n">>)).

is_valid_typed_matches_shape_test() ->
    ?assert(brutils_license_plate:is_valid(<<"ABC1234">>, old_format)),
    ?assert(brutils_license_plate:is_valid(<<"ABC1D23">>, mercosul)),
    %% cross-type rejection; note position 4 is the discriminator
    ?assertNot(brutils_license_plate:is_valid(<<"ABC1234">>, mercosul)),
    ?assertNot(brutils_license_plate:is_valid(<<"ABC1D23">>, old_format)).

is_valid_rejects_boundary_swaps_test() ->
    %% digit in a letter slot (positions 0-2)
    ?assertNot(brutils_license_plate:is_valid(<<"1BC1234">>)),
    ?assertNot(brutils_license_plate:is_valid(<<"AB11234">>)),
    %% letter in a digit slot: old 3-6, mercosul 3, 5, 6
    ?assertNot(brutils_license_plate:is_valid(<<"ABCA234">>)),   % pos 3, both shapes
    ?assertNot(brutils_license_plate:is_valid(<<"ABC1DA3">>)),   % pos 5
    ?assertNot(brutils_license_plate:is_valid(<<"ABC1D2A">>)).   % pos 6

is_valid_rejects_wrong_length_test() ->
    ?assertNot(brutils_license_plate:is_valid(<<>>)),
    ?assertNot(brutils_license_plate:is_valid(<<"ABC123">>)),      % 6
    ?assertNot(brutils_license_plate:is_valid(<<"ABCD1234">>)),    % 8
    ?assertNot(brutils_license_plate:is_valid(<<"ABCD123">>)).     % 4 letters

is_valid_rejects_symbols_test() ->
    %% the dash is NOT stripped by validation (only remove_symbols does)
    ?assertNot(brutils_license_plate:is_valid(<<"ABC-1234">>)).

is_valid_rejects_non_binary_test() ->
    ?assertNot(brutils_license_plate:is_valid(1234567)),
    ?assertNot(brutils_license_plate:is_valid("ABC1234")),   % charlist
    ?assertNot(brutils_license_plate:is_valid(undefined)),
    ?assertNot(brutils_license_plate:is_valid(#{})).

is_valid_unknown_type_is_out_of_contract_test() ->
    %% same tightening as brutils_phone: only the two atoms
    ?assertError(function_clause,
                 brutils_license_plate:is_valid(<<"ABC1234">>, oldformat)),
    ?assertError(function_clause,
                 brutils_license_plate:is_valid(<<"ABC1234">>, "old_format")).

%%--------------------------------------------------------------------
%% get_format/1
%%
%% Returns plate_type() atoms — a documented divergence from the
%% reference's pattern strings ("LLLNNNN"/"LLLNLNN"), so the result
%% composes with is_valid/2.
%%--------------------------------------------------------------------

get_format_detects_old_format_test() ->
    ?assertEqual({ok, old_format},
                 brutils_license_plate:get_format(<<"ABC1234">>)),
    ?assertEqual({ok, old_format},
                 brutils_license_plate:get_format(<<"abc1234">>)).

get_format_detects_mercosul_test() ->
    ?assertEqual({ok, mercosul},
                 brutils_license_plate:get_format(<<"ABC1D23">>)),
    ?assertEqual({ok, mercosul},
                 brutils_license_plate:get_format(<<"abc1d23">>)).

get_format_trims_like_the_validators_test() ->
    ?assertEqual({ok, old_format},
                 brutils_license_plate:get_format(<<" abc1234 ">>)).

get_format_rejects_invalid_plates_test() ->
    %% the reference docstring's own example "abc123" (6 chars) is
    %% invalid — executed: the code returns None for it
    ?assertEqual({error, invalid},
                 brutils_license_plate:get_format(<<"abc123">>)),
    ?assertEqual({error, invalid},
                 brutils_license_plate:get_format(<<"ABCD123">>)),
    ?assertEqual({error, invalid},
                 brutils_license_plate:get_format(<<"ABC-1234">>)).

get_format_composes_with_is_valid_test() ->
    %% the point of the atoms: the detected type validates the plate
    {ok, T1} = brutils_license_plate:get_format(<<"ABC1234">>),
    ?assert(brutils_license_plate:is_valid(<<"ABC1234">>, T1)),
    {ok, T2} = brutils_license_plate:get_format(<<"ABC1D23">>),
    ?assert(brutils_license_plate:is_valid(<<"ABC1D23">>, T2)).

get_format_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_license_plate:get_format(1234567)).

%%--------------------------------------------------------------------
%% convert_to_mercosul/1
%%--------------------------------------------------------------------

convert_maps_each_digit_to_its_letter_test() ->
    %% position 4 digit D becomes the letter $A + D; all ten pinned
    %% from the executed reference
    Expected = [{$0, $A}, {$1, $B}, {$2, $C}, {$3, $D}, {$4, $E},
                {$5, $F}, {$6, $G}, {$7, $H}, {$8, $I}, {$9, $J}],
    lists:foreach(
      fun({D, L}) ->
              ?assertEqual({ok, <<"ABC4", L, "67">>},
                           brutils_license_plate:convert_to_mercosul(
                             <<"ABC4", D, "67">>))
      end,
      Expected).

convert_uppercases_lowercase_input_test() ->
    ?assertEqual({ok, <<"ABC4F67">>},
                 brutils_license_plate:convert_to_mercosul(<<"abc4567">>)).

convert_rejects_mercosul_input_test() ->
    %% already-converted plates are not old format — error, not a no-op
    ?assertEqual({error, invalid},
                 brutils_license_plate:convert_to_mercosul(<<"ABC1D23">>)).

convert_rejects_invalid_input_test() ->
    ?assertEqual({error, invalid},
                 brutils_license_plate:convert_to_mercosul(<<"ABC4*67">>)),
    ?assertEqual({error, invalid},
                 brutils_license_plate:convert_to_mercosul(<<"ABC123">>)).

convert_normalizes_padded_input_test() ->
    %% deliberate deviation: for padded input the reference converts
    %% the wrong position and keeps the spaces (' ABC4567 ' ->
    %% ' ABCE567 ', executed) because it slices the unstripped
    %% string; the port normalizes first and converts correctly
    ?assertEqual({ok, <<"ABC4F67">>},
                 brutils_license_plate:convert_to_mercosul(<<" ABC4567 ">>)).

convert_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause,
                 brutils_license_plate:convert_to_mercosul(1234567)).

%%--------------------------------------------------------------------
%% format/1
%%--------------------------------------------------------------------

format_old_format_gets_dash_test() ->
    ?assertEqual({ok, <<"ABC-1234">>},
                 brutils_license_plate:format(<<"ABC1234">>)),
    ?assertEqual({ok, <<"ABC-1234">>},
                 brutils_license_plate:format(<<"abc1234">>)).

format_mercosul_is_bare_uppercase_test() ->
    ?assertEqual({ok, <<"ABC1E34">>},
                 brutils_license_plate:format(<<"abc1e34">>)),
    ?assertEqual({ok, <<"ABC1D23">>},
                 brutils_license_plate:format(<<"ABC1D23">>)).

format_normalizes_padded_input_test() ->
    %% deliberate deviation: the reference returns ' AB-C1234 ' for
    %% padded input (executed) — dash misplaced, spaces kept — because
    %% it slices the unstripped string; the port normalizes first
    ?assertEqual({ok, <<"ABC-1234">>},
                 brutils_license_plate:format(<<" abc1234 ">>)).

format_invalid_plate_test() ->
    ?assertEqual({error, invalid},
                 brutils_license_plate:format(<<"ABC123">>)),
    ?assertEqual({error, invalid},
                 brutils_license_plate:format(<<"ABCD123">>)),
    ?assertEqual({error, invalid}, brutils_license_plate:format(<<>>)).

format_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_license_plate:format(1234567)),
    ?assertError(function_clause, brutils_license_plate:format("ABC1234")).

%%--------------------------------------------------------------------
%% generate/0,1
%%--------------------------------------------------------------------

generate_default_is_mercosul_test() ->
    lists:foreach(
      fun(_) ->
              {ok, Plate} = brutils_license_plate:generate(),
              ?assertEqual(7, byte_size(Plate)),
              ?assert(brutils_license_plate:is_valid(Plate, mercosul))
      end,
      lists:seq(1, 100)).

generate_old_format_pattern_test() ->
    lists:foreach(
      fun(_) ->
              {ok, Plate} = brutils_license_plate:generate(<<"LLLNNNN">>),
              ?assert(brutils_license_plate:is_valid(Plate, old_format))
      end,
      lists:seq(1, 100)).

generate_mercosul_pattern_test() ->
    {ok, Plate} = brutils_license_plate:generate(<<"LLLNLNN">>),
    ?assert(brutils_license_plate:is_valid(Plate, mercosul)).

generate_pattern_is_case_insensitive_test() ->
    {ok, Plate} = brutils_license_plate:generate(<<"lllnlnn">>),
    ?assert(brutils_license_plate:is_valid(Plate, mercosul)).

generate_rejects_unknown_pattern_test() ->
    ?assertEqual({error, invalid},
                 brutils_license_plate:generate(<<"XXXXXXX">>)),
    ?assertEqual({error, invalid},
                 brutils_license_plate:generate(<<"LLLNNN">>)),
    ?assertEqual({error, invalid}, brutils_license_plate:generate(<<>>)).

generate_is_random_test() ->
    Plates = [element(2, brutils_license_plate:generate())
              || _ <- lists:seq(1, 100)],
    ?assert(length(lists:usort(Plates)) > 1).
