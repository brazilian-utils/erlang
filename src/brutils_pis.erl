%% @doc Utilities for the Brazilian PIS/PASEP (Programa de Integração
%% Social) number.
%%
%% A PIS is an 11-digit identifier assigned to workers: a 10-digit
%% base number followed by 1 check digit. It is commonly displayed as
%% `"NNN.NNNNN.NN-N"'.
%%
%% All functions operate on UTF-8 binaries. Leading zeros are
%% significant, so a PIS is never handled as an integer.
-module(brutils_pis).

-export([remove_symbols/1, is_valid/1, format/1]).

-type pis() :: <<_:88>>.
%% A raw PIS: 11 ASCII digits, e.g. `<<"12056798818">>'.

-type formatted_pis() :: <<_:112>>.
%% A display-formatted PIS, e.g. `<<"120.56798.81-8">>'.

-export_type([pis/0, formatted_pis/0]).

%% @doc Removes the formatting symbols `.' and `-' from a PIS string.
%%
%% Only those two characters are removed; any other character
%% (letters, spaces, slashes, ...) is kept unchanged. This is a pure
%% character filter: it does not validate the input.
%%
%% ```
%% 1> brutils_pis:remove_symbols(<<"120.56798.81-8">>).
%% <<"12056798818">>
%% 2> brutils_pis:remove_symbols(<<"120/567.98 81-a">>).
%% <<"120/56798 81a">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Pis) when is_binary(Pis) ->
    << <<C>> || <<C>> <= Pis, C =/= $., C =/= $- >>.

%% @doc Returns whether the given term is a valid PIS: a binary of
%% exactly 11 ASCII digits whose check digit (the last one) matches
%% the one computed from its 10-digit base.
%%
%% Unlike CPF and CNPJ, PIS reserves no repeated-digit sequences —
%% such values stand or fall by their check digit alone (notably,
%% `<<"00000000000">>' is a valid PIS). Only the format is verified —
%% the PIS is not checked for existence. Formatting symbols are not
%% stripped, so a formatted PIS such as `<<"120.56798.81-8">>' is
%% invalid; clean it with {@link remove_symbols/1} first. The
%% function is total: any non-binary term returns `false' rather
%% than raising.
%%
%% ```
%% 1> brutils_pis:is_valid(<<"12056798818">>).
%% true
%% 2> brutils_pis:is_valid(<<"12056798810">>).
%% false
%% '''
-spec is_valid(term()) -> boolean().
is_valid(Pis) when is_binary(Pis), byte_size(Pis) =:= 11 ->
    all_digits(Pis)
        andalso begin
                    <<Base10:10/binary, Dv>> = Pis,
                    Dv =:= checksum(Base10)
                end;
is_valid(_) ->
    false.

%% @doc Formats a valid PIS for display, adding the standard visual
%% aid symbols: `<<"NNN.NNNNN.NN-N">>'.
%%
%% The input must be a raw, numbers-only PIS accepted by
%% {@link is_valid/1}; anything else yields `{error, invalid}'.
%%
%% ```
%% 1> brutils_pis:format(<<"12056798818">>).
%% {ok,<<"120.56798.81-8">>}
%% 2> brutils_pis:format(<<"12056798810">>).
%% {error,invalid}
%% '''
-spec format(binary()) -> {ok, formatted_pis()} | {error, invalid}.
format(Pis) when is_binary(Pis) ->
    case is_valid(Pis) of
        true ->
            <<A:3/binary, B:5/binary, C:2/binary, Dv>> = Pis,
            {ok, <<A/binary, $., B/binary, $., C/binary, $-, Dv>>};
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

%% Weights applied to the 10 base digits, left to right.
-define(WEIGHTS, [3, 2, 9, 8, 7, 6, 5, 4, 3, 2]).

%% The check digit for a 10-digit base: weighted sum mod 11
%% subtracted from 11; results of 10 and 11 map to 0.
-spec checksum(<<_:80>>) -> byte().
checksum(Base10) ->
    Sum = weighted_sum(Base10, ?WEIGHTS, 0),
    case 11 - (Sum rem 11) of
        Dv when Dv >= 10 -> $0;
        Dv -> $0 + Dv
    end.

-spec weighted_sum(binary(), [pos_integer()], non_neg_integer()) ->
        non_neg_integer().
weighted_sum(<<C, Rest/binary>>, [W | Ws], Acc) ->
    weighted_sum(Rest, Ws, Acc + (C - $0) * W);
weighted_sum(<<>>, [], Acc) ->
    Acc.
