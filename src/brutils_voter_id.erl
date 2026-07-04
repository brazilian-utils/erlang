%% @doc Validation, formatting and generation for the Brazilian voter
%% id (título de eleitor).
%%
%% A voter id is read from the RIGHT: the last 2 digits are check
%% digits, the 2 before them encode the federative union (`01' for
%% São Paulo through `27' for Tocantins, `28' for titles issued
%% abroad), and everything in front is the sequential number —
%% normally 8 digits (12 in total), but 9 for some São Paulo and
%% Minas Gerais titles (13 in total).
%%
%% All functions operate on UTF-8 binaries.
-module(brutils_voter_id).

-export([is_valid/1, format/1, generate/0, generate/1]).

-type voter_id() :: <<_:96>>.
%% A generated voter id: always 12 digits. (Valid input may also be
%% 13 digits for São Paulo and Minas Gerais titles.)

-type formatted_voter_id() :: <<_:120>>.
%% A display-formatted voter id, e.g. `<<"6908 4709 28 28">>'.

-export_type([voter_id/0, formatted_voter_id/0]).

%% @doc Returns whether the given term is a valid voter id: an
%% all-digit binary of 12 digits — or 13 when the federative union
%% code (the two digits before the final two) is `01' or `02' —
%% whose federative union code is in the range `01'..`28' and whose
%% two check digits match the ones computed from the first 8
%% sequential digits and the federative union.
%%
%% The 9th sequential digit of a 13-digit title is ignored by the
%% checksum. Only the format is verified — the title is not checked
%% for existence. The function is total: any non-binary term returns
%% `false' rather than raising.
%%
%% ```
%% 1> brutils_voter_id:is_valid(<<"690847092828">>).
%% true
%% 2> brutils_voter_id:is_valid(<<"690847092820">>).
%% false
%% '''
-spec is_valid(term()) -> boolean().
is_valid(VoterId) when is_binary(VoterId),
                       byte_size(VoterId) =:= 12;
                       is_binary(VoterId),
                       byte_size(VoterId) =:= 13 ->
    all_digits(VoterId)
        andalso length_allowed(VoterId)
        andalso fu_in_range(fu(VoterId))
        andalso checksum_ok(VoterId);
is_valid(_) ->
    false.

%% @doc Formats a valid 12-digit voter id for display with visual
%% spacing: `<<"NNNN NNNN NN NN">>'.
%%
%% Valid 13-digit São Paulo / Minas Gerais titles yield
%% `{error, invalid}': the display mask has no slot for the 9th
%% sequential digit. (The reference implementation silently slices
%% the first 12 digits of such titles, dropping the last digit and
%% shifting every group — corrupting the value; this port refuses
%% instead of corrupting.)
%%
%% ```
%% 1> brutils_voter_id:format(<<"690847092828">>).
%% {ok,<<"6908 4709 28 28">>}
%% 2> brutils_voter_id:format(<<"3476353100183">>).
%% {error,invalid}
%% '''
-spec format(binary()) -> {ok, formatted_voter_id()} | {error, invalid}.
format(VoterId) when is_binary(VoterId) ->
    case byte_size(VoterId) =:= 12 andalso is_valid(VoterId) of
        true ->
            <<A:4/binary, B:4/binary, C:2/binary, D:2/binary>> = VoterId,
            {ok, <<A/binary, $\s, B/binary, $\s, C/binary, $\s, D/binary>>};
        false ->
            {error, invalid}
    end.

