%% @doc Property-based tests for {@link brutils_license_plate}.
-module(prop_brutils_license_plate).

-include_lib("proper/include/proper.hrl").

%%--------------------------------------------------------------------
%% Generators
%%--------------------------------------------------------------------

old_plate() ->
    ?LET(_, integer(),
         element(2, brutils_license_plate:generate(<<"LLLNNNN">>))).

mercosul_plate() ->
    ?LET(_, integer(),
         element(2, brutils_license_plate:generate())).

any_plate() ->
    oneof([old_plate(), mercosul_plate()]).

%% ASCII-lowercase a binary.
lower(Bin) ->
    << <<(case C >= $A andalso C =< $Z of
              true -> C + 32;
              false -> C
          end)>> || <<C>> <= Bin >>.

%%--------------------------------------------------------------------
%% Properties
%%--------------------------------------------------------------------

%% The default generator produces Mercosul plates.
prop_generate_default_is_mercosul() ->
    ?FORALL(Plate, mercosul_plate(),
            brutils_license_plate:is_valid(Plate, mercosul)).

%% Each pattern produces plates of its own type, and get_format
%% agrees.
prop_generate_pattern_matches_type() ->
    ?FORALL(Plate, old_plate(),
            brutils_license_plate:is_valid(Plate, old_format)
                andalso brutils_license_plate:get_format(Plate)
                            =:= {ok, old_format}).

%% Converting an old-format plate yields a valid Mercosul plate with
%% the first four and last two characters unchanged.
prop_convert_roundtrip_shape() ->
    ?FORALL(Plate, old_plate(),
            begin
                {ok, Converted} = brutils_license_plate:convert_to_mercosul(Plate),
                <<Head:4/binary, _, Tail:2/binary>> = Plate,
                <<Head2:4/binary, L, Tail2:2/binary>> = Converted,
                brutils_license_plate:is_valid(Converted, mercosul)
                    andalso Head2 =:= Head
                    andalso Tail2 =:= Tail
                    andalso L >= $A andalso L =< $J
            end).

%% The detected type always validates the plate it was detected from.
prop_get_format_composes_with_is_valid() ->
    ?FORALL(Plate, any_plate(),
            begin
                {ok, Type} = brutils_license_plate:get_format(Plate),
                brutils_license_plate:is_valid(Plate, Type)
            end).

%% Formatting then stripping the dash recovers the raw plate — both
%% shapes (Mercosul formatting adds no symbols, so the strip is a
%% no-op there).
prop_format_roundtrip() ->
    ?FORALL(Plate, any_plate(),
            begin
                {ok, Formatted} = brutils_license_plate:format(Plate),
                brutils_license_plate:remove_symbols(Formatted) =:= Plate
            end).

%% Lowercasing never changes the verdict.
prop_case_insensitive() ->
    ?FORALL(Plate, any_plate(),
            brutils_license_plate:is_valid(lower(Plate))
                =:= brutils_license_plate:is_valid(Plate)).

%% is_valid/1 is total: any term yields a boolean, and non-binaries
%% always yield false.
prop_non_binary_false() ->
    ?FORALL(Term, any(),
            case brutils_license_plate:is_valid(Term) of
                B when is_boolean(B) -> is_binary(Term) orelse not B
            end).
