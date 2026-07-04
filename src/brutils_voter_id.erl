%% @doc Validation, formatting and generation for the Brazilian voter
%% id (título de eleitor).
%%
%% A voter id is read from the RIGHT: the last 2 digits are check
%% digits, the 2 before them encode the federative union (`01' for
%% São Paulo through `27' for Tocantins, `28' for titles issued
%% abroad), and everything in front is the sequential number —
%% normally 8 digits (12 in total), but 9 for some São Paulo and
%% Minas Gerais titles (13 in total).
%%
%% All functions operate on UTF-8 binaries.
-module(brutils_voter_id).

-export([is_valid/1]).

-type voter_id() :: <<_:96>>.
%% A generated voter id: always 12 digits. (Valid input may also be
%% 13 digits for São Paulo and Minas Gerais titles.)

-type formatted_voter_id() :: <<_:120>>.
%% A display-formatted voter id, e.g. `<<"6908 4709 28 28">>'.

-export_type([voter_id/0, formatted_voter_id/0]).

%% @doc Returns whether the given term has the shape of a valid voter
%% id: an all-digit binary of 12 digits — or 13 when the federative
%% union code (the two digits before the final two) is `01' or `02' —
%% whose federative union code is in the range `01'..`28'.
%%
%% The function is total: any non-binary term returns `false' rather
%% than raising.
-spec is_valid(term()) -> boolean().
is_valid(VoterId) when is_binary(VoterId),
                       byte_size(VoterId) =:= 12;
                       is_binary(VoterId),
                       byte_size(VoterId) =:= 13 ->
    all_digits(VoterId)
        andalso length_allowed(VoterId)
        andalso fu_in_range(fu(VoterId));
is_valid(_) ->
    false.

%%--------------------------------------------------------------------
%% Internal
%%--------------------------------------------------------------------

%% The federative-union code: bytes [-4, -2) from the right.
-spec fu(binary()) -> binary().
fu(VoterId) ->
    binary:part(VoterId, byte_size(VoterId) - 4, 2).

%% 12 digits always; 13 only for São Paulo (01) and Minas Gerais (02).
-spec length_allowed(binary()) -> boolean().
length_allowed(VoterId) when byte_size(VoterId) =:= 12 ->
    true;
length_allowed(VoterId) ->
    case fu(VoterId) of
        <<"01">> -> true;
        <<"02">> -> true;
        _ -> false
    end.

-spec fu_in_range(binary()) -> boolean().
fu_in_range(Fu) ->
    Fu >= <<"01">> andalso Fu =< <<"28">>.

-spec all_digits(binary()) -> boolean().
all_digits(<<C, Rest/binary>>) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(<<>>) -> true;
all_digits(_) -> false.
