%% @doc Utilities for Brazilian passport numbers.
%%
%% A passport number has 8 characters: 2 uppercase letters followed by
%% 6 digits (e.g. `<<"AB123456">>'). There is no check digit — only
%% the shape is verified, never existence.
%%
%% All functions operate on UTF-8 binaries.
-module(brutils_passport).

-export([remove_symbols/1, is_valid/1]).

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

%%--------------------------------------------------------------------
%% Internal
%%--------------------------------------------------------------------

-spec all_digits(binary()) -> boolean().
all_digits(<<C, Rest/binary>>) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(<<>>) -> true;
all_digits(_) -> false.
