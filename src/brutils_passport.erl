%% @doc Utilities for Brazilian passport numbers.
%%
%% A passport number has 8 characters: 2 uppercase letters followed by
%% 6 digits (e.g. `<<"AB123456">>'). There is no check digit — only
%% the shape is verified, never existence.
%%
%% All functions operate on UTF-8 binaries.
-module(brutils_passport).

-export([remove_symbols/1]).

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
