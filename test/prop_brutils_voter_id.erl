%% @doc Property-based tests for {@link brutils_voter_id}.
%%
%% There is deliberately no federative-union corruption property:
%% swapping the FU of a valid title can coincidentally produce
%% matching check digits (executed counterexamples are pinned in the
%% eunit suite), so the statement would be false.
-module(prop_brutils_voter_id).

-include_lib("proper/include/proper.hrl").

%%--------------------------------------------------------------------
%% Generators
%%--------------------------------------------------------------------

uf() ->
    oneof([<<"SP">>, <<"MG">>, <<"RJ">>, <<"RS">>, <<"BA">>, <<"PR">>,
           <<"CE">>, <<"PE">>, <<"SC">>, <<"GO">>, <<"MA">>, <<"PB">>,
           <<"PA">>, <<"ES">>, <<"PI">>, <<"RN">>, <<"AL">>, <<"MT">>,
           <<"MS">>, <<"DF">>, <<"SE">>, <<"AM">>, <<"RO">>, <<"AC">>,
           <<"AP">>, <<"RR">>, <<"TO">>, <<"ZZ">>]).

lower(Bin) ->
    << <<(C + 32)>> || <<C>> <= Bin >>.

digit() ->
    integer($0, $9).

any_voter_id() ->
    ?LET(Uf, uf(), element(2, brutils_voter_id:generate(Uf))).

%%--------------------------------------------------------------------
%% Properties
%%--------------------------------------------------------------------

%% The default generator produces valid ids for federative union 28.
prop_generate_default_is_valid_zz() ->
    ?FORALL(_, integer(),
            begin
                {ok, V} = brutils_voter_id:generate(),
                brutils_voter_id:is_valid(V)
                    andalso binary:part(V, 8, 2) =:= <<"28">>
            end).

%% Every federative union, in either letter case, generates a valid
%% 12-digit id.
prop_generate_any_uf_is_valid() ->
    ?FORALL({Uf, Lower}, {uf(), boolean()},
            begin
                Arg = case Lower of true -> lower(Uf); false -> Uf end,
                {ok, V} = brutils_voter_id:generate(Arg),
                byte_size(V) =:= 12 andalso brutils_voter_id:is_valid(V)
            end).

%% Replacing the second check digit with any different digit
%% invalidates: vd2 is a pure function of the federative union and
%% the first check digit.
prop_corrupt_vd2_invalid() ->
    ?FORALL({V, D}, {any_voter_id(), digit()},
            begin
                <<Base:11/binary, Old>> = V,
                D =:= Old
                    orelse not brutils_voter_id:is_valid(<<Base/binary, D>>)
            end).

%% Replacing the first check digit invalidates: vd1 is compared
%% directly against the deterministic computation.
prop_corrupt_vd1_invalid() ->
    ?FORALL({V, D}, {any_voter_id(), digit()},
            begin
                <<Head:10/binary, Old, Vd2>> = V,
                D =:= Old
                    orelse not brutils_voter_id:is_valid(
                                 <<Head/binary, D, Vd2>>)
            end).

%% The 9th sequential digit of a 13-digit São Paulo title is ignored
%% by the checksum: inserting any digit into a valid SP id at
%% position 8 keeps it valid.
prop_sequential_digit9_ignored() ->
    ?FORALL(D, digit(),
            begin
                {ok, V} = brutils_voter_id:generate(<<"SP">>),
                <<Seq8:8/binary, Rest/binary>> = V,
                brutils_voter_id:is_valid(<<Seq8/binary, D, Rest/binary>>)
            end).

%% All-digit binaries of length other than 12 or 13 are invalid.
prop_wrong_length_invalid() ->
    ?FORALL(Digits,
            ?SUCHTHAT(L, list(digit()),
                      length(L) =/= 12 andalso length(L) =/= 13),
            not brutils_voter_id:is_valid(list_to_binary(Digits))).

%% is_valid/1 is total: any term yields a boolean, and non-binaries
%% always yield false.
prop_non_binary_false() ->
    ?FORALL(Term, any(),
            case brutils_voter_id:is_valid(Term) of
                B when is_boolean(B) -> is_binary(Term) orelse not B
            end).
