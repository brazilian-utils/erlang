%% @doc Property-based tests for {@link brutils_passport}.
-module(prop_brutils_passport).

-include_lib("proper/include/proper.hrl").

%%--------------------------------------------------------------------
%% Generators
%%--------------------------------------------------------------------

upper() ->
    integer($A, $Z).

digit() ->
    integer($0, $9).

%% A shape-conforming passport: 2 uppercase letters + 6 digits.
conforming() ->
    ?LET({L1, L2, Ds}, {upper(), upper(), vector(6, digit())},
         list_to_binary([L1, L2 | Ds])).

%% One of the symbols format/1 strips.
strip_symbol() ->
    oneof([$-, $., $\s]).

%% A conforming passport, lowercased at random letter positions and
%% with strip symbols spliced in at random positions.
dressed() ->
    ?LET({Passport, LowerFirst, LowerSecond, Junk},
         {conforming(), boolean(), boolean(),
          list({integer(0, 8), strip_symbol()})},
         begin
             <<L1, L2, Ds/binary>> = Passport,
             F1 = case LowerFirst of true -> L1 + 32; false -> L1 end,
             F2 = case LowerSecond of true -> L2 + 32; false -> L2 end,
             Base = <<F1, F2, Ds/binary>>,
             Dressed =
                 lists:foldl(
                   fun({Pos, Sym}, Acc) ->
                           At = min(Pos, byte_size(Acc)),
                           <<Before:At/binary, After/binary>> = Acc,
                           <<Before/binary, Sym, After/binary>>
                   end,
                   Base, Junk),
             {Passport, Dressed}
         end).

%%--------------------------------------------------------------------
%% Properties
%%--------------------------------------------------------------------

%% Every generated passport is valid.
prop_generate_is_valid() ->
    ?FORALL(_, integer(),
            brutils_passport:is_valid(brutils_passport:generate())).

%% Every generated passport has exactly 8 bytes.
prop_generate_size() ->
    ?FORALL(_, integer(),
            byte_size(brutils_passport:generate()) =:= 8).

%% The no-checksum theorem: EVERY shape-conforming value is valid —
%% there are no reserved passports.
prop_any_shape_conforming_is_valid() ->
    ?FORALL(Passport, conforming(),
            brutils_passport:is_valid(Passport)).

%% format/1 recovers the clean uppercase passport from any dressing
%% of it: lowercased letters, strip symbols spliced anywhere.
prop_format_normalizes_dressed_input() ->
    ?FORALL({Clean, Dressed}, dressed(),
            brutils_passport:format(Dressed) =:= {ok, Clean}).

%% Planting a non-uppercase byte in a letter position, or a non-digit
%% in a digit position, invalidates.
prop_bad_char_invalid() ->
    ?FORALL({Passport, Scenario},
            {conforming(),
             oneof([{integer(0, 1),
                     ?SUCHTHAT(C, byte(), C < $A orelse C > $Z)},
                    {integer(2, 7),
                     ?SUCHTHAT(C, byte(), C < $0 orelse C > $9)}])},
            begin
                {Pos, Bad} = Scenario,
                <<Before:Pos/binary, _, After/binary>> = Passport,
                not brutils_passport:is_valid(
                      <<Before/binary, Bad, After/binary>>)
            end).

%% Conforming-alphabet strings of any length other than 8 are invalid.
prop_wrong_length_invalid() ->
    ?FORALL(Chars,
            ?SUCHTHAT(L, list(oneof([upper(), digit()])), length(L) =/= 8),
            not brutils_passport:is_valid(list_to_binary(Chars))).

%% is_valid/1 is total: any term yields a boolean, and non-binaries
%% always yield false.
prop_non_binary_false() ->
    ?FORALL(Term, any(),
            case brutils_passport:is_valid(Term) of
                B when is_boolean(B) -> is_binary(Term) orelse not B
            end).
