![Logo do Brazilian Utils](https://github.com/brazilian-utils/brand/raw/main/github-hero/github-hero-js.png)

<div align="center">

<p>Utils library for Brazilian-specific businesses.</p>

<p><strong>Erlang</strong>

</div>

## Build

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

## CPF

### is_valid_cpf

Returns whether the verifying checksum digits of the given CPF (Brazilian
Individual Taxpayer Number) match its base number. This function does not
verify the existence of the CPF; it only validates the format of the string.

Args:

- `Cpf` (`term()`): the CPF to be validated, an 11-digit binary. Any other
  term returns `false` — the function never raises.

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
  other term returns `false` — the function never raises.

Returns:

- `boolean()`: `true` if the checksum digits match the base number, `false`
  otherwise. Lowercase letters are invalid, and formatting symbols are not
  stripped — clean the input with `remove_symbols_cnpj/1` first.

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
  term returns `false` — the function never raises.

Returns:

- `boolean()`: `true` if the check digit matches the base number, `false`
  otherwise. PIS reserves no repeated-digit sequences — notably,
  `<<"00000000000">>` has a matching check digit and is valid. Formatting
  symbols are not stripped — clean the input with `remove_symbols_pis/1`
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
  `false` — the function never raises.

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
  other term returns `false` — the function never raises.

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
structural — exactly 8 digits — and says nothing about whether the postal
code actually exists. Address lookup functions (via the ViaCEP API) are
planned for a future release.

### is_valid_cep

Returns whether the given CEP is valid: a binary of exactly 8 digits. Any
8-digit sequence is structurally valid, including repeated ones like
`<<"00000000">>`.

Args:

- `Cep` (`term()`): the CEP to be validated, an 8-digit binary. Any other
  term returns `false` — the function never raises.

Returns:

- `boolean()`: `true` if the input is exactly 8 digits, `false` otherwise.
  Formatting symbols are not stripped — clean the input with
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

## Author

Camilo Cunha de Azevedo <camilotk@gmail.com>
