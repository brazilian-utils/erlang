%% @doc Utilities for Brazilian vehicle license plates.
%%
%% Two plate patterns exist: the old format — 3 letters followed by 4
%% digits (`"ABC1234"') — and the Mercosul format — 3 letters, a
%% digit, a letter and 2 digits (`"ABC1D23"'). Validation accepts
%% lowercase input; formatting and conversion emit uppercase.
%%
%% All functions operate on UTF-8 binaries.
-module(brutils_license_plate).

-export([remove_symbols/1, is_valid/1, is_valid/2, get_format/1,
         convert_to_mercosul/1]).

-type plate_type() :: old_format | mercosul.
%% The two plate patterns: `old_format' is `LLLNNNN', `mercosul' is
%% `LLLNLNN'.

-type plate() :: <<_:56>>.
%% A raw plate: 7 characters in either pattern, e.g. `<<"ABC1D23">>'.

-type formatted_plate() :: <<_:56>> | <<_:64>>.
%% A display-formatted plate: Mercosul plates are bare
%% (`<<"ABC1D23">>'), old-format plates carry a dash
%% (`<<"ABC-1234">>').

-export_type([plate_type/0, plate/0, formatted_plate/0]).

%% @doc Removes the dash (`-') from a license plate string.
%%
%% Only the dash is removed — the narrowest cleaning rule in this
%% library: dots, spaces and letter case are all kept unchanged. This
%% is a pure character filter: it does not validate the input.
%%
%% ```
%% 1> brutils_license_plate:remove_symbols(<<"ABC-123">>).
%% <<"ABC123">>
%% 2> brutils_license_plate:remove_symbols(<<"abc.12 3">>).
%% <<"abc.12 3">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Plate) when is_binary(Plate) ->
    << <<C>> || <<C>> <= Plate, C =/= $- >>.

%% @doc Returns whether the given term is a valid license plate of
%% either pattern, old format or Mercosul.
%%
%% Surrounding ASCII whitespace is trimmed and letter case is
%% ignored, so `<<"  abc1234 ">>' is valid — but embedded symbols
%% such as the display dash are not stripped. Existence is never
%% verified. The function is total: any non-binary term returns
%% `false' rather than raising.
%%
%% ```
%% 1> brutils_license_plate:is_valid(<<"ABC1234">>).
%% true
%% 2> brutils_license_plate:is_valid(<<"abc1d23">>).
%% true
%% '''
-spec is_valid(term()) -> boolean().
is_valid(Plate) ->
    is_valid(Plate, old_format) orelse is_valid(Plate, mercosul).

%% @doc Returns whether the given term is a valid license plate of
%% the given pattern: `old_format' (`LLLNNNN') or `mercosul'
%% (`LLLNLNN').
%%
%% Trimming and case rules are those of {@link is_valid/1}. The type
%% must be one of the two atoms; anything else is out of contract and
%% raises.
%%
%% ```
%% 1> brutils_license_plate:is_valid(<<"ABC1234">>, old_format).
%% true
%% 2> brutils_license_plate:is_valid(<<"ABC1234">>, mercosul).
%% false
%% '''
-spec is_valid(term(), plate_type()) -> boolean().
is_valid(Plate, old_format) when is_binary(Plate) ->
    case normalize(Plate) of
        <<L1, L2, L3, Digits:4/binary>>
          when L1 >= $A, L1 =< $Z, L2 >= $A, L2 =< $Z, L3 >= $A, L3 =< $Z ->
            all_digits(Digits);
        _ ->
            false
    end;
is_valid(_, old_format) ->
    false;
is_valid(Plate, mercosul) when is_binary(Plate) ->
    case normalize(Plate) of
        <<L1, L2, L3, D1, L4, D2, D3>>
          when L1 >= $A, L1 =< $Z, L2 >= $A, L2 =< $Z, L3 >= $A, L3 =< $Z,
               D1 >= $0, D1 =< $9, L4 >= $A, L4 =< $Z,
               D2 >= $0, D2 =< $9, D3 >= $0, D3 =< $9 ->
            true;
        _ ->
            false
    end;
is_valid(_, mercosul) ->
    false.

%% @doc Detects the pattern of a license plate: `{ok, old_format}'
%% for `LLLNNNN', `{ok, mercosul}' for `LLLNLNN', or
%% `{error, invalid}' when the input matches neither.
%%
%% Trimming and case rules are those of {@link is_valid/1}. The
%% result composes with {@link is_valid/2}: a detected type always
%% validates the plate it was detected from. (The reference
%% implementation returns the pattern strings `"LLLNNNN"' /
%% `"LLLNLNN"' instead — this port deliberately returns the
%% `plate_type()' atoms.)
%%
%% ```
%% 1> brutils_license_plate:get_format(<<"abc1234">>).
%% {ok,old_format}
%% 2> brutils_license_plate:get_format(<<"ABC1D23">>).
%% {ok,mercosul}
%% '''
-spec get_format(binary()) -> {ok, plate_type()} | {error, invalid}.
get_format(Plate) when is_binary(Plate) ->
    case {is_valid(Plate, old_format), is_valid(Plate, mercosul)} of
        {true, _} -> {ok, old_format};
        {_, true} -> {ok, mercosul};
        _ -> {error, invalid}
    end.

%% @doc Converts an old-format plate (`LLLNNNN') to the Mercosul
%% pattern (`LLLNLNN') by replacing the digit at position 5 with a
%% letter: `0' becomes `A', `1' becomes `B', ... `9' becomes `J'.
%%
%% The input is normalized (trimmed, uppercased) first and must be a
%% valid old-format plate — an already-Mercosul plate yields
%% `{error, invalid}', not a no-op. (For whitespace-padded input the
%% reference implementation converts the wrong position and keeps the
%% padding, an artifact of slicing the unstripped string; this port
%% deliberately normalizes first and converts correctly.)
%%
%% ```
%% 1> brutils_license_plate:convert_to_mercosul(<<"abc4567">>).
%% {ok,<<"ABC4F67">>}
%% 2> brutils_license_plate:convert_to_mercosul(<<"ABC1D23">>).
%% {error,invalid}
%% '''
-spec convert_to_mercosul(binary()) -> {ok, plate()} | {error, invalid}.
convert_to_mercosul(Plate) when is_binary(Plate) ->
    case is_valid(Plate, old_format) of
        true ->
            <<Head:4/binary, D, Tail:2/binary>> = normalize(Plate),
            {ok, <<Head/binary, ($A + D - $0), Tail/binary>>};
        false ->
            {error, invalid}
    end.

%%--------------------------------------------------------------------
%% Internal
%%--------------------------------------------------------------------

%% Trim surrounding ASCII whitespace and uppercase ASCII letters —
%% the normalization every validating function applies first.
-spec normalize(binary()) -> binary().
normalize(Plate) ->
    ascii_uppercase(trim(Plate)).

-spec trim(binary()) -> binary().
trim(<<C, Rest/binary>>) when C =:= $\s; C =:= $\t; C =:= $\n;
                              C =:= $\r; C =:= $\f; C =:= $\v ->
    trim(Rest);
trim(Bin) ->
    trim_trailing(Bin).

-spec trim_trailing(binary()) -> binary().
trim_trailing(Bin) when byte_size(Bin) > 0 ->
    case binary:last(Bin) of
        C when C =:= $\s; C =:= $\t; C =:= $\n;
               C =:= $\r; C =:= $\f; C =:= $\v ->
            trim_trailing(binary:part(Bin, 0, byte_size(Bin) - 1));
        _ ->
            Bin
    end;
trim_trailing(Bin) ->
    Bin.

-spec ascii_uppercase(binary()) -> binary().
ascii_uppercase(Bin) ->
    << <<(upcase(C))>> || <<C>> <= Bin >>.

-spec upcase(byte()) -> byte().
upcase(C) when C >= $a, C =< $z -> C - 32;
upcase(C) -> C.

-spec all_digits(binary()) -> boolean().
all_digits(<<C, Rest/binary>>) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(<<>>) -> true;
all_digits(_) -> false.
