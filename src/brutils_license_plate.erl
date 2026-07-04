%% @doc Utilities for Brazilian vehicle license plates.
%%
%% Two plate patterns exist: the old format — 3 letters followed by 4
%% digits (`"ABC1234"') — and the Mercosul format — 3 letters, a
%% digit, a letter and 2 digits (`"ABC1D23"'). Validation accepts
%% lowercase input; formatting and conversion emit uppercase.
%%
%% All functions operate on UTF-8 binaries.
-module(brutils_license_plate).

-export([remove_symbols/1]).

-type plate_type() :: old_format | mercosul.
%% The two plate patterns: `old_format' is `LLLNNNN', `mercosul' is
%% `LLLNLNN'.

-type plate() :: <<_:56>>.
%% A raw plate: 7 characters in either pattern, e.g. `<<"ABC1D23">>'.

-type formatted_plate() :: <<_:56>> | <<_:64>>.
%% A display-formatted plate: Mercosul plates are bare
%% (`<<"ABC1D23">>'), old-format plates carry a dash
%% (`<<"ABC-1234">>').

-export_type([plate_type/0, plate/0, formatted_plate/0]).

%% @doc Removes the dash (`-') from a license plate string.
%%
%% Only the dash is removed — the narrowest cleaning rule in this
%% library: dots, spaces and letter case are all kept unchanged. This
%% is a pure character filter: it does not validate the input.
%%
%% ```
%% 1> brutils_license_plate:remove_symbols(<<"ABC-123">>).
%% <<"ABC123">>
%% 2> brutils_license_plate:remove_symbols(<<"abc.12 3">>).
%% <<"abc.12 3">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Plate) when is_binary(Plate) ->
    << <<C>> || <<C>> <= Plate, C =/= $- >>.
