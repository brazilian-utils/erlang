%% @doc Utilities for the Brazilian CEP (Código de Endereçamento
%% Postal).
%%
%% A CEP is an 8-digit postal code, commonly displayed as
%% `"NNNNN-NNN"'. It carries no check digit: validation is purely
%% structural and says nothing about whether the code exists.
%%
%% All functions operate on UTF-8 binaries. Leading zeros are
%% significant, so a CEP is never handled as an integer.
-module(brutils_cep).

-export([remove_symbols/1, is_valid/1, format/1]).

-type cep() :: <<_:64>>.
%% A raw CEP: 8 ASCII digits, e.g. `<<"01310200">>'.

-type formatted_cep() :: <<_:72>>.
%% A display-formatted CEP, e.g. `<<"01310-200">>'.

-export_type([cep/0, formatted_cep/0]).

%% @doc Removes the formatting symbols `.' and `-' from a CEP string.
%%
%% Only those two characters are removed; any other character
%% (letters, spaces, slashes, ...) is kept unchanged. This is a pure
%% character filter: it does not validate the input.
%%
%% ```
%% 1> brutils_cep:remove_symbols(<<"01310-200">>).
%% <<"01310200">>
%% 2> brutils_cep:remove_symbols(<<"abc.xyz">>).
%% <<"abcxyz">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Cep) when is_binary(Cep) ->
    << <<C>> || <<C>> <= Cep, C =/= $., C =/= $- >>.

%% @doc Returns whether the given term is a valid CEP: a binary of
%% exactly 8 ASCII digits.
%%
%% That is the entire rule — a CEP carries no check digit, so any
%% 8-digit sequence is structurally valid (including repeated ones
%% like `<<"00000000">>'), and validity says nothing about whether
%% the postal code exists. Formatting symbols are not stripped, so
%% `<<"01310-200">>' is invalid; clean it with
%% {@link remove_symbols/1} first. The function is total: any
%% non-binary term returns `false' rather than raising.
%%
%% ```
%% 1> brutils_cep:is_valid(<<"01310200">>).
%% true
%% 2> brutils_cep:is_valid(<<"01310-200">>).
%% false
%% '''
-spec is_valid(term()) -> boolean().
is_valid(Cep) when is_binary(Cep), byte_size(Cep) =:= 8 ->
    all_digits(Cep);
is_valid(_) ->
    false.

%% @doc Formats a valid CEP for display, adding the standard dash:
%% `<<"NNNNN-NNN">>'.
%%
%% The input must be a raw, numbers-only CEP accepted by
%% {@link is_valid/1}; anything else yields `{error, invalid}'.
%%
%% ```
%% 1> brutils_cep:format(<<"01310200">>).
%% {ok,<<"01310-200">>}
%% 2> brutils_cep:format(<<"1234567">>).
%% {error,invalid}
%% '''
-spec format(binary()) -> {ok, formatted_cep()} | {error, invalid}.
format(Cep) when is_binary(Cep) ->
    case is_valid(Cep) of
        true ->
            <<A:5/binary, B:3/binary>> = Cep,
            {ok, <<A/binary, $-, B/binary>>};
        false ->
            {error, invalid}
    end.

%%--------------------------------------------------------------------
%% Internal
%%--------------------------------------------------------------------

-spec all_digits(binary()) -> boolean().
all_digits(<<C, Rest/binary>>) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(<<>>) -> true;
all_digits(_) -> false.
