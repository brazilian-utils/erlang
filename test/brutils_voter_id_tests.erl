%% @doc Tests for {@link brutils_voter_id}.
-module(brutils_voter_id_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% is_valid/1 — shape and gate rejection (never raises, total)
%%
%% A voter id is read from the RIGHT: last 2 bytes are check digits,
%% the 2 before them the federative-union code, the rest (8 or 9
%% digits) the sequential number.
%%--------------------------------------------------------------------

is_valid_rejects_non_binary_test() ->
    ?assertNot(brutils_voter_id:is_valid(690847092828)),
    ?assertNot(brutils_voter_id:is_valid("690847092828")),   % charlist
    ?assertNot(brutils_voter_id:is_valid(undefined)),
    ?assertNot(brutils_voter_id:is_valid(#{})),
    ?assertNot(brutils_voter_id:is_valid(3.14)).

is_valid_rejects_non_digit_chars_test() ->
    ?assertNot(brutils_voter_id:is_valid(<<"69084709282a">>)),
    ?assertNot(brutils_voter_id:is_valid(<<"6908 4709 28 28">>)).

is_valid_rejects_wrong_length_test() ->
    ?assertNot(brutils_voter_id:is_valid(<<>>)),
    ?assertNot(brutils_voter_id:is_valid(<<"34763531018">>)),      % 11
    ?assertNot(brutils_voter_id:is_valid(<<"34763531018300">>)).   % 14

is_valid_rejects_13_digits_outside_sp_mg_test() ->
    %% 13 digits are allowed only when the federative union (read
    %% from the right) is 01 (SP) or 02 (MG); this is a valid RJ
    %% title with a digit inserted — executed: the reference rejects
    ?assertNot(brutils_voter_id:is_valid(<<"9197377050361">>)).

is_valid_rejects_out_of_range_federative_union_test() ->
    %% both carry DVs computed by the reference's own arithmetic on
    %% the out-of-range FU, so the FU gate — not the checksum — is
    %% what rejects them
    ?assertNot(brutils_voter_id:is_valid(<<"123456780094">>)),   % FU 00
    ?assertNot(brutils_voter_id:is_valid(<<"123456782992">>)).   % FU 29

%%--------------------------------------------------------------------
%% is_valid/1 — check digits
%%--------------------------------------------------------------------

%% One reference-generated fixture per federative union, 01..28.
uf_fixtures() ->
    [<<"347635310183">>, <<"390248360230">>, <<"919737700361">>,
     <<"918159200426">>, <<"249274760507">>, <<"875112640612">>,
     <<"309450520779">>, <<"894139120868">>, <<"197514690930">>,
     <<"302208571074">>, <<"860278141104">>, <<"985189801201">>,
     <<"251489351333">>, <<"174768961465">>, <<"095062211511">>,
     <<"713118581600">>, <<"287101821775">>, <<"999508911813">>,
     <<"395481601902">>, <<"040230392020">>, <<"579257312127">>,
     <<"169512522259">>, <<"918265102305">>, <<"816583532461">>,
     <<"019370822526">>, <<"370221952682">>, <<"196911262755">>,
     <<"114018942844">>].

is_valid_accepts_one_fixture_per_uf_test() ->
    ?assert(brutils_voter_id:is_valid(<<"690847092828">>)),   % spec anchor
    lists:foreach(fun(V) -> ?assert(brutils_voter_id:is_valid(V)) end,
                  uf_fixtures()).

vd1_rem_zero_sp_maps_to_one_test() ->
    %% weighted sum rem 11 =:= 0 with FU 01: vd1 becomes 1, not 0
    ?assert(brutils_voter_id:is_valid(<<"756048060116">>)).

vd1_rem_zero_elsewhere_stays_zero_test() ->
    %% same sequential, FU 05 (BA): the rule is CONDITIONAL — vd1
    %% stays 0
    ?assert(brutils_voter_id:is_valid(<<"756048060507">>)).

vd1_rem_ten_maps_to_zero_test() ->
    ?assert(brutils_voter_id:is_valid(<<"840905360108">>)).

vd2_rem_zero_sp_maps_to_one_test() ->
    ?assert(brutils_voter_id:is_valid(<<"146881970141">>)).

vd2_rem_ten_maps_to_zero_test() ->
    ?assert(brutils_voter_id:is_valid(<<"146881970540">>)).

is_valid_accepts_13_digit_sp_and_ignores_digit_9_test() ->
    %% same SP title, two different inserted 9th digits, both valid —
    %% the checksum reads only the first 8 sequential digits
    ?assert(brutils_voter_id:is_valid(<<"3476353100183">>)),
    ?assert(brutils_voter_id:is_valid(<<"3476353190183">>)).

is_valid_rejects_repeated_digits_test() ->
    %% no reservation rule exists — all ten fail on checksum alone,
    %% pinned from the executed reference
    lists:foreach(
      fun(D) ->
              ?assertNot(brutils_voter_id:is_valid(binary:copy(<<D>>, 12)))
      end,
      lists:seq($0, $9)).

is_valid_rejects_bad_vd2_test() ->
    Base = <<"34763531018">>,
    lists:foreach(
      fun(D) when D =:= $3 -> ok;
         (D) -> ?assertNot(brutils_voter_id:is_valid(<<Base/binary, D>>))
      end,
      lists:seq($0, $9)).

is_valid_rejects_bad_vd1_test() ->
    lists:foreach(
      fun(D) when D =:= $8 -> ok;
         (D) ->
              V = <<"3476353101", D, "3">>,
              ?assertNot(brutils_voter_id:is_valid(V))
      end,
      lists:seq($0, $9)).

fu_swap_can_coincide_test() ->
    %% counterexample evidence, executed: swapping the FU of a valid
    %% title CAN coincidentally produce matching check digits — these
    %% two FU-swapped variants of the SP fixture are genuinely valid.
    %% (This is why no fu-corruption property exists in the proper
    %% suite.)
    ?assert(brutils_voter_id:is_valid(<<"347635311783">>)),   % FU 17
    ?assert(brutils_voter_id:is_valid(<<"347635312283">>)).   % FU 22

%%--------------------------------------------------------------------
%% format/1
%%--------------------------------------------------------------------

format_valid_voter_id_test() ->
    %% grouping is 4-4-2-2 with spaces
    ?assertEqual({ok, <<"6908 4709 28 28">>},
                 brutils_voter_id:format(<<"690847092828">>)),
    ?assertEqual({ok, <<"3476 3531 01 83">>},
                 brutils_voter_id:format(<<"347635310183">>)).

format_rejects_valid_13_digit_titles_test() ->
    %% deliberate deviation: for a VALID 13-digit SP/MG title the
    %% reference silently slices the first 12 digits, producing
    %% '3476 3531 00 18' for input 3476353100183 (executed) — the
    %% last digit is dropped and every group shifts, corrupting the
    %% value. The port refuses instead of corrupting.
    ?assert(brutils_voter_id:is_valid(<<"3476353100183">>)),
    ?assertEqual({error, invalid},
                 brutils_voter_id:format(<<"3476353100183">>)).

format_invalid_voter_id_test() ->
    ?assertEqual({error, invalid},
                 brutils_voter_id:format(<<"690847092820">>)),   % bad vd2
    ?assertEqual({error, invalid},
                 brutils_voter_id:format(<<"34763531018">>)),    % 11 digits
    ?assertEqual({error, invalid}, brutils_voter_id:format(<<>>)).

format_non_binary_is_out_of_contract_test() ->
    ?assertError(function_clause, brutils_voter_id:format(690847092828)),
    ?assertError(function_clause, brutils_voter_id:format("690847092828")).

%%--------------------------------------------------------------------
%% generate/0,1
%%--------------------------------------------------------------------

ufs_with_codes() ->
    [{<<"SP">>, <<"01">>}, {<<"MG">>, <<"02">>}, {<<"RJ">>, <<"03">>},
     {<<"RS">>, <<"04">>}, {<<"BA">>, <<"05">>}, {<<"PR">>, <<"06">>},
     {<<"CE">>, <<"07">>}, {<<"PE">>, <<"08">>}, {<<"SC">>, <<"09">>},
     {<<"GO">>, <<"10">>}, {<<"MA">>, <<"11">>}, {<<"PB">>, <<"12">>},
     {<<"PA">>, <<"13">>}, {<<"ES">>, <<"14">>}, {<<"PI">>, <<"15">>},
     {<<"RN">>, <<"16">>}, {<<"AL">>, <<"17">>}, {<<"MT">>, <<"18">>},
     {<<"MS">>, <<"19">>}, {<<"DF">>, <<"20">>}, {<<"SE">>, <<"21">>},
     {<<"AM">>, <<"22">>}, {<<"RO">>, <<"23">>}, {<<"AC">>, <<"24">>},
     {<<"AP">>, <<"25">>}, {<<"RR">>, <<"26">>}, {<<"TO">>, <<"27">>},
     {<<"ZZ">>, <<"28">>}].

generate_covers_all_28_ufs_test() ->
    lists:foreach(
      fun({Uf, Code}) ->
              {ok, V} = brutils_voter_id:generate(Uf),
              ?assertEqual(12, byte_size(V)),
              ?assert(brutils_voter_id:is_valid(V)),
              ?assertEqual(Code, binary:part(V, 8, 2))
      end,
      ufs_with_codes()).

generate_default_is_zz_test() ->
    {ok, V} = brutils_voter_id:generate(),
    ?assert(brutils_voter_id:is_valid(V)),
    ?assertEqual(<<"28">>, binary:part(V, 8, 2)).

generate_uf_is_case_insensitive_test() ->
    {ok, V} = brutils_voter_id:generate(<<"sp">>),
    ?assertEqual(<<"01">>, binary:part(V, 8, 2)).

generate_rejects_unknown_uf_test() ->
    ?assertEqual({error, invalid}, brutils_voter_id:generate(<<"XX">>)),
    ?assertEqual({error, invalid}, brutils_voter_id:generate(<<"S">>)),
    ?assertEqual({error, invalid}, brutils_voter_id:generate(<<>>)).

generate_is_random_test() ->
    Ids = [element(2, brutils_voter_id:generate()) || _ <- lists:seq(1, 100)],
    ?assert(length(lists:usort(Ids)) > 1).
