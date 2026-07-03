%% @doc Property-based tests for {@link brutils_cpf}.
-module(prop_brutils_cpf).

-include_lib("proper/include/proper.hrl").

%%--------------------------------------------------------------------
%% Generators
%%--------------------------------------------------------------------

digit() ->
    integer($0, $9).

non_digit() ->
    ?SUCHTHAT(C, byte(), C < $0 orelse C > $9).

%% An 11-byte binary with at least one non-digit byte.
almost_cpf() ->
    ?LET({Digits, Bad, Pos},
         {vector(10, digit()), non_digit(), integer(0, 10)},
         begin
             {Before, After} = lists:split(Pos, Digits),
             list_to_binary(Before ++ [Bad] ++ After)
         end).

%%--------------------------------------------------------------------
%% Properties
%%--------------------------------------------------------------------

%% Every generated CPF is valid.
prop_generate_is_valid() ->
    ?FORALL(_, integer(),
            brutils_cpf:is_valid(brutils_cpf:generate())).

%% Every generated CPF has exactly 11 bytes.
prop_generate_size() ->
    ?FORALL(_, integer(),
            byte_size(brutils_cpf:generate()) =:= 11).

%% Formatting a generated CPF succeeds, and stripping the symbols
%% recovers the original raw CPF.
prop_format_roundtrip() ->
    ?FORALL(_, integer(),
            begin
                Cpf = brutils_cpf:generate(),
                {ok, Formatted} = brutils_cpf:format(Cpf),
                brutils_cpf:remove_symbols(Formatted) =:= Cpf
            end).

%% Replacing the last check digit with any different digit always
%% invalidates the CPF.
prop_corrupt_dv_invalid() ->
    ?FORALL(D, digit(),
            begin
                Cpf = brutils_cpf:generate(),
                <<Base:10/binary, Dv2>> = Cpf,
                case D =:= Dv2 of
                    true -> brutils_cpf:is_valid(Cpf);
                    false -> not brutils_cpf:is_valid(<<Base/binary, D>>)
                end
            end).

%% Any 11-byte binary containing a non-digit byte is invalid.
prop_non_digit_invalid() ->
    ?FORALL(Bin, almost_cpf(),
            not brutils_cpf:is_valid(Bin)).
