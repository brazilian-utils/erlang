%% @doc Utilities for Brazilian phone numbers.
%%
%% Numbers are handled without the +55 country code and with the
%% two-digit DDD (area code) included. Two shapes exist: mobile
%% numbers have 11 digits (DDD + `9' + 8 digits) and landline numbers
%% have 10 (DDD + a digit from 2 to 5 + 7 digits).
%%
%% All functions operate on UTF-8 binaries.
-module(brutils_phone).

-export([remove_symbols/1, is_valid/1, is_valid/2, format/1,
         remove_international_dialing_code/1, generate/0, generate/1]).

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

%% @doc Returns whether the given term is a valid Brazilian phone
%% number of either shape: mobile (11 digits) or landline (10).
%%
%% Equivalent to `is_valid(Phone, mobile) orelse
%% is_valid(Phone, landline)'. It does not verify that the number
%% actually exists. Formatting symbols are not stripped; clean the
%% input with {@link remove_symbols/1} first. The function is total:
%% any non-binary term returns `false' rather than raising.
%%
%% ```
%% 1> brutils_phone:is_valid(<<"11994029275">>).
%% true
%% 2> brutils_phone:is_valid(<<"1635014415">>).
%% true
%% '''
-spec is_valid(term()) -> boolean().
is_valid(Phone) ->
    is_valid(Phone, mobile) orelse is_valid(Phone, landline).

%% @doc Returns whether the given term is a valid Brazilian phone
%% number of the given type.
%%
%% Mobile numbers have 11 digits: a DDD of two digits from 1 to 9,
%% then a `9', then 8 digits. Landline numbers have 10: the DDD, then
%% a digit from 2 to 5, then 7 digits.
%%
%% The type must be the atom `mobile' or `landline'; anything else is
%% out of contract and raises. (The reference implementation accepts
%% any string as the type and silently falls back to checking both
%% shapes — this port deliberately tightens that to the two atoms.)
%%
%% ```
%% 1> brutils_phone:is_valid(<<"11994029275">>, mobile).
%% true
%% 2> brutils_phone:is_valid(<<"11994029275">>, landline).
%% false
%% '''
-spec is_valid(term(), phone_type()) -> boolean().
is_valid(<<D1, D2, $9, Rest/binary>>, mobile)
  when D1 >= $1, D1 =< $9, D2 >= $1, D2 =< $9, byte_size(Rest) =:= 8 ->
    all_digits(Rest);
is_valid(_, mobile) ->
    false;
is_valid(<<D1, D2, D3, Rest/binary>>, landline)
  when D1 >= $1, D1 =< $9, D2 >= $1, D2 =< $9,
       D3 >= $2, D3 =< $5, byte_size(Rest) =:= 7 ->
    all_digits(Rest);
is_valid(_, landline) ->
    false.

%% @doc Formats a valid phone number for display: the DDD in
%% parentheses (no space after them), then the subscriber number with
%% a dash before the last four digits.
%%
%% Mobile numbers come out as `(DD)NNNNN-NNNN' and landlines as
%% `(DD)NNNN-NNNN'. The input must be a raw, digits-only number
%% accepted by {@link is_valid/1}; anything else yields
%% `{error, invalid}'.
%%
%% ```
%% 1> brutils_phone:format(<<"11994029275">>).
%% {ok,<<"(11)99402-9275">>}
%% 2> brutils_phone:format(<<"1635014415">>).
%% {ok,<<"(16)3501-4415">>}
%% '''
-spec format(binary()) -> {ok, binary()} | {error, invalid}.
format(Phone) when is_binary(Phone) ->
    case is_valid(Phone) of
        true ->
            Split = byte_size(Phone) - 4,
            <<Ddd:2/binary, Head:(Split - 2)/binary, Tail:4/binary>> = Phone,
            {ok, <<$(, Ddd/binary, $), Head/binary, $-, Tail/binary>>};
        false ->
            {error, invalid}
    end.

%% @doc Removes the Brazilian international dialing code (`55') from
%% a phone number, faithfully porting the reference implementation's
%% sharp edges.
%%
%% If the input contains the substring `55' anywhere and is longer
%% than 11 characters once spaces are ignored, the FIRST occurrence
%% of `55' is removed from the original string; otherwise the input
%% is returned unchanged. Consequences to be aware of:
%%
%% <ul>
%% <li>a leading `+' is kept: `<<"+5511994029275">>' becomes
%%     `<<"+11994029275">>';</li>
%% <li>the removed `55' need not actually be a dialing code — the
%%     first occurrence goes, wherever it sits;</li>
%% <li>spaces are ignored by the length check but preserved in the
%%     output.</li>
%% </ul>
%%
%% ```
%% 1> brutils_phone:remove_international_dialing_code(<<"5511994029275">>).
%% <<"11994029275">>
%% 2> brutils_phone:remove_international_dialing_code(<<"1635014415">>).
%% <<"1635014415">>
%% '''
-spec remove_international_dialing_code(binary()) -> binary().
remove_international_dialing_code(Phone) when is_binary(Phone) ->
    NoSpaces = << <<C>> || <<C>> <= Phone, C =/= $\s >>,
    case binary:match(Phone, <<"55">>) of
        {Pos, 2} when byte_size(NoSpaces) > 11 ->
            <<Before:Pos/binary, "55", After/binary>> = Phone,
            <<Before/binary, After/binary>>;
        _ ->
            Phone
    end.

%% @doc Generates a random valid phone number of a random type
%% (mobile or landline, equal probability).
%%
%% ```
%% 1> brutils_phone:generate().
%% <<"4545670536">>
%% '''
-spec generate() -> binary().
generate() ->
    case rand:uniform(2) of
        1 -> generate(mobile);
        2 -> generate(landline)
    end.

%% @doc Generates a random valid phone number of the given type.
%%
%% Mobile: a DDD of two digits from 1 to 9, then `9', then 8 uniform
%% digits. Landline: the DDD, then a digit from 2 to 5, then 7
%% uniform digits. The result always satisfies
%% {@link is_valid/2} for the requested type.
%%
%% ```
%% 1> brutils_phone:generate(mobile).
%% <<"89918945257">>
%% 2> brutils_phone:generate(landline).
%% <<"5747087233">>
%% '''
-spec generate(phone_type()) -> binary().
generate(mobile) ->
    <<(ddd())/binary, $9, (digits(8))/binary>>;
generate(landline) ->
    <<(ddd())/binary, ($1 + rand:uniform(4)), (digits(7))/binary>>.

%%--------------------------------------------------------------------
%% Internal
%%--------------------------------------------------------------------

%% Two DDD digits, each 1..9.
-spec ddd() -> binary().
ddd() ->
    <<($0 + rand:uniform(9)), ($0 + rand:uniform(9))>>.

-spec digits(pos_integer()) -> binary().
digits(N) ->
    << <<($0 + rand:uniform(10) - 1)>> || _ <- lists:seq(1, N) >>.

-spec all_digits(binary()) -> boolean().
all_digits(<<C, Rest/binary>>) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(<<>>) -> true;
all_digits(_) -> false.