%% @doc Generates a random valid voter id for a title issued abroad
%% (federative union `ZZ').
%%
%% Equivalent to `generate(<<"ZZ">>)', but with no error case — the
%% default is always a known federative union.
%%
%% ```
%% 1> brutils_voter_id:generate().
%% {ok,<<"721636202895">>}
%% '''
-spec generate() -> {ok, voter_id()}.
generate() ->
    {ok, from_uf_code(<<"28">>)}.

%% @doc Generates a random valid voter id for the given federative
%% union (two-letter code, case insensitive; `<<"ZZ">>' for titles
%% issued abroad).
%%
%% The result always has 12 digits — the 13-digit São Paulo / Minas
%% Gerais variant is never generated. Unknown codes yield
%% `{error, invalid}'.
%%
%% ```
%% 1> brutils_voter_id:generate(<<"sp">>).
%% {ok,<<"454300320183">>}
%% 2> brutils_voter_id:generate(<<"XX">>).
%% {error,invalid}
%% '''
-spec generate(binary()) -> {ok, voter_id()} | {error, invalid}.
generate(Uf) when is_binary(Uf) ->
    case uf_code(ascii_uppercase(Uf)) of
        {ok, Code} -> {ok, from_uf_code(Code)};
        error -> {error, invalid}
    end.

%%--------------------------------------------------------------------
%% Internal
%%--------------------------------------------------------------------

%% Build a valid 12-digit id: random 8-digit sequential, the given
%% federative-union code, both check digits.
-spec from_uf_code(<<_:16>>) -> voter_id().
from_uf_code(Code) ->
    N = rand:uniform(100000000) - 1,
    Seq8 = list_to_binary(io_lib:format("~8..0b", [N])),
    Vd1 = vd1(Seq8, Code),
    Vd2 = vd2(Code, Vd1),
    <<Seq8/binary, Code/binary, ($0 + Vd1), ($0 + Vd2)>>.

%% The TSE numbering of the federative unions.
-spec uf_code(binary()) -> {ok, <<_:16>>} | error.
uf_code(<<"SP">>) -> {ok, <<"01">>};
uf_code(<<"MG">>) -> {ok, <<"02">>};
uf_code(<<"RJ">>) -> {ok, <<"03">>};
uf_code(<<"RS">>) -> {ok, <<"04">>};
uf_code(<<"BA">>) -> {ok, <<"05">>};
uf_code(<<"PR">>) -> {ok, <<"06">>};
uf_code(<<"CE">>) -> {ok, <<"07">>};
uf_code(<<"PE">>) -> {ok, <<"08">>};
uf_code(<<"SC">>) -> {ok, <<"09">>};
uf_code(<<"GO">>) -> {ok, <<"10">>};
uf_code(<<"MA">>) -> {ok, <<"11">>};
uf_code(<<"PB">>) -> {ok, <<"12">>};
uf_code(<<"PA">>) -> {ok, <<"13">>};
uf_code(<<"ES">>) -> {ok, <<"14">>};
uf_code(<<"PI">>) -> {ok, <<"15">>};
uf_code(<<"RN">>) -> {ok, <<"16">>};
uf_code(<<"AL">>) -> {ok, <<"17">>};
uf_code(<<"MT">>) -> {ok, <<"18">>};
uf_code(<<"MS">>) -> {ok, <<"19">>};
uf_code(<<"DF">>) -> {ok, <<"20">>};
uf_code(<<"SE">>) -> {ok, <<"21">>};
uf_code(<<"AM">>) -> {ok, <<"22">>};
uf_code(<<"RO">>) -> {ok, <<"23">>};
uf_code(<<"AC">>) -> {ok, <<"24">>};
uf_code(<<"AP">>) -> {ok, <<"25">>};
uf_code(<<"RR">>) -> {ok, <<"26">>};
uf_code(<<"TO">>) -> {ok, <<"27">>};
uf_code(<<"ZZ">>) -> {ok, <<"28">>};
uf_code(_) -> error.

-spec ascii_uppercase(binary()) -> binary().
ascii_uppercase(Bin) ->
    << <<(upcase(C))>> || <<C>> <= Bin >>.

-spec upcase(byte()) -> byte().
upcase(C) when C >= $a, C =< $z -> C - 32;
upcase(C) -> C.

%% The federative-union code: bytes [-4, -2) from the right.
-spec fu(binary()) -> binary().
fu(VoterId) ->
    binary:part(VoterId, byte_size(VoterId) - 4, 2).

%% 12 digits always; 13 only for São Paulo (01) and Minas Gerais (02).
-spec length_allowed(binary()) -> boolean().
length_allowed(VoterId) when byte_size(VoterId) =:= 12 ->
    true;
length_allowed(VoterId) ->
    case fu(VoterId) of
        <<"01">> -> true;
        <<"02">> -> true;
        _ -> false
    end.

-spec fu_in_range(binary()) -> boolean().
fu_in_range(Fu) ->
    Fu >= <<"01">> andalso Fu =< <<"28">>.

-spec all_digits(binary()) -> boolean().
all_digits(<<C, Rest/binary>>) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(<<>>) -> true;
all_digits(_) -> false.

%% Both check digits (the last two bytes) match the ones computed
%% from the first 8 sequential digits and the federative union. The
%% second digit is computed from the FIRST — a corrupted vd1 usually
%% breaks vd2 too.
-spec checksum_ok(binary()) -> boolean().
checksum_ok(VoterId) ->
    <<Seq8:8/binary, _/binary>> = VoterId,
    Fu = fu(VoterId),
    Size = byte_size(VoterId),
    V1 = binary:at(VoterId, Size - 2) - $0,
    V2 = binary:at(VoterId, Size - 1) - $0,
    Vd1 = vd1(Seq8, Fu),
    Vd1 =:= V1 andalso vd2(Fu, Vd1) =:= V2.

%% First check digit: weighted sum of the first 8 sequential digits
%% (weights 2..9), rem 11, then — in this order — a remainder of 0
%% becomes 1 for São Paulo and Minas Gerais, and a remainder of 10
%% becomes 0.
-spec vd1(<<_:64>>, binary()) -> 0..9.
vd1(Seq8, Fu) ->
    Sum = weighted_sum(Seq8, 2, 0),
    edge_rules(Sum rem 11, Fu).

%% Second check digit: the two federative-union digits weighted 7 and
%% 8 plus the first check digit weighted 9, rem 11, same edge rules.
-spec vd2(binary(), 0..9) -> 0..9.
vd2(<<F1, F2>>, Vd1) ->
    Sum = (F1 - $0) * 7 + (F2 - $0) * 8 + Vd1 * 9,
    edge_rules(Sum rem 11, <<F1, F2>>).

%% The two overlapping remainder rules, order significant.
-spec edge_rules(0..10, binary()) -> 0..9.
edge_rules(0, <<"01">>) -> 1;
edge_rules(0, <<"02">>) -> 1;
edge_rules(10, _Fu) -> 0;
edge_rules(R, _Fu) -> R.

-spec weighted_sum(binary(), pos_integer(), non_neg_integer()) ->
        non_neg_integer().
weighted_sum(<<C, Rest/binary>>, Weight, Acc) ->
    weighted_sum(Rest, Weight + 1, Acc + (C - $0) * Weight);
weighted_sum(<<>>, _Weight, Acc) ->
    Acc.
