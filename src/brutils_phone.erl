%% @doc Utilities for Brazilian phone numbers.
%%
%% Numbers are handled without the +55 country code and with the
%% two-digit DDD (area code) included. Two shapes exist: mobile
%% numbers have 11 digits (DDD + `9' + 8 digits) and landline numbers
%% have 10 (DDD + a digit from 2 to 5 + 7 digits).
%%
%% All functions operate on UTF-8 binaries.
-module(brutils_phone).

-export([remove_symbols/1]).

-type phone_type() :: mobile | landline.
-export_type([phone_type/0]).

%% @doc Removes common phone punctuation from a string: `(', `)',
%% `-', `+' and spaces.
%%
%% Only those five characters are removed; anything else — including
%% dots — is kept unchanged. This is a pure character filter: it does
%% not validate the input.
%%
%% ```
%% 1> brutils_phone:remove_symbols(<<"+55 (11) 99402-9275">>).
%% <<"5511994029275">>
%% 2> brutils_phone:remove_symbols(<<"11.99402.9275">>).
%% <<"11.99402.9275">>
%% '''
-spec remove_symbols(binary()) -> binary().
remove_symbols(Phone) when is_binary(Phone) ->
    << <<C>> || <<C>> <= Phone,
                C =/= $(, C =/= $), C =/= $-, C =/= $+, C =/= $\s >>.
