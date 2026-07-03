%% @doc Utilities for the Brazilian CPF (Cadastro de Pessoas Físicas).
%%
%% A CPF is an 11-digit identifier assigned to individuals: a 9-digit
%% base number followed by 2 check digits. It is commonly displayed as
%% `"XXX.XXX.XXX-XX"'.
%%
%% All functions operate on UTF-8 binaries. Leading zeros are
%% significant, so a CPF is never handled as an integer.
-module(brutils_cpf).

-export([remove_symbols/1, is_valid/1, format/1]).

-type cpf() :: <<_:88>>.
%% A raw CPF: 11 ASCII digits, e.g. `<<"82178537464">>'.

-type formatted_cpf() :: <<_:112>>.
%% A display-formatted CPF, e.g. `<<"821.785.374-64">>'.

-export_type([cpf/0, formatted_cpf/0]).

%% @doc Removes the formatting symbols `.' and `-' from a CPF string.
%%
%% Only those two characters are removed; any other character (letters,
%% spaces, slashes, ...) is kept unchanged. This is a pure character
%% filter: it does not validate the input.
%%
%% ```
%% 1> brutils_cpf:remove_symbols(<<"123.456.789-01">>).
%% <<"12345678901">>
%% 2> brutils_cpf:remove_symbols(<<"abc//1">>).
%% <<"abc//1">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Cpf) when is_binary(Cpf) ->
    << <<C>> || <<C>> <= Cpf, C =/= $., C =/= $- >>.

%% @doc Returns whether the given term is a valid CPF: a binary of
%% exactly 11 ASCII digits, not a sequence of one repeated digit
%% (`<<"00000000000">>' and the like are reserved and always invalid),
%% whose two check digits match its 9-digit base number.
%%
%% Only the format is verified — the CPF is not checked for existence.
%% Formatting symbols are not stripped, so a formatted CPF such as
%% `<<"821.785.374-64">>' is invalid; clean it with
%% {@link remove_symbols/1} first. The function is total: any
%% non-binary term returns `false' rather than raising.
%%
%% ```
%% 1> brutils_cpf:is_valid(<<"82178537464">>).
%% true
%% 2> brutils_cpf:is_valid(<<"82178537460">>).
%% false
%% '''
-spec is_valid(term()) -> boolean().
is_valid(<<First, _/binary>> = Cpf) when byte_size(Cpf) =:= 11 ->
    all_digits(Cpf)
        andalso not repeated(Cpf, First)
        andalso checksum_ok(Cpf);
is_valid(_) ->
    false.

%% @doc Formats a valid CPF for display, adding the standard visual
%% aid symbols: `<<"XXX.XXX.XXX-XX">>'.
%%
%% The input must be a raw, numbers-only CPF accepted by
%% {@link is_valid/1}; anything else yields `{error, invalid}'.
%%
%% ```
%% 1> brutils_cpf:format(<<"82178537464">>).
%% {ok,<<"821.785.374-64">>}
%% 2> brutils_cpf:format(<<"11111111111">>).
%% {error,invalid}
%% '''
-spec format(binary()) -> {ok, formatted_cpf()} | {error, invalid}.
format(Cpf) when is_binary(Cpf) ->
    case is_valid(Cpf) of
        true ->
            <<A:3/binary, B:3/binary, C:3/binary, Dv:2/binary>> = Cpf,
            {ok, <<A/binary, $., B/binary, $., C/binary, $-, Dv/binary>>};
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

%% All bytes equal to the first one?
-spec repeated(binary(), byte()) -> boolean().
repeated(Cpf, First) ->
    Cpf =:= binary:copy(<<First>>, byte_size(Cpf)).

%% Both check digits (bytes 10 and 11) match the ones computed from
%% the digits preceding them.
-spec checksum_ok(binary()) -> boolean().
checksum_ok(Cpf) ->
    <<Base9:9/binary, Dv1, Dv2>> = Cpf,
    Dv1 =:= $0 + hash_digit(Base9, 10)
        andalso Dv2 =:= $0 + hash_digit(<<Base9/binary, Dv1>>, 11).

%% Check digit for position `Position': weighted sum of the preceding
%% digits with weights descending from `Position' to 2, mod 11; values
%% below 2 map to 0, otherwise the digit is the complement to 11.
-spec hash_digit(binary(), 10 | 11) -> 0..9.
hash_digit(Digits, Position) ->
    Sum = weighted_sum(Digits, Position, 0),
    case Sum rem 11 of
        Val when Val < 2 -> 0;
        Val -> 11 - Val
    end.

weighted_sum(<<C, Rest/binary>>, Weight, Acc) ->
    weighted_sum(Rest, Weight - 1, Acc + (C - $0) * Weight);
weighted_sum(<<>>, _Weight, Acc) ->
    Acc.
