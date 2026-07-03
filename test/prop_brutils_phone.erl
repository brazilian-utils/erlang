%% @doc Property-based tests for {@link brutils_phone}.
-module(prop_brutils_phone).

-include_lib("proper/include/proper.hrl").

%%--------------------------------------------------------------------
%% Generators
%%--------------------------------------------------------------------

phone_type() ->
    oneof([mobile, landline]).

%% A generated phone of either type.
any_phone() ->
    ?LET(T, phone_type(), brutils_phone:generate(T)).

%% A generated phone that does not contain the substring "55".
phone_without_55() ->
    ?SUCHTHAT(P, any_phone(), binary:match(P, <<"55">>) =:= nomatch).

%%--------------------------------------------------------------------
%% Properties
%%--------------------------------------------------------------------

%% Typed generation always satisfies the matching validator.
prop_generate_mobile_is_valid() ->
    ?FORALL(_, integer(),
            brutils_phone:is_valid(brutils_phone:generate(mobile), mobile)).

prop_generate_landline_is_valid() ->
    ?FORALL(_, integer(),
            brutils_phone:is_valid(brutils_phone:generate(landline), landline)).

%% Untyped generation always satisfies the either-or validator.
prop_generate_either_is_valid() ->
    ?FORALL(_, integer(),
            brutils_phone:is_valid(brutils_phone:generate())).

%% Formatting a generated phone succeeds, and stripping the symbols
%% recovers the original raw number — both shapes.
prop_format_roundtrip() ->
    ?FORALL(Phone, any_phone(),
            begin
                {ok, Formatted} = brutils_phone:format(Phone),
                brutils_phone:remove_symbols(Formatted) =:= Phone
            end).

%% No number is valid as both types (the shapes differ in length).
prop_mobile_landline_disjoint() ->
    ?FORALL(Phone, any_phone(),
            not (brutils_phone:is_valid(Phone, mobile)
                 andalso brutils_phone:is_valid(Phone, landline))).

%% Planting a zero in either DDD position invalidates, both shapes.
prop_ddd_zero_invalid() ->
    ?FORALL({Phone, Pos}, {any_phone(), integer(0, 1)},
            begin
                <<Before:Pos/binary, _, After/binary>> = Phone,
                not brutils_phone:is_valid(
                      <<Before/binary, $0, After/binary>>)
            end).

%% is_valid/1 is total: any term yields a boolean, and non-binaries
%% always yield false.
prop_non_binary_false() ->
    ?FORALL(Term, any(),
            case brutils_phone:is_valid(Term) of
                B when is_boolean(B) -> is_binary(Term) orelse not B
            end).

%% Dialing-code removal, scoped to the sane region (the mid-number-55
%% quirks are pinned in the eunit suite): a 10/11-digit number with
%% no "55" substring is returned unchanged, and prepending "55" to a
%% generated mobile is always undone — the prepended pair is at
%% position 0, so it is necessarily the first occurrence.
prop_dialing_code_scoped() ->
    ?FORALL(Clean, phone_without_55(),
            begin
                Mobile = brutils_phone:generate(mobile),
                Unchanged =
                    brutils_phone:remove_international_dialing_code(Clean)
                        =:= Clean,
                Undone =
                    brutils_phone:remove_international_dialing_code(
                      <<"55", Mobile/binary>>) =:= Mobile,
                Unchanged andalso Undone
            end).
