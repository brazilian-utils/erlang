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
