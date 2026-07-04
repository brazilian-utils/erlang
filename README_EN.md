![Logo do Brazilian Utils](https://github.com/brazilian-utils/brand/raw/main/github-hero/github-hero-js.png)

<div align="center">

<p>Utils library for Brazilian-specific businesses.</p>

[![GitHub License](https://img.shields.io/github/license/brazilian-utils/erlang?color=blue)](https://opensource.org/license/mit)
[![Package version](https://img.shields.io/hexpm/v/brutils)](https://hex.pm/packages/brutils)
[![run-tests](https://github.com/brazilian-utils/erlang/actions/workflows/run-tests.yml/badge.svg)](https://github.com/brazilian-utils/erlang/actions/workflows/run-tests.yml)
[![check-static](https://github.com/brazilian-utils/erlang/actions/workflows/check-static.yml/badge.svg)](https://github.com/brazilian-utils/erlang/actions/workflows/check-static.yml)

### [Looking for the Portuguese version?](README.md)

</div>

# Getting Started

Brazilian Utils is a library focused on solving problems that we face daily in
the development of applications for Brazilian businesses.

- [Installation](#installation)
- [Build](#build)
- [Usage](#usage)
- [Utilities](#utilities)
- [Feature Request and Bug Report](#feature-request-and-bug-report)
- [Questions? Ideas?](#questions-ideas)
- [Code Contribution](#code-contribution)

# Installation

Add `brutils` to your `rebar.config`:

```erlang
{deps, [
  {brutils, "0.1.0"}
]}.
```

# Build

Requires Erlang/OTP 25 or newer (tested on OTP 25, 26 and 27).

```sh
rebar3 compile
```

Generate the API documentation with:

```sh
rebar3 edoc
```

# Usage

All functions are available through the `brutils` facade module and operate on
UTF-8 binaries:

```erlang
1> brutils:is_valid_cpf(<<"82178537464">>).
true
```

Each utility also lives in its own module (`brutils_cpf`, ...) with the
unsuffixed names (`brutils_cpf:is_valid/1`), if you prefer to depend on the
domain module directly.

# Utilities

- [CPF](#cpf)
  - [is_valid_cpf](#is_valid_cpf)
  - [format_cpf](#format_cpf)
  - [remove_symbols_cpf](#remove_symbols_cpf)
  - [generate_cpf](#generate_cpf)
- [CNPJ](#cnpj)
  - [is_valid_cnpj](#is_valid_cnpj)
  - [format_cnpj](#format_cnpj)
  - [remove_symbols_cnpj](#remove_symbols_cnpj)
  - [generate_cnpj](#generate_cnpj)
- [PIS](#pis)
  - [is_valid_pis](#is_valid_pis)
  - [format_pis](#format_pis)
  - [remove_symbols_pis](#remove_symbols_pis)
  - [generate_pis](#generate_pis)
- [CNH](#cnh)
  - [is_valid_cnh](#is_valid_cnh)
- [RENAVAM](#renavam)
  - [is_valid_renavam](#is_valid_renavam)
- [CEP](#cep)
  - [is_valid_cep](#is_valid_cep)
  - [format_cep](#format_cep)
  - [remove_symbols_cep](#remove_symbols_cep)
  - [generate_cep](#generate_cep)
- [Phone](#phone)
  - [is_valid_phone](#is_valid_phone)
  - [format_phone](#format_phone)
  - [remove_symbols_phone](#remove_symbols_phone)
  - [remove_international_dialing_code](#remove_international_dialing_code)
  - [generate_phone](#generate_phone)
- [Passport](#passport)
  - [is_valid_passport](#is_valid_passport)
  - [format_passport](#format_passport)
  - [remove_symbols_passport](#remove_symbols_passport)
  - [generate_passport](#generate_passport)
- [License plate](#license-plate)
  - [is_valid_license_plate](#is_valid_license_plate)
  - [format_license_plate](#format_license_plate)
  - [remove_symbols_license_plate](#remove_symbols_license_plate)
  - [convert_license_plate_to_mercosul](#convert_license_plate_to_mercosul)
  - [get_format_license_plate](#get_format_license_plate)
  - [generate_license_plate](#generate_license_plate)
- [Voter ID](#voter-id)
  - [is_valid_voter_id](#is_valid_voter_id)
  - [format_voter_id](#format_voter_id)
  - [generate_voter_id](#generate_voter_id)

## CPF

### is_valid_cpf

Returns whether the verifying checksum digits of the given CPF (Brazilian
Individual Taxpayer Number) match its base number. This function does not
verify the existence of the CPF; it only validates the format of the string.

Args:

- `Cpf` (`term()`): the CPF to be validated, an 11-digit binary. Any other
  term returns `false` - the function never raises.

Returns:

- `boolean()`: `true` if the checksum digits match the base number, `false`
  otherwise. Formatting symbols are not stripped, so a formatted CPF must be
  cleaned with `remove_symbols_cpf/1` first.

Example:

```erlang
1> brutils:is_valid_cpf(<<"82178537464">>).
true
2> brutils:is_valid_cpf(<<"00011122233">>).
false
```

### format_cpf

Formats a valid CPF for display, adding the standard visual aid symbols
(`XXX.XXX.XXX-XX`).

Args:

- `Cpf` (`binary()`): a numbers-only CPF binary.

Returns:

- `{ok, Formatted}` with the formatted CPF, or `{error, invalid}` if the
  input is not a valid CPF.

Example:

```erlang
1> brutils:format_cpf(<<"82178537464">>).
{ok,<<"821.785.374-64">>}
2> brutils:format_cpf(<<"00011122233">>).
{error,invalid}
```

### remove_symbols_cpf

Removes the formatting symbols `.` and `-` from a CPF string. Only those two
characters are removed; anything else is kept unchanged.

Args:

- `Cpf` (`binary()`): the CPF binary containing symbols to be removed.

Returns:

- `binary()`: a new binary with the specified symbols removed.

Example:

```erlang
1> brutils:remove_symbols_cpf(<<"000.111.222-33">>).
<<"00011122233">>
```

### generate_cpf

Generates a random valid CPF as a numbers-only binary.

Returns:

- `binary()`: a random valid 11-digit CPF.

Example:

```erlang
1> brutils:generate_cpf().
<<"44635843700">>
2> brutils:generate_cpf().
<<"06854668417">>
```

## CNPJ

### is_valid_cnpj

Returns whether the verifying checksum digits of the given CNPJ (Brazilian
Company Registration Number) match its base number. Both the numeric format
and the 2026 alphanumeric format (digits and uppercase letters in the first
12 characters) are supported. This function does not verify the existence of
the CNPJ; it only validates the format of the string.

Args:

- `Cnpj` (`term()`): the CNPJ to be validated, a 14-character binary. Any
  other term returns `false` - the function never raises.

Returns:

- `boolean()`: `true` if the checksum digits match the base number, `false`
  otherwise. Lowercase letters are invalid, and formatting symbols are not
  stripped - clean the input with `remove_symbols_cnpj/1` first.

Example:

```erlang
1> brutils:is_valid_cnpj(<<"03560714000142">>).
true
2> brutils:is_valid_cnpj(<<"00111222000133">>).
false
3> brutils:is_valid_cnpj(<<"6Q4E392H000190">>).
true
```

### format_cnpj

Formats a valid CNPJ for display, adding the standard visual aid symbols
(`XX.XXX.XXX/XXXX-XX`).

Args:

- `Cnpj` (`binary()`): a symbols-free CNPJ binary, numeric or alphanumeric.

Returns:

- `{ok, Formatted}` with the formatted CNPJ, or `{error, invalid}` if the
  input is not a valid CNPJ.

Example:

```erlang
1> brutils:format_cnpj(<<"03560714000142">>).
{ok,<<"03.560.714/0001-42">>}
2> brutils:format_cnpj(<<"00111222000133">>).
{error,invalid}
```

### remove_symbols_cnpj

Removes the formatting symbols `.`, `/` and `-` from a CNPJ string. Only
those three characters are removed; anything else is kept unchanged.

Args:

- `Cnpj` (`binary()`): the CNPJ binary containing symbols to be removed.

Returns:

- `binary()`: a new binary with the specified symbols removed.

Example:

```erlang
1> brutils:remove_symbols_cnpj(<<"03.560.714/0001-42">>).
<<"03560714000142">>
```

### generate_cnpj

Generates a random valid CNPJ. An optional branch number can be given
(non-negative integer or digits-only binary; defaults to 1), and an optional
alphanumeric flag switches to the 2026 alphanumeric format, where the branch
may also contain uppercase letters and invalid branches are replaced by
`0001`.

Returns:

- `binary()`: a random valid 14-character CNPJ.

Example:

```erlang
1> brutils:generate_cnpj().
<<"95427181000143">>
2> brutils:generate_cnpj(1234).
<<"44122762123483">>
3> brutils:generate_cnpj(<<"AB12">>, true).
<<"X8641237AB1272">>
```

## PIS

### is_valid_pis

Returns whether the verifying check digit of the given PIS/PASEP (Brazilian
social integration program number) matches its base number. This function
does not verify the existence of the PIS; it only validates the format of
the string.

Args:

- `Pis` (`term()`): the PIS to be validated, an 11-digit binary. Any other
  term returns `false` - the function never raises.

Returns:

- `boolean()`: `true` if the check digit matches the base number, `false`
  otherwise. PIS reserves no repeated-digit sequences - notably,
  `<<"00000000000">>` has a matching check digit and is valid. Formatting
  symbols are not stripped - clean the input with `remove_symbols_pis/1`
  first.

Example:

```erlang
1> brutils:is_valid_pis(<<"12056798818">>).
true
2> brutils:is_valid_pis(<<"12056798810">>).
false
3> brutils:is_valid_pis(<<"00000000000">>).
true
```

### format_pis

Formats a valid PIS for display, adding the standard visual aid symbols
(`NNN.NNNNN.NN-N`).

Args:

- `Pis` (`binary()`): a numbers-only PIS binary.

Returns:

- `{ok, Formatted}` with the formatted PIS, or `{error, invalid}` if the
  input is not a valid PIS.

Example:

```erlang
1> brutils:format_pis(<<"12056798818">>).
{ok,<<"120.56798.81-8">>}
2> brutils:format_pis(<<"12056798810">>).
{error,invalid}
```

### remove_symbols_pis

Removes the formatting symbols `.` and `-` from a PIS string. Only those two
characters are removed; anything else is kept unchanged.

Args:

- `Pis` (`binary()`): the PIS binary containing symbols to be removed.

Returns:

- `binary()`: a new binary with the specified symbols removed.

Example:

```erlang
1> brutils:remove_symbols_pis(<<"120.56798.81-8">>).
<<"12056798818">>
```

### generate_pis

Generates a random valid PIS as a numbers-only binary. The base is drawn
uniformly with zero included, so results may start with zeros.

Returns:

- `binary()`: a random valid 11-digit PIS.

Example:

```erlang
1> brutils:generate_pis().
<<"99360519414">>
2> brutils:generate_pis().
<<"95319303914">>
```

## CNH

### is_valid_cnh

Returns whether the given CNH (Brazilian driver's license registration
number, 2022 layout) is valid: after stripping every non-digit character,
exactly 11 digits must remain and both verifying check digits must match the
base number. Earlier CNH layouts are not supported. This function does not
verify the existence of the CNH; it only validates the format of the string.

Unlike the CPF/CNPJ/PIS validators, symbols do not need to be removed first:
formatted input such as `<<"987654321-00">>` is accepted, and letters are
stripped rather than rejected.

Args:

- `Cnh` (`term()`): the CNH to be validated. Any non-binary term returns
  `false` - the function never raises.

Returns:

- `boolean()`: `true` if 11 digits remain after stripping and the check
  digits match, `false` otherwise.

Example:

```erlang
1> brutils:is_valid_cnh(<<"98765432100">>).
true
2> brutils:is_valid_cnh(<<"987654321-00">>).
true
3> brutils:is_valid_cnh(<<"12345678901">>).
false
4> brutils:is_valid_cnh(<<"A2C45678901">>).
false
```

## RENAVAM

### is_valid_renavam

Returns whether the given RENAVAM (Brazilian vehicle registration number) is
valid: exactly 11 digits whose verifying check digit matches the base number.
This function does not verify the existence of the RENAVAM; it only validates
the format of the string.

Unlike `is_valid_cnh`, symbols are **not** stripped: any non-digit character
(space, dash, letter) makes the input invalid.

Args:

- `Renavam` (`term()`): the RENAVAM to be validated, an 11-digit binary. Any
  other term returns `false` - the function never raises.

Returns:

- `boolean()`: `true` if the check digit matches the base number, `false`
  otherwise.

Example:

```erlang
1> brutils:is_valid_renavam(<<"86769597308">>).
true
2> brutils:is_valid_renavam(<<"12345678901">>).
false
3> brutils:is_valid_renavam(<<"867695973-08">>).
false
4> brutils:is_valid_renavam(<<"12345678 901">>).
false
```

## CEP

A CEP (Brazilian postal code) has no check digit: validation is purely
structural - exactly 8 digits - and says nothing about whether the postal
code actually exists. Address lookup functions (via the ViaCEP API) are
planned for a future release.

### is_valid_cep

Returns whether the given CEP is valid: a binary of exactly 8 digits. Any
8-digit sequence is structurally valid, including repeated ones like
`<<"00000000">>`.

Args:

- `Cep` (`term()`): the CEP to be validated, an 8-digit binary. Any other
  term returns `false` - the function never raises.

Returns:

- `boolean()`: `true` if the input is exactly 8 digits, `false` otherwise.
  Formatting symbols are not stripped - clean the input with
  `remove_symbols_cep/1` first.

Example:

```erlang
1> brutils:is_valid_cep(<<"01310200">>).
true
2> brutils:is_valid_cep(<<"1310200">>).
false
3> brutils:is_valid_cep(<<"01310-200">>).
false
```

### format_cep

Formats a valid CEP for display, adding the standard dash (`NNNNN-NNN`).

Args:

- `Cep` (`binary()`): a numbers-only CEP binary.

Returns:

- `{ok, Formatted}` with the formatted CEP, or `{error, invalid}` if the
  input is not a valid CEP.

Example:

```erlang
1> brutils:format_cep(<<"01310200">>).
{ok,<<"01310-200">>}
2> brutils:format_cep(<<"1234567">>).
{error,invalid}
```

### remove_symbols_cep

Removes the formatting symbols `.` and `-` from a CEP string. Only those two
characters are removed; anything else is kept unchanged.

Args:

- `Cep` (`binary()`): the CEP binary containing symbols to be removed.

Returns:

- `binary()`: a new binary with the specified symbols removed.

Example:

```erlang
1> brutils:remove_symbols_cep(<<"01310-200">>).
<<"01310200">>
```

### generate_cep

Generates a random CEP as a numbers-only binary. Each digit is drawn
independently, so results may start with zeros.

Returns:

- `binary()`: a random 8-digit CEP.

Example:

```erlang
1> brutils:generate_cep().
<<"22648357">>
2> brutils:generate_cep().
<<"98885103">>
```

## Phone

Brazilian phone numbers are handled without the +55 country code and with
the two-digit DDD (area code) included. Two shapes exist:

| Type | Digits | Shape |
|---|---|---|
| mobile | 11 | DDD (1-9 each) + `9` + 8 digits |
| landline | 10 | DDD (1-9 each) + one digit 2-5 + 7 digits |

### is_valid_phone

Returns whether the given phone number is valid - either shape for the
one-argument form, or a specific one when the type atom (`mobile` or
`landline`) is given. It does not verify that the number actually exists.
Symbols are not stripped - clean the input with `remove_symbols_phone/1`
first.

Args:

- `Phone` (`term()`): the phone number to be validated, digits only. Any
  non-binary term returns `false` - the function never raises.
- `Type` (`mobile | landline`, optional): restricts the check to one shape.
  Any other value raises.

Returns:

- `boolean()`: `true` if the number matches the (requested) shape, `false`
  otherwise.

Example:

```erlang
1> brutils:is_valid_phone(<<"11994029275">>).
true
2> brutils:is_valid_phone(<<"1635014415">>).
true
3> brutils:is_valid_phone(<<"11994029275">>, mobile).
true
4> brutils:is_valid_phone(<<"11994029275">>, landline).
false
```

### format_phone

Formats a valid phone number for display: DDD in parentheses (no space
after them) and a dash before the last four digits.

Args:

- `Phone` (`binary()`): a digits-only phone number.

Returns:

- `{ok, Formatted}` with the formatted number, or `{error, invalid}` if the
  input is not a valid phone number.

Example:

```erlang
1> brutils:format_phone(<<"11994029275">>).
{ok,<<"(11)99402-9275">>}
2> brutils:format_phone(<<"1635014415">>).
{ok,<<"(16)3501-4415">>}
```

### remove_symbols_phone

Removes common phone punctuation from a string: `(`, `)`, `-`, `+` and
spaces. Dots are NOT removed.

Args:

- `Phone` (`binary()`): the phone number containing symbols to be removed.

Returns:

- `binary()`: a new binary with the specified symbols removed.

Example:

```erlang
1> brutils:remove_symbols_phone(<<"+55 (11) 99402-9275">>).
<<"5511994029275">>
```

### remove_international_dialing_code

Removes the Brazilian international dialing code (`55`) from a phone
number: if the input contains `55` and is longer than 11 characters
(ignoring spaces), the first occurrence of `55` is removed; otherwise the
input is returned unchanged. Note the sharp edges: a leading `+` is kept,
and the removed `55` is the first occurrence wherever it sits.

Args:

- `Phone` (`binary()`): the phone number, possibly with the dialing code.

Returns:

- `binary()`: the number without the dialing code, or unchanged.

Example:

```erlang
1> brutils:remove_international_dialing_code(<<"5511994029275">>).
<<"11994029275">>
2> brutils:remove_international_dialing_code(<<"+5511994029275">>).
<<"+11994029275">>
```

### generate_phone

Generates a random valid phone number - of a random type with no argument,
or of the given type (`mobile` or `landline`).

Returns:

- `binary()`: a random valid phone number.

Example:

```erlang
1> brutils:generate_phone().
<<"38950126454">>
2> brutils:generate_phone(mobile).
<<"59956385883">>
3> brutils:generate_phone(landline).
<<"7529936607">>
```

## Passport

A Brazilian passport number has 2 uppercase letters followed by 6 digits.
There is no check digit, so validity says nothing about existence. Note the
division of labor: `is_valid_passport` is strict (case-sensitive, no
symbol stripping), while `format_passport` is lenient - it uppercases and
strips symbols before validating, so the same input can fail one and pass
the other.

### is_valid_passport

Returns whether the given passport number is valid: exactly 2 uppercase
letters followed by exactly 6 digits. Lowercase letters and symbols make
the input invalid - use `format_passport/1` to normalize first.

Args:

- `Passport` (`term()`): the passport number to be validated. Any
  non-binary term returns `false` - the function never raises.

Returns:

- `boolean()`: `true` if the input matches the shape, `false` otherwise.

Example:

```erlang
1> brutils:is_valid_passport(<<"AB123456">>).
true
2> brutils:is_valid_passport(<<"Ab123456">>).
false
3> brutils:is_valid_passport(<<"AB-123456">>).
false
```

### format_passport

Normalizes and formats a passport number: uppercases ASCII letters, strips
the symbols `-`, `.` and spaces, then validates the result.

Args:

- `Passport` (`binary()`): a passport number, possibly lowercase or with
  symbols.

Returns:

- `{ok, Formatted}` with the normalized uppercase passport, or
  `{error, invalid}` if the input does not normalize into a valid one.

Example:

```erlang
1> brutils:format_passport(<<"ab-123456">>).
{ok,<<"AB123456">>}
2> brutils:format_passport(<<"111111">>).
{error,invalid}
```

### remove_symbols_passport

Removes the symbols `-`, `.` and spaces from a passport string. Only those
three characters are removed, and letter case is preserved.

Args:

- `Passport` (`binary()`): the passport string containing symbols to be
  removed.

Returns:

- `binary()`: a new binary with the specified symbols removed.

Example:

```erlang
1> brutils:remove_symbols_passport(<<"Ab -. 123456">>).
<<"Ab123456">>
```

### generate_passport

Generates a random valid passport number: 2 uniform uppercase letters
followed by 6 uniform digits.

Returns:

- `binary()`: a random valid passport number.

Example:

```erlang
1> brutils:generate_passport().
<<"AP051847">>
2> brutils:generate_passport().
<<"ZN446187">>
```

## License plate

Two Brazilian plate patterns exist:

| Type atom | Pattern | Example |
|---|---|---|
| `old_format` | `LLLNNNN` - 3 letters + 4 digits | `ABC1234` |
| `mercosul` | `LLLNLNN` - 3 letters, digit, letter, 2 digits | `ABC1D23` |

Validation ignores letter case and trims surrounding whitespace; formatting
and conversion emit uppercase.

### is_valid_license_plate

Returns whether the given plate is valid - either pattern for the
one-argument form, or a specific one when the type atom is given.

Args:

- `Plate` (`term()`): the plate to be validated. Any non-binary term
  returns `false` - the function never raises.
- `Type` (`old_format | mercosul`, optional): restricts the check to one
  pattern. Any other value raises.

Returns:

- `boolean()`: `true` if the plate matches the (requested) pattern.

Example:

```erlang
1> brutils:is_valid_license_plate(<<"ABC1234">>).
true
2> brutils:is_valid_license_plate(<<"abc1d23">>).
true
3> brutils:is_valid_license_plate(<<"ABC-1234">>).
false
4> brutils:is_valid_license_plate(<<"ABC1234">>, mercosul).
false
```

### format_license_plate

Formats a valid plate for display: old-format plates get a dash after the
letters, Mercosul plates come out bare - both uppercased.

Args:

- `Plate` (`binary()`): a license plate, any letter case.

Returns:

- `{ok, Formatted}` with the formatted plate, or `{error, invalid}` if the
  input matches neither pattern.

Example:

```erlang
1> brutils:format_license_plate(<<"abc1234">>).
{ok,<<"ABC-1234">>}
2> brutils:format_license_plate(<<"abc1e34">>).
{ok,<<"ABC1E34">>}
```

### remove_symbols_license_plate

Removes the dash (`-`) from a license plate string. Only the dash is
removed; anything else is kept unchanged.

Args:

- `Plate` (`binary()`): the plate string containing dashes to be removed.

Returns:

- `binary()`: a new binary with the dashes removed.

Example:

```erlang
1> brutils:remove_symbols_license_plate(<<"ABC-123">>).
<<"ABC123">>
```

### convert_license_plate_to_mercosul

Converts an old-format plate to the Mercosul pattern by replacing the digit
at the fifth position with a letter (`0`->`A`, `1`->`B`, ... `9`->`J`). An
already-Mercosul plate yields an error, not a no-op.

Args:

- `Plate` (`binary()`): an old-format plate, any letter case.

Returns:

- `{ok, Converted}` with the Mercosul plate, or `{error, invalid}` if the
  input is not a valid old-format plate.

Example:

```erlang
1> brutils:convert_license_plate_to_mercosul(<<"ABC4567">>).
{ok,<<"ABC4F67">>}
2> brutils:convert_license_plate_to_mercosul(<<"ABC1D23">>).
{error,invalid}
```

### get_format_license_plate

Detects the pattern of a license plate, returning the type atom
(`old_format` for `LLLNNNN`, `mercosul` for `LLLNLNN`) - the result can be
fed straight back into `is_valid_license_plate/2`.

Args:

- `Plate` (`binary()`): the plate to inspect, any letter case.

Returns:

- `{ok, old_format | mercosul}`, or `{error, invalid}` if the input
  matches neither pattern.

Example:

```erlang
1> brutils:get_format_license_plate(<<"abc1234">>).
{ok,old_format}
2> brutils:get_format_license_plate(<<"ABC1D23">>).
{ok,mercosul}
```

### generate_license_plate

Generates a random valid plate - Mercosul with no argument, or in the
given pattern (`<<"LLLNNNN">>` or `<<"LLLNLNN">>`, case insensitive).

Returns:

- `{ok, Plate}` with the generated plate; the pattern form yields
  `{error, invalid}` for unknown patterns.

Example:

```erlang
1> brutils:generate_license_plate().
{ok,<<"WMF1O31">>}
2> brutils:generate_license_plate(<<"LLLNNNN">>).
{ok,<<"BFX5517">>}
```

## Voter ID

A Brazilian voter id (titulo de eleitor) is read from the right:

| Field | Digits | Position |
|---|---|---|
| sequential number | 8 (or 9 for some SP/MG titles) | leading |
| federative union | 2 | before the check digits |
| check digits | 2 | last |

Titles normally have 12 digits; Sao Paulo and Minas Gerais titles may have
13 (an extra sequential digit that the checksum ignores). Federative-union
codes run `01` (SP) through `27` (TO), with `28` (`ZZ`) for titles issued
abroad.

### is_valid_voter_id

Returns whether the given voter id is valid: correct length for its
federative union, code in range, and both verifying check digits matching.
This function does not verify the existence of the title; it only validates
the format of the string.

Args:

- `VoterId` (`term()`): the voter id to be validated, a 12- or 13-digit
  binary. Any non-binary term returns `false` - the function never raises.

Returns:

- `boolean()`: `true` if the title is structurally valid, `false`
  otherwise.

Example:

```erlang
1> brutils:is_valid_voter_id(<<"690847092828">>).
true
2> brutils:is_valid_voter_id(<<"690847092820">>).
false
3> brutils:is_valid_voter_id(<<"3476353100183">>).
true
```

### format_voter_id

Formats a valid 12-digit voter id for display with visual spacing
(`NNNN NNNN NN NN`). Valid 13-digit SP/MG titles yield `{error, invalid}`:
the display mask has no slot for their extra digit, so they are refused
rather than silently truncated.

Args:

- `VoterId` (`binary()`): a numbers-only 12-digit voter id.

Returns:

- `{ok, Formatted}` with the spaced voter id, or `{error, invalid}`.

Example:

```erlang
1> brutils:format_voter_id(<<"690847092828">>).
{ok,<<"6908 4709 28 28">>}
2> brutils:format_voter_id(<<"3476353100183">>).
{error,invalid}
```

### generate_voter_id

Generates a random valid 12-digit voter id - for a title issued abroad
(`ZZ`) with no argument, or for the given federative union (two-letter
code, case insensitive).

Returns:

- `{ok, VoterId}` with the generated title; the UF form yields
  `{error, invalid}` for unknown codes.

Example:

```erlang
1> brutils:generate_voter_id().
{ok,<<"469000172810">>}
2> brutils:generate_voter_id(<<"sp">>).
{ok,<<"569431460183">>}
3> brutils:generate_voter_id(<<"XX">>).
{error,invalid}
```

## Author

Camilo Cunha de Azevedo <camilotk@gmail.com>

# Feature Request and Bug Report

If you want to suggest new features or report bugs, simply create
a new [issue][github-issues], and we will respond to you there.

(To learn more about GitHub Issues, check out the [official GitHub documentation][github-issues-doc].)

# Questions? Ideas?

Questions on how to use the library? New ideas for the project?
Want to share something with us? Feel free to start a thread in our
[Discussions][github-discussions], and we'll interact with you there.

(To learn more about GitHub Discussions, refer to the
[official GitHub documentation][github-discussions-doc].)

# Code Contribution

Your collaboration is always very welcome.

Before opening a PR, we recommend:

1. Opening an issue or discussion first when alignment is useful.
2. Ensuring the project compiles with `rebar3 compile`.
3. Running `rebar3 eunit` and property tests with `rebar3 proper -n 200 -c`.
4. Checking static analysis with `rebar3 xref`, `rebar3 dialyzer` and `rebar3 edoc`.

Every bit of help counts.

[github-discussions-doc]: https://docs.github.com/en/discussions
[github-discussions]: https://github.com/brazilian-utils/erlang/discussions
[github-issues-doc]: https://docs.github.com/en/issues/tracking-your-work-with-issues/creating-an-issue
[github-issues]: https://github.com/brazilian-utils/erlang/issues
