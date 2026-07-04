![Logo do Brazilian Utils](https://github.com/brazilian-utils/brand/raw/main/github-hero/github-hero.png)

<div align="center">

<p>Biblioteca de utilitários projetada para validar, gerar e manipular dados de acordo com as particularidades do Brasil.</p>

[![GitHub License](https://img.shields.io/github/license/brazilian-utils/erlang?color=blue)](https://opensource.org/license/mit)
[![Package version](https://img.shields.io/hexpm/v/brutils)](https://hex.pm/packages/brutils)
[![run-tests](https://github.com/brazilian-utils/erlang/actions/workflows/run-tests.yml/badge.svg)](https://github.com/brazilian-utils/erlang/actions/workflows/run-tests.yml)
[![check-static](https://github.com/brazilian-utils/erlang/actions/workflows/check-static.yml/badge.svg)](https://github.com/brazilian-utils/erlang/actions/workflows/check-static.yml)

### [Looking for the english version?](README_EN.md)

</div>

# Introdução

Brazilian Utils é uma biblioteca com foco na resolução de problemas que enfrentamos diariamente no desenvolvimento de aplicações para negócios brasileiros.

- [Instalação](#instalação)
- [Build](#build)
- [Utilização](#utilização)
- [Utilitários](#utilitários)
- [Novos Utilitários e Reportar Bugs](#novos-utilitários-e-reportar-bugs)
- [Dúvidas? Ideias?](#dúvidas-ideias)
- [Contribuindo com o Código do Projeto](#contribuindo-com-o-código-do-projeto)

# Instalação

Adicione `brutils` ao seu `rebar.config`:

```erlang
{deps, [
  {brutils, "0.1.3"}
]}. 
```

# Build

Requer Erlang/OTP 25 ou superior (testado nas versões 25, 26 e 27).

```sh
rebar3 compile
```

Gere a documentação da API com:

```sh
rebar3 edoc
```

# Utilização

Todas as funções estão disponíveis por meio do módulo fachada `brutils` e operam sobre binários UTF-8:

```erlang
1> brutils:is_valid_cpf(<<"82178537464">>).
true
```

Cada utilitário também existe em seu próprio módulo (`brutils_cpf`, ...) com nomes sem sufixo (`brutils_cpf:is_valid/1`), caso você prefira depender diretamente do módulo de domínio.

# Utilitários

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
- [Telefone](#telefone)
  - [is_valid_phone](#is_valid_phone)
  - [format_phone](#format_phone)
  - [remove_symbols_phone](#remove_symbols_phone)
  - [remove_international_dialing_code](#remove_international_dialing_code)
  - [generate_phone](#generate_phone)
- [Passaporte](#passaporte)
  - [is_valid_passport](#is_valid_passport)
  - [format_passport](#format_passport)
  - [remove_symbols_passport](#remove_symbols_passport)
  - [generate_passport](#generate_passport)
- [Placa de Veículo](#placa-de-veículo)
  - [is_valid_license_plate](#is_valid_license_plate)
  - [format_license_plate](#format_license_plate)
  - [remove_symbols_license_plate](#remove_symbols_license_plate)
  - [convert_license_plate_to_mercosul](#convert_license_plate_to_mercosul)
  - [get_format_license_plate](#get_format_license_plate)
  - [generate_license_plate](#generate_license_plate)
- [Título de Eleitor](#título-de-eleitor)
  - [is_valid_voter_id](#is_valid_voter_id)
  - [format_voter_id](#format_voter_id)
  - [generate_voter_id](#generate_voter_id)

## CPF

### is_valid_cpf

Retorna se os dígitos verificadores do CPF informado correspondem ao seu número-base. Esta função não verifica a existência do CPF; ela apenas valida o formato da string.

Argumentos:

- `Cpf` (`term()`): o CPF a ser validado, em um binário de 11 dígitos. Qualquer outro termo retorna `false`, e a função nunca gera exceção.

Retorna:

- `boolean()`: `true` se os dígitos verificadores corresponderem ao número-base; `false`, caso contrário. Os símbolos de formatação não são removidos, então um CPF formatado deve ser limpo com `remove_symbols_cpf/1` antes.

Exemplo:

```erlang
1> brutils:is_valid_cpf(<<"82178537464">>).
true
2> brutils:is_valid_cpf(<<"00011122233">>).
false
```

### format_cpf

Formata um CPF válido para exibição, adicionando os símbolos visuais padrão (`XXX.XXX.XXX-XX`).

Argumentos:

- `Cpf` (`binary()`): um binário de CPF contendo apenas números.

Retorna:

- `{ok, Formatted}` com o CPF formatado, ou `{error, invalid}` se a entrada não for um CPF válido.

Exemplo:

```erlang
1> brutils:format_cpf(<<"82178537464">>).
{ok,<<"821.785.374-64">>}
2> brutils:format_cpf(<<"00011122233">>).
{error,invalid}
```

### remove_symbols_cpf

Remove os símbolos `.` e `-` de uma string de CPF. Apenas esses dois caracteres são removidos; qualquer outro é preservado.

Argumentos:

- `Cpf` (`binary()`): o binário de CPF contendo símbolos a serem removidos.

Retorna:

- `binary()`: um novo binário com os símbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_cpf(<<"000.111.222-33">>).
<<"00011122233">>
```

### generate_cpf

Gera um CPF válido aleatório como binário contendo apenas números.

Retorna:

- `binary()`: um CPF válido aleatório de 11 dígitos.

Exemplo:

```erlang
1> brutils:generate_cpf().
<<"44635843700">>
2> brutils:generate_cpf().
<<"06854668417">>
```

## CNPJ

### is_valid_cnpj

Retorna se os dígitos verificadores do CNPJ informado correspondem ao seu número-base. Tanto o formato numérico quanto o formato alfanumérico de 2026 (dígitos e letras maiúsculas nos 12 primeiros caracteres) são suportados. Esta função não verifica a existência do CNPJ; ela apenas valida o formato da string.

Argumentos:

- `Cnpj` (`term()`): o CNPJ a ser validado, em um binário de 14 caracteres. Qualquer outro termo retorna `false`, e a função nunca gera exceção.

Retorna:

- `boolean()`: `true` se os dígitos verificadores corresponderem ao número-base; `false`, caso contrário. Letras minúsculas são inválidas, e os símbolos de formatação não são removidos. Limpe a entrada com `remove_symbols_cnpj/1` antes.

Exemplo:

```erlang
1> brutils:is_valid_cnpj(<<"03560714000142">>).
true
2> brutils:is_valid_cnpj(<<"00111222000133">>).
false
3> brutils:is_valid_cnpj(<<"6Q4E392H000190">>).
true
```

### format_cnpj

Formata um CNPJ válido para exibição, adicionando os símbolos visuais padrão (`XX.XXX.XXX/XXXX-XX`).

Argumentos:

- `Cnpj` (`binary()`): um binário de CNPJ sem símbolos, numérico ou alfanumérico.

Retorna:

- `{ok, Formatted}` com o CNPJ formatado, ou `{error, invalid}` se a entrada não for um CNPJ válido.

Exemplo:

```erlang
1> brutils:format_cnpj(<<"03560714000142">>).
{ok,<<"03.560.714/0001-42">>}
2> brutils:format_cnpj(<<"00111222000133">>).
{error,invalid}
```

### remove_symbols_cnpj

Remove os símbolos `.`, `/` e `-` de uma string de CNPJ. Apenas esses três caracteres são removidos; qualquer outro é preservado.

Argumentos:

- `Cnpj` (`binary()`): o binário de CNPJ contendo símbolos a serem removidos.

Retorna:

- `binary()`: um novo binário com os símbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_cnpj(<<"03.560.714/0001-42">>).
<<"03560714000142">>
```

### generate_cnpj

Gera um CNPJ válido aleatório. Um número de filial opcional pode ser informado (inteiro não negativo ou binário contendo apenas dígitos; o padrão é 1), e uma flag opcional permite usar o formato alfanumérico de 2026, em que a filial também pode conter letras maiúsculas e filiais inválidas são substituídas por `0001`.

Retorna:

- `binary()`: um CNPJ válido aleatório de 14 caracteres.

Exemplo:

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

Retorna se o dígito verificador do PIS/PASEP informado corresponde ao seu número-base. Esta função não verifica a existência do PIS; ela apenas valida o formato da string.

Argumentos:

- `Pis` (`term()`): o PIS a ser validado, em um binário de 11 dígitos. Qualquer outro termo retorna `false`, e a função nunca gera exceção.

Retorna:

- `boolean()`: `true` se o dígito verificador corresponder ao número-base; `false`, caso contrário. O PIS não reserva sequências de dígitos repetidos, então `<<"00000000000">>` possui dígito verificador compatível e é válido. Os símbolos de formatação não são removidos; limpe a entrada com `remove_symbols_pis/1` antes.

Exemplo:

```erlang
1> brutils:is_valid_pis(<<"12056798818">>).
true
2> brutils:is_valid_pis(<<"12056798810">>).
false
3> brutils:is_valid_pis(<<"00000000000">>).
true
```

### format_pis

Formata um PIS válido para exibição, adicionando os símbolos visuais padrão (`NNN.NNNNN.NN-N`).

Argumentos:

- `Pis` (`binary()`): um binário de PIS contendo apenas números.

Retorna:

- `{ok, Formatted}` com o PIS formatado, ou `{error, invalid}` se a entrada não for um PIS válido.

Exemplo:

```erlang
1> brutils:format_pis(<<"12056798818">>).
{ok,<<"120.56798.81-8">>}
2> brutils:format_pis(<<"12056798810">>).
{error,invalid}
```

### remove_symbols_pis

Remove os símbolos `.` e `-` de uma string de PIS. Apenas esses dois caracteres são removidos; qualquer outro é preservado.

Argumentos:

- `Pis` (`binary()`): o binário de PIS contendo símbolos a serem removidos.

Retorna:

- `binary()`: um novo binário com os símbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_pis(<<"120.56798.81-8">>).
<<"12056798818">>
```

### generate_pis

Gera um PIS válido aleatório como binário contendo apenas números. A base é sorteada uniformemente com zero incluído, então os resultados podem começar com zero.

Retorna:

- `binary()`: um PIS válido aleatório de 11 dígitos.

Exemplo:

```erlang
1> brutils:generate_pis().
<<"99360519414">>
2> brutils:generate_pis().
<<"95319303914">>
```

## CNH

### is_valid_cnh

Retorna se a CNH informada (registro da Carteira Nacional de Habilitação, layout 2022) é válida: após remover todos os caracteres não numéricos, devem restar exatamente 11 dígitos, e ambos os dígitos verificadores devem corresponder ao número-base. Layouts anteriores de CNH não são suportados. Esta função não verifica a existência da CNH; ela apenas valida o formato da string.

Diferentemente dos validadores de CPF/CNPJ/PIS, os símbolos não precisam ser removidos antes: entradas formatadas como `<<"987654321-00">>` são aceitas, e letras são removidas em vez de rejeitadas imediatamente.

Argumentos:

- `Cnh` (`term()`): a CNH a ser validada. Qualquer termo que não seja binário retorna `false`, e a função nunca gera exceção.

Retorna:

- `boolean()`: `true` se restarem 11 dígitos após a limpeza e os dígitos verificadores corresponderem; `false`, caso contrário.

Exemplo:

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

Retorna se o RENAVAM informado (número de registro do veículo) é válido: exatamente 11 dígitos cujo dígito verificador corresponde ao número-base. Esta função não verifica a existência do RENAVAM; ela apenas valida o formato da string.

Diferentemente de `is_valid_cnh`, os símbolos **não** são removidos: qualquer caractere não numérico (espaço, hífen, letra) torna a entrada inválida.

Argumentos:

- `Renavam` (`term()`): o RENAVAM a ser validado, em um binário de 11 dígitos. Qualquer outro termo retorna `false`, e a função nunca gera exceção.

Retorna:

- `boolean()`: `true` se o dígito verificador corresponder ao número-base; `false`, caso contrário.

Exemplo:

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

Um CEP não possui dígito verificador: a validação é puramente estrutural, com exatamente 8 dígitos, e não informa se o código postal realmente existe. Funções de busca de endereço via ViaCEP estão planejadas para uma futura versão.

### is_valid_cep

Retorna se o CEP informado é válido: um binário com exatamente 8 dígitos. Qualquer sequência de 8 dígitos é estruturalmente válida, incluindo repetições como `<<"00000000">>`.

Argumentos:

- `Cep` (`term()`): o CEP a ser validado, em um binário de 8 dígitos. Qualquer outro termo retorna `false`, e a função nunca gera exceção.

Retorna:

- `boolean()`: `true` se a entrada tiver exatamente 8 dígitos; `false`, caso contrário. Os símbolos de formatação não são removidos; limpe a entrada com `remove_symbols_cep/1` antes.

Exemplo:

```erlang
1> brutils:is_valid_cep(<<"01310200">>).
true
2> brutils:is_valid_cep(<<"1310200">>).
false
3> brutils:is_valid_cep(<<"01310-200">>).
false
```

### format_cep

Formata um CEP válido para exibição, adicionando o hífen padrão (`NNNNN-NNN`).

Argumentos:

- `Cep` (`binary()`): um binário de CEP contendo apenas números.

Retorna:

- `{ok, Formatted}` com o CEP formatado, ou `{error, invalid}` se a entrada não for um CEP válido.

Exemplo:

```erlang
1> brutils:format_cep(<<"01310200">>).
{ok,<<"01310-200">>}
2> brutils:format_cep(<<"1234567">>).
{error,invalid}
```

### remove_symbols_cep

Remove os símbolos `.` e `-` de uma string de CEP. Apenas esses dois caracteres são removidos; qualquer outro é preservado.

Argumentos:

- `Cep` (`binary()`): o binário de CEP contendo símbolos a serem removidos.

Retorna:

- `binary()`: um novo binário com os símbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_cep(<<"01310-200">>).
<<"01310200">>
```

### generate_cep

Gera um CEP aleatório como binário contendo apenas números. Cada dígito é sorteado de forma independente, então os resultados podem começar com zero.

Retorna:

- `binary()`: um CEP aleatório de 8 dígitos.

Exemplo:

```erlang
1> brutils:generate_cep().
<<"22648357">>
2> brutils:generate_cep().
<<"98885103">>
```

## Telefone

Números de telefone brasileiros são tratados sem o código do país `+55` e com o DDD de dois dígitos incluído. Existem dois formatos:

| Tipo | Dígitos | Formato |
|---|---|---|
| celular | 11 | DDD (1-9 cada) + `9` + 8 dígitos |
| fixo | 10 | DDD (1-9 cada) + um dígito de 2-5 + 7 dígitos |

### is_valid_phone

Retorna se o número de telefone informado é válido, aceitando qualquer um dos formatos na versão de um argumento, ou um formato específico quando o átomo `mobile` ou `landline` é informado. A função não verifica se o número realmente existe. Os símbolos não são removidos; limpe a entrada com `remove_symbols_phone/1` antes.

Argumentos:

- `Phone` (`term()`): o número de telefone a ser validado, contendo apenas dígitos. Qualquer termo que não seja binário retorna `false`, e a função nunca gera exceção.
- `Type` (`mobile | landline`, opcional): restringe a validação a um dos formatos. Qualquer outro valor gera exceção.

Retorna:

- `boolean()`: `true` se o número corresponder ao formato esperado; `false`, caso contrário.

Exemplo:

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

Formata um número de telefone válido para exibição: DDD entre parênteses (sem espaço depois deles) e um hífen antes dos últimos quatro dígitos.

Argumentos:

- `Phone` (`binary()`): um número de telefone contendo apenas dígitos.

Retorna:

- `{ok, Formatted}` com o número formatado, ou `{error, invalid}` se a entrada não for um número de telefone válido.

Exemplo:

```erlang
1> brutils:format_phone(<<"11994029275">>).
{ok,<<"(11)99402-9275">>}
2> brutils:format_phone(<<"1635014415">>).
{ok,<<"(16)3501-4415">>}
```

### remove_symbols_phone

Remove a pontuação comum de uma string de telefone: `(`, `)`, `-`, `+` e espaços. Pontos NÃO são removidos.

Argumentos:

- `Phone` (`binary()`): o número de telefone contendo símbolos a serem removidos.

Retorna:

- `binary()`: um novo binário com os símbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_phone(<<"+55 (11) 99402-9275">>).
<<"5511994029275">>
```

### remove_international_dialing_code

Remove o código internacional brasileiro (`55`) de um número de telefone: se a entrada contiver `55` e tiver mais de 11 caracteres (ignorando espaços), a primeira ocorrência de `55` é removida; caso contrário, a entrada é retornada sem alterações. Observe os casos de borda: um `+` inicial é preservado, e o `55` removido é a primeira ocorrência, esteja ela onde estiver.

Argumentos:

- `Phone` (`binary()`): o número de telefone, possivelmente com o código internacional.

Retorna:

- `binary()`: o número sem o código internacional, ou a própria entrada original.

Exemplo:

```erlang
1> brutils:remove_international_dialing_code(<<"5511994029275">>).
<<"11994029275">>
2> brutils:remove_international_dialing_code(<<"+5511994029275">>).
<<"+11994029275">>
```

### generate_phone

Gera um número de telefone válido aleatório, de tipo aleatório quando chamada sem argumentos, ou do tipo informado (`mobile` ou `landline`).

Retorna:

- `binary()`: um número de telefone válido aleatório.

Exemplo:

```erlang
1> brutils:generate_phone().
<<"38950126454">>
2> brutils:generate_phone(mobile).
<<"59956385883">>
3> brutils:generate_phone(landline).
<<"7529936607">>
```

## Passaporte

Um número de passaporte brasileiro possui 2 letras maiúsculas seguidas de 6 dígitos. Não há dígito verificador, então a validade não informa existência. Observe a divisão de responsabilidades: `is_valid_passport` é estrita (sensível a maiúsculas e minúsculas e sem remoção de símbolos), enquanto `format_passport` é mais tolerante, convertendo para maiúsculas e removendo símbolos antes de validar. Assim, a mesma entrada pode falhar em uma e passar na outra.

### is_valid_passport

Retorna se o número de passaporte informado é válido: exatamente 2 letras maiúsculas seguidas de exatamente 6 dígitos. Letras minúsculas e símbolos tornam a entrada inválida. Use `format_passport/1` para normalizar antes, se necessário.

Argumentos:

- `Passport` (`term()`): o número de passaporte a ser validado. Qualquer termo que não seja binário retorna `false`, e a função nunca gera exceção.

Retorna:

- `boolean()`: `true` se a entrada corresponder ao formato; `false`, caso contrário.

Exemplo:

```erlang
1> brutils:is_valid_passport(<<"AB123456">>).
true
2> brutils:is_valid_passport(<<"Ab123456">>).
false
3> brutils:is_valid_passport(<<"AB-123456">>).
false
```

### format_passport

Normaliza e formata um número de passaporte: converte letras ASCII para maiúsculas, remove os símbolos `-`, `.` e espaços, e depois valida o resultado.

Argumentos:

- `Passport` (`binary()`): um número de passaporte, possivelmente com letras minúsculas ou símbolos.

Retorna:

- `{ok, Formatted}` com o passaporte normalizado em maiúsculas, ou `{error, invalid}` se a entrada não for normalizada para um valor válido.

Exemplo:

```erlang
1> brutils:format_passport(<<"ab-123456">>).
{ok,<<"AB123456">>}
2> brutils:format_passport(<<"111111">>).
{error,invalid}
```

### remove_symbols_passport

Remove os símbolos `-`, `.` e espaços de uma string de passaporte. Apenas esses três caracteres são removidos, e a caixa das letras é preservada.

Argumentos:

- `Passport` (`binary()`): a string de passaporte contendo símbolos a serem removidos.

Retorna:

- `binary()`: um novo binário com os símbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_passport(<<"Ab -. 123456">>).
<<"Ab123456">>
```

### generate_passport

Gera um número de passaporte válido aleatório: 2 letras maiúsculas uniformes seguidas de 6 dígitos uniformes.

Retorna:

- `binary()`: um número de passaporte válido aleatório.

Exemplo:

```erlang
1> brutils:generate_passport().
<<"AP051847">>
2> brutils:generate_passport().
<<"ZN446187">>
```

## Placa de Veículo

Existem dois padrões brasileiros de placa:

| Tipo atômico | Padrão | Exemplo |
|---|---|---|
| `old_format` | `LLLNNNN` - 3 letras + 4 dígitos | `ABC1234` |
| `mercosul` | `LLLNLNN` - 3 letras, dígito, letra, 2 dígitos | `ABC1D23` |

A validação ignora maiúsculas e minúsculas e remove espaços nas extremidades; formatação e conversão sempre retornam letras maiúsculas.

### is_valid_license_plate

Retorna se a placa informada é válida, aceitando qualquer um dos padrões na forma de um argumento, ou um padrão específico quando o tipo atômico é informado.

Argumentos:

- `Plate` (`term()`): a placa a ser validada. Qualquer termo que não seja binário retorna `false`, e a função nunca gera exceção.
- `Type` (`old_format | mercosul`, opcional): restringe a validação a um dos padrões. Qualquer outro valor gera exceção.

Retorna:

- `boolean()`: `true` se a placa corresponder ao padrão esperado.

Exemplo:

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

Formata uma placa válida para exibição: placas do formato antigo recebem um hífen após as letras, enquanto placas Mercosul permanecem sem separador, ambas em maiúsculas.

Argumentos:

- `Plate` (`binary()`): uma placa de veículo, com letras em qualquer caixa.

Retorna:

- `{ok, Formatted}` com a placa formatada, ou `{error, invalid}` se a entrada não corresponder a nenhum dos padrões.

Exemplo:

```erlang
1> brutils:format_license_plate(<<"abc1234">>).
{ok,<<"ABC-1234">>}
2> brutils:format_license_plate(<<"abc1e34">>).
{ok,<<"ABC1E34">>}
```

### remove_symbols_license_plate

Remove o hífen (`-`) de uma string de placa. Apenas o hífen é removido; qualquer outro caractere é preservado.

Argumentos:

- `Plate` (`binary()`): a string da placa contendo hífens a serem removidos.

Retorna:

- `binary()`: um novo binário com os hífens removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_license_plate(<<"ABC-123">>).
<<"ABC123">>
```

### convert_license_plate_to_mercosul

Converte uma placa do formato antigo para o padrão Mercosul, substituindo o dígito na quinta posição por uma letra (`0` -> `A`, `1` -> `B`, ... `9` -> `J`). Uma placa já no formato Mercosul gera erro, em vez de ser tratada como no-op.

Argumentos:

- `Plate` (`binary()`): uma placa do formato antigo, com letras em qualquer caixa.

Retorna:

- `{ok, Converted}` com a placa Mercosul convertida, ou `{error, invalid}` se a entrada não for uma placa válida do formato antigo.

Exemplo:

```erlang
1> brutils:convert_license_plate_to_mercosul(<<"ABC4567">>).
{ok,<<"ABC4F67">>}
2> brutils:convert_license_plate_to_mercosul(<<"ABC1D23">>).
{error,invalid}
```

### get_format_license_plate

Detecta o padrão de uma placa, retornando o átomo correspondente (`old_format` para `LLLNNNN` e `mercosul` para `LLLNLNN`). O resultado pode ser usado diretamente em `is_valid_license_plate/2`.

Argumentos:

- `Plate` (`binary()`): a placa a ser inspecionada, com letras em qualquer caixa.

Retorna:

- `{ok, old_format | mercosul}`, ou `{error, invalid}` se a entrada não corresponder a nenhum dos padrões.

Exemplo:

```erlang
1> brutils:get_format_license_plate(<<"abc1234">>).
{ok,old_format}
2> brutils:get_format_license_plate(<<"ABC1D23">>).
{ok,mercosul}
```

### generate_license_plate

Gera uma placa válida aleatória, Mercosul quando chamada sem argumentos, ou no padrão informado (`<<"LLLNNNN">>` ou `<<"LLLNLNN">>`, sem diferenciar maiúsculas de minúsculas).

Retorna:

- `{ok, Plate}` com a placa gerada; a forma com padrão retorna `{error, invalid}` para formatos desconhecidos.

Exemplo:

```erlang
1> brutils:generate_license_plate().
{ok,<<"WMF1O31">>}
2> brutils:generate_license_plate(<<"LLLNNNN">>).
{ok,<<"BFX5517">>}
```

## Título de Eleitor

Um título de eleitor brasileiro é lido da direita para a esquerda:

| Campo | Dígitos | Posição |
|---|---|---|
| número sequencial | 8 (ou 9 em alguns títulos de SP/MG) | início |
| unidade federativa | 2 | antes dos dígitos verificadores |
| dígitos verificadores | 2 | final |

Títulos normalmente possuem 12 dígitos; títulos de São Paulo e Minas Gerais podem ter 13 (um dígito sequencial extra que o checksum ignora). Os códigos de UF vão de `01` (SP) a `27` (TO), com `28` (`ZZ`) para títulos emitidos no exterior.

### is_valid_voter_id

Retorna se o título de eleitor informado é válido: tamanho correto para sua UF, código em faixa válida, e ambos os dígitos verificadores correspondendo ao valor esperado. Esta função não verifica a existência do título; ela apenas valida o formato da string.

Argumentos:

- `VoterId` (`term()`): o título a ser validado, em um binário de 12 ou 13 dígitos. Qualquer termo que não seja binário retorna `false`, e a função nunca gera exceção.

Retorna:

- `boolean()`: `true` se o título for estruturalmente válido; `false`, caso contrário.

Exemplo:

```erlang
1> brutils:is_valid_voter_id(<<"690847092828">>).
true
2> brutils:is_valid_voter_id(<<"690847092820">>).
false
3> brutils:is_valid_voter_id(<<"3476353100183">>).
true
```

### format_voter_id

Formata um título de eleitor válido de 12 dígitos para exibição com espaços visuais (`NNNN NNNN NN NN`). Títulos válidos de 13 dígitos de SP/MG retornam `{error, invalid}`: como a máscara não comporta o dígito extra, eles são rejeitados em vez de truncados.

Argumentos:

- `VoterId` (`binary()`): um título de eleitor de 12 dígitos contendo apenas números.

Retorna:

- `{ok, Formatted}` com o título formatado, ou `{error, invalid}`.

Exemplo:

```erlang
1> brutils:format_voter_id(<<"690847092828">>).
{ok,<<"6908 4709 28 28">>}
2> brutils:format_voter_id(<<"3476353100183">>).
{error,invalid}
```

### generate_voter_id

Gera um título de eleitor válido aleatório de 12 dígitos, emitido no exterior (`ZZ`) quando chamada sem argumentos, ou para a unidade federativa informada (código de duas letras, sem diferenciar maiúsculas de minúsculas).

Retorna:

- `{ok, VoterId}` com o título gerado; a forma com UF retorna `{error, invalid}` para códigos desconhecidos.

Exemplo:

```erlang
1> brutils:generate_voter_id().
{ok,<<"469000172810">>}
2> brutils:generate_voter_id(<<"sp">>).
{ok,<<"569431460183">>}
3> brutils:generate_voter_id(<<"XX">>).
{error,invalid}
```

## Autor

Camilo Cunha de Azevedo <camilotk@gmail.com>

# Novos Utilitários e Reportar Bugs

Caso queira sugerir novas funcionalidades ou reportar bugs, basta criar uma nova [issue][github-issues], e iremos lhe responder por lá.

(Para saber mais sobre GitHub Issues, confira a [documentação oficial do GitHub][github-issues-doc].)

# Dúvidas? Ideias?

Dúvidas sobre como utilizar a biblioteca? Novas ideias para o projeto? Quer compartilhar algo com a gente? Fique à vontade para criar um tópico em nosso [Discussions][github-discussions], que iremos interagir por lá.

(Para saber mais sobre GitHub Discussions, confira a [documentação oficial do GitHub][github-discussions-doc].)

# Contribuindo com o Código do Projeto

Sua colaboração é sempre muito bem-vinda. Enquanto este repositório ainda não possui um `CONTRIBUTING.md`, você pode contribuir abrindo uma discussão, issue ou pull request com contexto claro sobre a proposta.

Antes de abrir um PR, recomendamos:

1. Garantir que o código compila com `rebar3 compile`.
2. Rodar os testes com `rebar3 eunit --cover`.
3. Rodar os testes de propriedade com `rebar3 proper -n 200 -c`.
4. Verificar a análise estática com `rebar3 xref`, `rebar3 dialyzer` e `rebar3 edoc`.

Não hesite em nos perguntar no [GitHub Discussions][github-discussions] caso haja qualquer dificuldade ou dúvida. Toda ajuda conta.

Vamos construir juntos!

[github-discussions-doc]: https://docs.github.com/pt/discussions
[github-discussions]: https://github.com/brazilian-utils/erlang/discussions
[github-issues-doc]: https://docs.github.com/pt/issues/tracking-your-work-with-issues/creating-an-issue
[github-issues]: https://github.com/brazilian-utils/erlang/issues
