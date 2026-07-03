%% @doc Utils library for Brazilian-specific businesses.
%%
%% This module is the flat facade of the library: it re-exports the
%% domain modules' functions under suffixed names (for example
%% `is_valid_cpf/1' delegating to {@link brutils_cpf:is_valid/1}) so
%% callers can depend on a single module.
-module(brutils).

%% CPF
-export([is_valid_cpf/1, format_cpf/1, remove_symbols_cpf/1, generate_cpf/0]).
%% CNPJ
-export([is_valid_cnpj/1, format_cnpj/1, remove_symbols_cnpj/1,
         generate_cnpj/0, generate_cnpj/1, generate_cnpj/2]).
%% PIS
-export([is_valid_pis/1, format_pis/1, remove_symbols_pis/1, generate_pis/0]).
%% CNH
-export([is_valid_cnh/1]).
%% RENAVAM
-export([is_valid_renavam/1]).
%% CEP
-export([is_valid_cep/1, format_cep/1, remove_symbols_cep/1, generate_cep/0]).

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

%%--------------------------------------------------------------------
%% CNPJ
%%--------------------------------------------------------------------

%% @doc Returns whether the given term is a valid CNPJ.
%% @see brutils_cnpj:is_valid/1
-spec is_valid_cnpj(term()) -> boolean().
is_valid_cnpj(Cnpj) ->
    brutils_cnpj:is_valid(Cnpj).

%% @doc Formats a valid CNPJ for display (`<<"XX.XXX.XXX/XXXX-XX">>').
%% @see brutils_cnpj:format/1
-spec format_cnpj(binary()) ->
        {ok, brutils_cnpj:formatted_cnpj()} | {error, invalid}.
format_cnpj(Cnpj) ->
    brutils_cnpj:format(Cnpj).

%% @doc Removes the formatting symbols `.', `/' and `-' from a CNPJ
%% string.
%% @see brutils_cnpj:remove_symbols/1
-spec remove_symbols_cnpj(binary()) -> binary().
remove_symbols_cnpj(Cnpj) ->
    brutils_cnpj:remove_symbols(Cnpj).

%% @doc Generates a random valid CNPJ with branch number `0001'.
%% @see brutils_cnpj:generate/0
-spec generate_cnpj() -> brutils_cnpj:cnpj().
generate_cnpj() ->
    brutils_cnpj:generate().

%% @doc Generates a random valid CNPJ with the given branch number.
%% @see brutils_cnpj:generate/1
-spec generate_cnpj(Branch :: non_neg_integer() | binary()) ->
        brutils_cnpj:cnpj().
generate_cnpj(Branch) ->
    brutils_cnpj:generate(Branch).

%% @doc Generates a random valid CNPJ, optionally alphanumeric.
%% @see brutils_cnpj:generate/2
-spec generate_cnpj(Branch :: non_neg_integer() | binary(),
                    Alphanumeric :: boolean()) -> brutils_cnpj:cnpj().
generate_cnpj(Branch, Alphanumeric) ->
    brutils_cnpj:generate(Branch, Alphanumeric).

%%--------------------------------------------------------------------
%% PIS
%%--------------------------------------------------------------------

%% @doc Returns whether the given term is a valid PIS.
%% @see brutils_pis:is_valid/1
-spec is_valid_pis(term()) -> boolean().
is_valid_pis(Pis) ->
    brutils_pis:is_valid(Pis).

%% @doc Formats a valid PIS for display (`<<"NNN.NNNNN.NN-N">>').
%% @see brutils_pis:format/1
-spec format_pis(binary()) ->
        {ok, brutils_pis:formatted_pis()} | {error, invalid}.
format_pis(Pis) ->
    brutils_pis:format(Pis).

%% @doc Removes the formatting symbols `.' and `-' from a PIS string.
%% @see brutils_pis:remove_symbols/1
-spec remove_symbols_pis(binary()) -> binary().
remove_symbols_pis(Pis) ->
    brutils_pis:remove_symbols(Pis).

%% @doc Generates a random valid PIS.
%% @see brutils_pis:generate/0
-spec generate_pis() -> brutils_pis:pis().
generate_pis() ->
    brutils_pis:generate().

%%--------------------------------------------------------------------
%% CNH
%%--------------------------------------------------------------------

%% @doc Returns whether the given term is a valid CNH (2022 layout).
%% Non-digit characters are stripped before validation.
%% @see brutils_cnh:is_valid/1
-spec is_valid_cnh(term()) -> boolean().
is_valid_cnh(Cnh) ->
    brutils_cnh:is_valid(Cnh).

%%--------------------------------------------------------------------
%% RENAVAM
%%--------------------------------------------------------------------

%% @doc Returns whether the given term is a valid RENAVAM.
%% Symbols are not stripped: the input must be digits only.
%% @see brutils_renavam:is_valid/1
-spec is_valid_renavam(term()) -> boolean().
is_valid_renavam(Renavam) ->
    brutils_renavam:is_valid(Renavam).

%%--------------------------------------------------------------------
%% CEP
%%--------------------------------------------------------------------

%% @doc Returns whether the given term is a valid CEP (8 digits; no
%% check digit exists, so validity says nothing about existence).
%% @see brutils_cep:is_valid/1
-spec is_valid_cep(term()) -> boolean().
is_valid_cep(Cep) ->
    brutils_cep:is_valid(Cep).

%% @doc Formats a valid CEP for display (`<<"NNNNN-NNN">>').
%% @see brutils_cep:format/1
-spec format_cep(binary()) ->
        {ok, brutils_cep:formatted_cep()} | {error, invalid}.
format_cep(Cep) ->
    brutils_cep:format(Cep).

%% @doc Removes the formatting symbols `.' and `-' from a CEP string.
%% @see brutils_cep:remove_symbols/1
-spec remove_symbols_cep(binary()) -> binary().
remove_symbols_cep(Cep) ->
    brutils_cep:remove_symbols(Cep).

%% @doc Generates a random CEP.
%% @see brutils_cep:generate/0
-spec generate_cep() -> brutils_cep:cep().
generate_cep() ->
    brutils_cep:generate().
