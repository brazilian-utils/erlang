%% @doc Property-based tests for {@link brutils_cnpj}.
-module(prop_brutils_cnpj).

-include_lib("proper/include/proper.hrl").

%%--------------------------------------------------------------------
%% Generators
%%--------------------------------------------------------------------

digit() ->
    integer($0, $9).

upper() ->
    integer($A, $Z).

alnum() ->
    oneof([digit(), upper()]).

%% A byte outside [0-9A-Z].
non_alnum() ->
    ?SUCHTHAT(C, byte(),
              not ((C >= $0 andalso C =< $9)
                   orelse (C >= $A andalso C =< $Z))).

%% Branch inputs for numeric mode.
numeric_branch() ->
    oneof([non_neg_integer(),
           ?LET(Ds, non_empty(list(digit())), list_to_binary(Ds))]).

%% Branch inputs for alphanumeric mode: anything goes — integers and
%% arbitrary binaries — because alphanumeric mode repairs instead of
%% raising.
alnum_branch() ->
    oneof([non_neg_integer(),
           ?LET(Cs, list(alnum()), list_to_binary(Cs)),
           binary()]).

%% A CNPJ from either generation mode.
any_cnpj() ->
    oneof([?LET(B, numeric_branch(), brutils_cnpj:generate(B, false)),
           ?LET(B, alnum_branch(), brutils_cnpj:generate(B, true))]).

%%--------------------------------------------------------------------
%% Properties
%%--------------------------------------------------------------------

%% Every generated CNPJ is valid (default numeric mode).
prop_generate_is_valid() ->
    ?FORALL(_, integer(),
            brutils_cnpj:is_valid(brutils_cnpj:generate())).

%% Every non-negative integer branch produces a valid CNPJ.
prop_generate_branch_is_valid() ->
    ?FORALL(B, non_neg_integer(),
            brutils_cnpj:is_valid(brutils_cnpj:generate(B))).

%% Alphanumeric mode produces a valid CNPJ for any branch input,
%% including garbage — invalid branches are repaired, never raised.
prop_generate_alphanumeric_is_valid() ->
    ?FORALL(B, alnum_branch(),
            brutils_cnpj:is_valid(brutils_cnpj:generate(B, true))).

%% Formatting a generated CNPJ succeeds, and stripping the symbols
%% recovers the original raw CNPJ — in both modes.
prop_format_roundtrip() ->
    ?FORALL(Cnpj, any_cnpj(),
            begin
                {ok, Formatted} = brutils_cnpj:format(Cnpj),
                brutils_cnpj:remove_symbols(Formatted) =:= Cnpj
            end).

%% Replacing the last check digit with any different digit always
%% invalidates the CNPJ — in both modes.
prop_corrupt_dv_invalid() ->
    ?FORALL({Cnpj, D}, {any_cnpj(), digit()},
            begin
                <<Base:13/binary, Dv2>> = Cnpj,
                case D =:= Dv2 of
                    true -> brutils_cnpj:is_valid(Cnpj);
                    false -> not brutils_cnpj:is_valid(<<Base/binary, D>>)
                end
            end).

%% Planting a byte outside [0-9A-Z] anywhere, or an uppercase letter
%% in a check-digit position, always invalidates a valid CNPJ.
prop_bad_char_invalid() ->
    ?FORALL({Cnpj, Scenario},
            {any_cnpj(),
             oneof([{non_alnum(), integer(0, 13)},   % junk byte anywhere
                    {upper(), integer(12, 13)}])},   % letter in DV position
            begin
                {Bad, Pos} = Scenario,
                %% the original char is alnum (or a DV digit), so the
                %% planted byte always differs from it
                <<Before:Pos/binary, _, After/binary>> = Cnpj,
                Corrupted = <<Before/binary, Bad, After/binary>>,
                not brutils_cnpj:is_valid(Corrupted)
            end).
