%% @doc Tests for {@link brutils_cnh}.
-module(brutils_cnh_tests).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% is_valid/1 — shape rejection and symbol stripping
%%
%% Unlike CPF/CNPJ/PIS, CNH strips every non-digit character BEFORE
%% validating: formatted input is as valid as clean input, and
%% letters are removed rather than rejected.
%%--------------------------------------------------------------------

is_valid_rejects_non_binary_test() ->
    ?assertNot(brutils_cnh:is_valid(98765432100)),
    ?assertNot(brutils_cnh:is_valid("98765432100")),   % charlist
    ?assertNot(brutils_cnh:is_valid(undefined)),
    ?assertNot(brutils_cnh:is_valid(#{})),
    ?assertNot(brutils_cnh:is_valid(3.14)).

is_valid_rejects_empty_and_symbol_only_test() ->
    ?assertNot(brutils_cnh:is_valid(<<>>)),
    ?assertNot(brutils_cnh:is_valid(<<"abc-def">>)),   % no digits at all
    ?assertNot(brutils_cnh:is_valid(<<"---">>)).

is_valid_rejects_wrong_length_after_stripping_test() ->
    ?assertNot(brutils_cnh:is_valid(<<"9876543210">>)),      % 10 digits
    ?assertNot(brutils_cnh:is_valid(<<"987654321000">>)),    % 12 digits
    %% letters are STRIPPED, not rejected: this fails because only
    %% 9 digits remain, not because letters are illegal
    ?assertNot(brutils_cnh:is_valid(<<"A2C45678901">>)),
    %% symbols hiding a short number
    ?assertNot(brutils_cnh:is_valid(<<"98-76-54-32">>)).

is_valid_rejects_repeated_digits_test() ->
    %% pinned from the executed reference: all ten fail
    lists:foreach(
      fun(D) ->
              Cnh = binary:copy(<<D>>, 11),
              ?assertNot(brutils_cnh:is_valid(Cnh))
      end,
      lists:seq($0, $9)).

is_valid_strips_symbols_before_validating_test() ->
    %% dressing a CNH in any non-digit junk never changes the verdict
    Pairs = [{<<"987654321-00">>, <<"98765432100">>},
             {<<"9 8765432100">>, <<"98765432100">>},
             {<<"9.8.7.6.5.4.3.2.1-0/0">>, <<"98765432100">>},
             {<<"111.111.111-12">>, <<"11111111112">>}],
    lists:foreach(
      fun({Dressed, Clean}) ->
              ?assertEqual(brutils_cnh:is_valid(Clean),
                           brutils_cnh:is_valid(Dressed))
      end,
      Pairs).
