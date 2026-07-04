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
