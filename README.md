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

## Author

Camilo Cunha de Azevedo <camilotk@gmail.com>
