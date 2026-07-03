%% @doc Utils library for Brazilian-specific businesses.
%%
%% This module is the flat facade of the library: it re-exports the
%% domain modules' functions under suffixed names (for example
%% `is_valid_cpf/1' delegating to {@link brutils_cpf:is_valid/1}) so
%% callers can depend on a single module.
-module(brutils).

-export([]).
