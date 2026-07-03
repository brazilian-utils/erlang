%% @doc Utilities for the Brazilian CNPJ (Cadastro Nacional da Pessoa
%% Jurídica).
%%
%% A CNPJ is a 14-character company identifier: an 8-character root, a
%% 4-character branch number (usually `0001') and 2 numeric check
%% digits. It is commonly displayed as `"XX.XXX.XXX/XXXX-XX"'. Since
%% the 2026 Receita Federal change the first 12 characters may be
%% alphanumeric (digits and uppercase letters); the check digits are
%% always numeric.
%%
%% All functions operate on UTF-8 binaries. Leading zeros are
%% significant, so a CNPJ is never handled as an integer.
-module(brutils_cnpj).

-export([remove_symbols/1, is_valid/1, format/1, generate/0, generate/1]).

-type cnpj() :: <<_:112>>.
%% A raw CNPJ: 14 characters, digits or uppercase letters with numeric
%% check digits, e.g. `<<"03560714000142">>'.

-type formatted_cnpj() :: <<_:144>>.
%% A display-formatted CNPJ, e.g. `<<"03.560.714/0001-42">>'.

-export_type([cnpj/0, formatted_cnpj/0]).

%% @doc Removes the formatting symbols `.', `/' and `-' from a CNPJ
%% string.
%%
%% Only those three characters are removed; any other character
%% (letters, spaces, ...) is kept unchanged. This is a pure character
%% filter: it does not validate the input.
%%
%% ```
%% 1> brutils_cnpj:remove_symbols(<<"03.560.714/0001-42">>).
%% <<"03560714000142">>
%% 2> brutils_cnpj:remove_symbols(<<"a-b c!">>).
%% <<"ab c!">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Cnpj) when is_binary(Cnpj) ->
    << <<C>> || <<C>> <= Cnpj, C =/= $., C =/= $/, C =/= $- >>.

%% @doc Returns whether the given term is a valid CNPJ: a 14-character
%% binary whose first 12 characters are digits or uppercase letters,
%% whose last 2 characters are digits, which is not a sequence of one
%% repeated character, and whose two check digits match the ones
%% computed from its 12-character base.
%%
%% Only the format is verified — the CNPJ is not checked for
%% existence. Lowercase letters are always invalid — they are never
%% case-folded. Formatting symbols are not stripped, so a formatted
%% CNPJ such as `<<"03.560.714/0001-42">>' is invalid; clean it with
%% {@link remove_symbols/1} first. The function is total: any
%% non-binary term returns `false' rather than raising.
%%
%% ```
%% 1> brutils_cnpj:is_valid(<<"03560714000142">>).
%% true
%% 2> brutils_cnpj:is_valid(<<"00111222000133">>).
%% false
%% '''
-spec is_valid(term()) -> boolean().
is_valid(<<First, _/binary>> = Cnpj) when byte_size(Cnpj) =:= 14 ->
    <<Base12:12/binary, Dvs:2/binary>> = Cnpj,
    alphanumeric(Base12)
        andalso all_digits(Dvs)
        andalso not repeated(Cnpj, First)
        andalso Dvs =:= checksum(Base12);
is_valid(_) ->
    false.

%% @doc Formats a valid CNPJ for display, adding the standard visual
%% aid symbols: `<<"XX.XXX.XXX/XXXX-XX">>'.
%%
%% The input must be a raw, symbols-free CNPJ accepted by
%% {@link is_valid/1} — numeric or alphanumeric; anything else yields
%% `{error, invalid}'.
%%
%% ```
%% 1> brutils_cnpj:format(<<"03560714000142">>).
%% {ok,<<"03.560.714/0001-42">>}
%% 2> brutils_cnpj:format(<<"00111222000133">>).
%% {error,invalid}
%% '''
-spec format(binary()) -> {ok, formatted_cnpj()} | {error, invalid}.
format(Cnpj) when is_binary(Cnpj) ->
    case is_valid(Cnpj) of
        true ->
            <<A:2/binary, B:3/binary, C:3/binary,
              Branch:4/binary, Dvs:2/binary>> = Cnpj,
            {ok, <<A/binary, $., B/binary, $., C/binary,
                   $/, Branch/binary, $-, Dvs/binary>>};
        false ->
            {error, invalid}
    end.

%% @doc Generates a random valid CNPJ with branch number `0001'.
%%
%% Equivalent to `generate(1)'.
%%
%% ```
%% 1> brutils_cnpj:generate().
%% <<"05864803000108">>
%% '''
-spec generate() -> cnpj().
generate() ->
    generate(1).

%% @doc Generates a random valid CNPJ with the given branch number.
%%
%% The branch may be a non-negative integer or a digits-only binary.
%% It is normalized to 4 digits: reduced modulo 10000, bumped to 1
%% when the reduction yields 0, and zero-padded. A negative integer or
%% a binary containing anything but ASCII digits is out of contract
%% and raises.
%%
%% ```
%% 1> brutils_cnpj:generate(42).
%% <<"38082273004273">>
%% 2> brutils_cnpj:generate(<<"12">>).
%% <<"12695023001208">>
%% '''
-spec generate(Branch :: non_neg_integer() | binary()) -> cnpj().
generate(Branch) ->
    Branch4 = normalize_branch(Branch),
    N = rand:uniform(100000000) - 1,
    Root = list_to_binary(io_lib:format("~8..0b", [N])),
    Base12 = <<Root/binary, Branch4/binary>>,
    <<Base12/binary, (checksum(Base12))/binary>>.

%%--------------------------------------------------------------------
%% Internal
%%--------------------------------------------------------------------

%% Normalize a branch number to its 4-digit form: modulo 10000,
%% zero bumped to 1, zero-padded.
-spec normalize_branch(non_neg_integer() | binary()) -> <<_:32>>.
normalize_branch(Branch) when is_integer(Branch), Branch >= 0 ->
    B0 = Branch rem 10000,
    B = case B0 of
            0 -> 1;
            _ -> B0
        end,
    list_to_binary(io_lib:format("~4..0b", [B]));
normalize_branch(Branch) when is_binary(Branch), Branch =/= <<>> ->
    case all_digits(Branch) of
        true -> normalize_branch(binary_to_integer(Branch));
        false -> error(badarg)
    end;
normalize_branch(Branch) when is_binary(Branch) ->
    error(badarg).

%% Every byte is a digit or an uppercase letter?
-spec alphanumeric(binary()) -> boolean().
alphanumeric(<<C, Rest/binary>>) when C >= $0, C =< $9; C >= $A, C =< $Z ->
    alphanumeric(Rest);
alphanumeric(<<>>) -> true;
alphanumeric(_) -> false.

-spec all_digits(binary()) -> boolean().
all_digits(<<C, Rest/binary>>) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(<<>>) -> true;
all_digits(_) -> false.

%% All bytes equal to the first one?
-spec repeated(binary(), byte()) -> boolean().
repeated(Cnpj, First) ->
    Cnpj =:= binary:copy(<<First>>, byte_size(Cnpj)).

%% The two check digits for a 12-character base: the first is computed
%% over the base, the second over the base plus the first.
-spec checksum(<<_:96>>) -> <<_:16>>.
checksum(Base12) ->
    Dv1 = $0 + hash_digit(Base12, 13),
    Dv2 = $0 + hash_digit(<<Base12/binary, Dv1>>, 14),
    <<Dv1, Dv2>>.

%% Check digit for position `Position': weighted sum of the preceding
%% characters, mod 11; values below 2 map to 0, otherwise the digit is
%% the complement to 11. Weights descend from `Position - 8' to 2 and
%% then restart at 9, descending to 2 again. Character values are
%% ASCII-based (`C - $0'), so digits map to 0..9 and uppercase letters
%% to 17..42 — the same rule covers numeric and alphanumeric CNPJs.
-spec hash_digit(binary(), 13 | 14) -> 0..9.
hash_digit(Chars, Position) ->
    Sum = weighted_sum(Chars, Position - 8, 0),
    case Sum rem 11 of
        Val when Val < 2 -> 0;
        Val -> 11 - Val
    end.

-spec weighted_sum(binary(), 2..9, non_neg_integer()) -> non_neg_integer().
weighted_sum(<<C, Rest/binary>>, Weight, Acc) ->
    Next = case Weight of
               2 -> 9;
               _ -> Weight - 1
           end,
    weighted_sum(Rest, Next, Acc + (C - $0) * Weight);
weighted_sum(<<>>, _Weight, Acc) ->
    Acc.
