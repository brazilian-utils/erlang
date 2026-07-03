%% @doc Utils library for Brazilian-specific businesses.
%%
%% This module is the flat facade of the library: it re-exports the
%% domain modules' functions under suffixed names (for example
%% `is_valid_cpf/1' delegating to {@link brutils_cpf:is_valid/1}) so
%% callers can depend on a single module.
-module(brutils).

%% CPF
-export([is_valid_cpf/1, format_cpf/1, remove_symbols_cpf/1, generate_cpf/0]).

%%--------------------------------------------------------------------
%% CPF
%%--------------------------------------------------------------------

%% @doc Returns whether the given term is a valid CPF.
%% @see brutils_cpf:is_valid/1
-spec is_valid_cpf(term()) -> boolean().
is_valid_cpf(Cpf) ->
    brutils_cpf:is_valid(Cpf).

%% @doc Formats a valid CPF for display (`<<"XXX.XXX.XXX-XX">>').
%% @see brutils_cpf:format/1
-spec format_cpf(binary()) ->
        {ok, brutils_cpf:formatted_cpf()} | {error, invalid}.
format_cpf(Cpf) ->
    brutils_cpf:format(Cpf).

%% @doc Removes the formatting symbols `.' and `-' from a CPF string.
%% @see brutils_cpf:remove_symbols/1
-spec remove_symbols_cpf(binary()) -> binary().
remove_symbols_cpf(Cpf) ->
    brutils_cpf:remove_symbols(Cpf).

%% @doc Generates a random valid CPF.
%% @see brutils_cpf:generate/0
-spec generate_cpf() -> brutils_cpf:cpf().
generate_cpf() ->
    brutils_cpf:generate().
