%% @doc Utilities for Brazilian passport numbers.
%%
%% A passport number has 8 characters: 2 uppercase letters followed by
%% 6 digits (e.g. `<<"AB123456">>'). There is no check digit — only
%% the shape is verified, never existence.
%%
%% All functions operate on UTF-8 binaries.
-module(brutils_passport).

-export([remove_symbols/1, is_valid/1, format/1, generate/0]).

-type passport() :: <<_:64>>.
%% A passport number: 2 uppercase ASCII letters + 6 ASCII digits.

-export_type([passport/0]).

%% @doc Removes the symbols `-', `.' and spaces from a passport
%% string.
%%
%% Only those three characters are removed; anything else — including
%% underscores and slashes — is kept unchanged, and letter case is
%% preserved (uppercasing is {@link format/1}'s job). This is a pure
%% character filter: it does not validate the input.
%%
%% ```
%% 1> brutils_passport:remove_symbols(<<"Ab -. 123456">>).
%% <<"Ab123456">>
%% 2> brutils_passport:remove_symbols(<<"ab_123/456">>).
%% <<"ab_123/456">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Passport) when is_binary(Passport) ->
    << <<C>> || <<C>> <= Passport, C =/= $-, C =/= $., C =/= $\s >>.

%% @doc Returns whether the given term is a valid passport number:
%% exactly 2 uppercase ASCII letters followed by exactly 6 digits.
%%
%% The check is case-sensitive — lowercase letters are invalid — and
%% no symbols are stripped; use {@link format/1} to normalize dressed
%% or lowercase input first. (The reference implementation's
%% docstring claims mixed case is accepted; its code rejects it, and
%% this port follows the code.) There is no check digit, so any
%% shape-conforming value is valid — existence is never verified. The
%% function is total: any non-binary term returns `false' rather
%% than raising.
%%
%% ```
%% 1> brutils_passport:is_valid(<<"AB123456">>).
%% true
%% 2> brutils_passport:is_valid(<<"Ab123456">>).
%% false
%% '''
-spec is_valid(term()) -> boolean().
is_valid(<<L1, L2, Digits:6/binary>>)
  when L1 >= $A, L1 =< $Z, L2 >= $A, L2 =< $Z ->
    all_digits(Digits);
is_valid(_) ->
    false.

%% @doc Normalizes and formats a passport number for display:
%% uppercases ASCII letters and strips the symbols `-', `.' and
%% spaces, then validates the result.
%%
%% This is the lenient counterpart to the strict {@link is_valid/1}:
%% `format(<<"ab-123456">>)' succeeds where
%% `is_valid(<<"ab-123456">>)' is `false'. Input that does not
%% normalize into a valid passport — including non-ASCII letters —
%% yields `{error, invalid}'.
%%
%% ```
%% 1> brutils_passport:format(<<"ab-123456">>).
%% {ok,<<"AB123456">>}
%% 2> brutils_passport:format(<<"111111">>).
%% {error,invalid}
%% '''
-spec format(binary()) -> {ok, passport()} | {error, invalid}.
format(Passport) when is_binary(Passport) ->
    Normalized = remove_symbols(ascii_uppercase(Passport)),
    case is_valid(Normalized) of
        true -> {ok, Normalized};
        false -> {error, invalid}
    end.

%% @doc Generates a random valid passport number: 2 uniform uppercase
%% letters followed by 6 uniform digits.
%%
%% With no check digit to compute, every output is valid by
%% construction.
%%
%% ```
%% 1> brutils_passport:generate().
%% <<"HA029151">>
%% '''
-spec generate() -> passport().
generate() ->
    <<($A + rand:uniform(26) - 1), ($A + rand:uniform(26) - 1),
      (digits(6))/binary>>.

%%--------------------------------------------------------------------
%% Internal
%%--------------------------------------------------------------------

-spec digits(pos_integer()) -> binary().
digits(N) ->
    << <<($0 + rand:uniform(10) - 1)>> || _ <- lists:seq(1, N) >>.

%% Uppercase ASCII letters only; every other byte is left unchanged
%% (multibyte input therefore simply fails the later validation).
-spec ascii_uppercase(binary()) -> binary().
ascii_uppercase(Bin) ->
    << <<(case C >= $a andalso C =< $z of
              true -> C - 32;
              false -> C
          end)>> || <<C>> <= Bin >>.

-spec all_digits(binary()) -> boolean().
all_digits(<<C, Rest/binary>>) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(<<>>) -> true;
all_digits(_) -> false.
