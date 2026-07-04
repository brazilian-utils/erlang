![Logo do Brazilian Utils](https://github.com/brazilian-utils/brand/raw/main/github-hero/github-hero-js.png)

<div align="center">

<p>Biblioteca de utilitarios projetada para validar, gerar e manipular dados de acordo com as particularidades do Brasil.</p>

[![GitHub License](https://img.shields.io/github/license/brazilian-utils/erlang?color=blue)](https://opensource.org/license/mit)
[![Package version](https://img.shields.io/hexpm/v/brutils)](https://hex.pm/packages/brutils)
[![run-tests](https://github.com/brazilian-utils/erlang/actions/workflows/run-tests.yml/badge.svg)](https://github.com/brazilian-utils/erlang/actions/workflows/run-tests.yml)
[![check-static](https://github.com/brazilian-utils/erlang/actions/workflows/check-static.yml/badge.svg)](https://github.com/brazilian-utils/erlang/actions/workflows/check-static.yml)

### [Looking for the english version?](README_EN.md)

</div>

# Introducao

Brazilian Utils e uma biblioteca com foco na resolucao de problemas que enfrentamos diariamente no
desenvolvimento de aplicacoes para o business brasileiro.

- [Instalacao](#instalacao)
- [Build](#build)
- [Utilizacao](#utilizacao)
- [Utilitarios](#utilitarios)
- [Novos Utilitarios e Reportar Bugs](#novos-utilitarios-e-reportar-bugs)
- [Duvidas? Ideias?](#duvidas-ideias)
- [Contribuindo com o Codigo do Projeto](#contribuindo-com-o-codigo-do-projeto)

# Instalacao

Adicione `brutils` ao seu `rebar.config`:

```erlang
{deps, [
  {brutils, "0.1.0"}
]}.
```

# Build

Requer Erlang/OTP 25 ou superior (testado nas versoes 25, 26 e 27).

```sh
rebar3 compile
```

Gere a documentacao da API com:

```sh
rebar3 edoc
```

# Utilizacao

Todas as funcoes estao disponiveis atraves do modulo fachada `brutils` e operam sobre
binarios UTF-8:

```erlang
1> brutils:is_valid_cpf(<<"82178537464">>).
true
```

Cada utilitario tambem existe em seu proprio modulo (`brutils_cpf`, ...) com os
nomes sem sufixo (`brutils_cpf:is_valid/1`), caso voce prefira depender diretamente
do modulo de dominio.

# Utilitarios

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
- [Placa de Veiculo](#placa-de-veiculo)
  - [is_valid_license_plate](#is_valid_license_plate)
  - [format_license_plate](#format_license_plate)
  - [remove_symbols_license_plate](#remove_symbols_license_plate)
  - [convert_license_plate_to_mercosul](#convert_license_plate_to_mercosul)
  - [get_format_license_plate](#get_format_license_plate)
  - [generate_license_plate](#generate_license_plate)
- [Titulo de Eleitor](#titulo-de-eleitor)
  - [is_valid_voter_id](#is_valid_voter_id)
  - [format_voter_id](#format_voter_id)
  - [generate_voter_id](#generate_voter_id)

## CPF

### is_valid_cpf

Retorna se os digitos verificadores do CPF fornecido correspondem ao seu numero base.
Esta funcao nao verifica a existencia do CPF; ela apenas valida o formato da string.

Argumentos:

- `Cpf` (`term()`): o CPF a ser validado, um binario de 11 digitos. Qualquer
  outro termo retorna `false` e a funcao nunca gera excecao.

Retorna:

- `boolean()`: `true` se os digitos verificadores corresponderem ao numero base,
  `false` caso contrario. Os simbolos de formatacao nao sao removidos, entao um
  CPF formatado deve ser limpo com `remove_symbols_cpf/1` antes.

Exemplo:

```erlang
1> brutils:is_valid_cpf(<<"82178537464">>).
true
2> brutils:is_valid_cpf(<<"00011122233">>).
false
```

### format_cpf

Formata um CPF valido para exibicao, adicionando os simbolos visuais padrao
(`XXX.XXX.XXX-XX`).

Argumentos:

- `Cpf` (`binary()`): um binario de CPF contendo apenas numeros.

Retorna:

- `{ok, Formatted}` com o CPF formatado, ou `{error, invalid}` se a entrada
  nao for um CPF valido.

Exemplo:

```erlang
1> brutils:format_cpf(<<"82178537464">>).
{ok,<<"821.785.374-64">>}
2> brutils:format_cpf(<<"00011122233">>).
{error,invalid}
```

### remove_symbols_cpf

Remove os simbolos `.` e `-` de uma string de CPF. Apenas esses dois caracteres
sao removidos; qualquer outro e preservado.

Argumentos:

- `Cpf` (`binary()`): o binario de CPF contendo simbolos a serem removidos.

Retorna:

- `binary()`: um novo binario com os simbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_cpf(<<"000.111.222-33">>).
<<"00011122233">>
```

### generate_cpf

Gera um CPF valido aleatorio como binario contendo apenas numeros.

Retorna:

- `binary()`: um CPF valido aleatorio de 11 digitos.

Exemplo:

```erlang
1> brutils:generate_cpf().
<<"44635843700">>
2> brutils:generate_cpf().
<<"06854668417">>
```

## CNPJ

### is_valid_cnpj

Retorna se os digitos verificadores do CNPJ fornecido correspondem ao seu numero base.
Tanto o formato numerico quanto o formato alfanumerico de 2026 (digitos e letras
maiuculas nos 12 primeiros caracteres) sao suportados. Esta funcao nao verifica a
existencia do CNPJ; ela apenas valida o formato da string.

Argumentos:

- `Cnpj` (`term()`): o CNPJ a ser validado, um binario de 14 caracteres.
  Qualquer outro termo retorna `false` e a funcao nunca gera excecao.

Retorna:

- `boolean()`: `true` se os digitos verificadores corresponderem ao numero base,
  `false` caso contrario. Letras minusculas sao invalidas, e os simbolos de
  formatacao nao sao removidos. Limpe a entrada com `remove_symbols_cnpj/1` antes.

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

Formata um CNPJ valido para exibicao, adicionando os simbolos visuais padrao
(`XX.XXX.XXX/XXXX-XX`).

Argumentos:

- `Cnpj` (`binary()`): um binario de CNPJ sem simbolos, numerico ou alfanumerico.

Retorna:

- `{ok, Formatted}` com o CNPJ formatado, ou `{error, invalid}` se a entrada
  nao for um CNPJ valido.

Exemplo:

```erlang
1> brutils:format_cnpj(<<"03560714000142">>).
{ok,<<"03.560.714/0001-42">>}
2> brutils:format_cnpj(<<"00111222000133">>).
{error,invalid}
```

### remove_symbols_cnpj

Remove os simbolos `.`, `/` e `-` de uma string de CNPJ. Apenas esses tres
caracteres sao removidos; qualquer outro e preservado.

Argumentos:

- `Cnpj` (`binary()`): o binario de CNPJ contendo simbolos a serem removidos.

Retorna:

- `binary()`: um novo binario com os simbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_cnpj(<<"03.560.714/0001-42">>).
<<"03560714000142">>
```

### generate_cnpj

Gera um CNPJ valido aleatorio. Um numero de filial opcional pode ser informado
(inteiro nao negativo ou binario contendo apenas digitos; o padrao e 1), e uma
flag opcional permite usar o formato alfanumerico de 2026, em que a filial tambem
pode conter letras maiusculas e filiais invalidas sao substituidas por `0001`.

Retorna:

- `binary()`: um CNPJ valido aleatorio de 14 caracteres.

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

Retorna se o digito verificador do PIS/PASEP fornecido corresponde ao seu numero base.
Esta funcao nao verifica a existencia do PIS; ela apenas valida o formato da string.

Argumentos:

- `Pis` (`term()`): o PIS a ser validado, um binario de 11 digitos. Qualquer
  outro termo retorna `false` e a funcao nunca gera excecao.

Retorna:

- `boolean()`: `true` se o digito verificador corresponder ao numero base,
  `false` caso contrario. O PIS nao reserva sequencias de digitos repetidos,
  entao `<<"00000000000">>` possui digito verificador compativel e e valido.
  Os simbolos de formatacao nao sao removidos; limpe a entrada com
  `remove_symbols_pis/1` antes.

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

Formata um PIS valido para exibicao, adicionando os simbolos visuais padrao
(`NNN.NNNNN.NN-N`).

Argumentos:

- `Pis` (`binary()`): um binario de PIS contendo apenas numeros.

Retorna:

- `{ok, Formatted}` com o PIS formatado, ou `{error, invalid}` se a entrada
  nao for um PIS valido.

Exemplo:

```erlang
1> brutils:format_pis(<<"12056798818">>).
{ok,<<"120.56798.81-8">>}
2> brutils:format_pis(<<"12056798810">>).
{error,invalid}
```

### remove_symbols_pis

Remove os simbolos `.` e `-` de uma string de PIS. Apenas esses dois caracteres
sao removidos; qualquer outro e preservado.

Argumentos:

- `Pis` (`binary()`): o binario de PIS contendo simbolos a serem removidos.

Retorna:

- `binary()`: um novo binario com os simbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_pis(<<"120.56798.81-8">>).
<<"12056798818">>
```

### generate_pis

Gera um PIS valido aleatorio como binario contendo apenas numeros. A base e sorteada
uniformemente com zero incluido, entao os resultados podem comecar com zero.

Retorna:

- `binary()`: um PIS valido aleatorio de 11 digitos.

Exemplo:

```erlang
1> brutils:generate_pis().
<<"99360519414">>
2> brutils:generate_pis().
<<"95319303914">>
```

## CNH

### is_valid_cnh

Retorna se a CNH fornecida (registro da carteira nacional de habilitacao, layout 2022)
e valida: apos remover todos os caracteres nao numericos, devem restar exatamente
11 digitos e ambos os digitos verificadores devem corresponder ao numero base.
Layouts anteriores de CNH nao sao suportados. Esta funcao nao verifica a existencia
da CNH; ela apenas valida o formato da string.

Diferentemente dos validadores de CPF/CNPJ/PIS, os simbolos nao precisam ser removidos
antes: entradas formatadas como `<<"987654321-00">>` sao aceitas, e letras sao removidas
em vez de rejeitadas imediatamente.

Argumentos:

- `Cnh` (`term()`): a CNH a ser validada. Qualquer termo que nao seja binario
  retorna `false` e a funcao nunca gera excecao.

Retorna:

- `boolean()`: `true` se restarem 11 digitos apos a limpeza e os digitos
  verificadores corresponderem; `false` caso contrario.

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

Retorna se o RENAVAM fornecido (numero de registro do veiculo) e valido:
exatamente 11 digitos cujo digito verificador corresponde ao numero base.
Esta funcao nao verifica a existencia do RENAVAM; ela apenas valida o formato da string.

Diferentemente de `is_valid_cnh`, os simbolos **nao** sao removidos: qualquer
caractere nao numerico (espaco, hifen, letra) torna a entrada invalida.

Argumentos:

- `Renavam` (`term()`): o RENAVAM a ser validado, um binario de 11 digitos.
  Qualquer outro termo retorna `false` e a funcao nunca gera excecao.

Retorna:

- `boolean()`: `true` se o digito verificador corresponder ao numero base,
  `false` caso contrario.

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

Um CEP nao possui digito verificador: a validacao e puramente estrutural,
com exatamente 8 digitos, e nao informa se o codigo postal realmente existe.
Funcoes de busca de endereco via ViaCEP estao planejadas para uma futura versao.

### is_valid_cep

Retorna se o CEP fornecido e valido: um binario com exatamente 8 digitos.
Qualquer sequencia de 8 digitos e estruturalmente valida, incluindo repeticoes
como `<<"00000000">>`.

Argumentos:

- `Cep` (`term()`): o CEP a ser validado, um binario de 8 digitos. Qualquer
  outro termo retorna `false` e a funcao nunca gera excecao.

Retorna:

- `boolean()`: `true` se a entrada tiver exatamente 8 digitos, `false` caso contrario.
  Os simbolos de formatacao nao sao removidos; limpe a entrada com `remove_symbols_cep/1` antes.

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

Formata um CEP valido para exibicao, adicionando o hifen padrao (`NNNNN-NNN`).

Argumentos:

- `Cep` (`binary()`): um binario de CEP contendo apenas numeros.

Retorna:

- `{ok, Formatted}` com o CEP formatado, ou `{error, invalid}` se a entrada
  nao for um CEP valido.

Exemplo:

```erlang
1> brutils:format_cep(<<"01310200">>).
{ok,<<"01310-200">>}
2> brutils:format_cep(<<"1234567">>).
{error,invalid}
```

### remove_symbols_cep

Remove os simbolos `.` e `-` de uma string de CEP. Apenas esses dois caracteres
sao removidos; qualquer outro e preservado.

Argumentos:

- `Cep` (`binary()`): o binario de CEP contendo simbolos a serem removidos.

Retorna:

- `binary()`: um novo binario com os simbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_cep(<<"01310-200">>).
<<"01310200">>
```

### generate_cep

Gera um CEP aleatorio como binario contendo apenas numeros. Cada digito e sorteado
de forma independente, entao os resultados podem comecar com zero.

Retorna:

- `binary()`: um CEP aleatorio de 8 digitos.

Exemplo:

```erlang
1> brutils:generate_cep().
<<"22648357">>
2> brutils:generate_cep().
<<"98885103">>
```

## Telefone

Numeros de telefone brasileiros sao tratados sem o codigo do pais `+55` e com
o DDD de dois digitos incluido. Existem dois formatos:

| Tipo | Digitos | Formato |
|---|---|---|
| celular | 11 | DDD (1-9 cada) + `9` + 8 digitos |
| fixo | 10 | DDD (1-9 cada) + um digito de 2-5 + 7 digitos |

### is_valid_phone

Retorna se o numero de telefone fornecido e valido, aceitando qualquer um dos formatos
na versao de um argumento, ou um formato especifico quando o atom `mobile` ou `landline`
e informado. A funcao nao verifica se o numero realmente existe. Os simbolos nao sao
removidos; limpe a entrada com `remove_symbols_phone/1` antes.

Argumentos:

- `Phone` (`term()`): o numero de telefone a ser validado, apenas digitos.
  Qualquer termo que nao seja binario retorna `false` e a funcao nunca gera excecao.
- `Type` (`mobile | landline`, opcional): restringe a validacao a um dos formatos.
  Qualquer outro valor gera excecao.

Retorna:

- `boolean()`: `true` se o numero corresponder ao formato esperado, `false` caso contrario.

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

Formata um numero de telefone valido para exibicao: DDD entre parenteses
(sem espaco depois deles) e um hifen antes dos ultimos quatro digitos.

Argumentos:

- `Phone` (`binary()`): um numero de telefone contendo apenas digitos.

Retorna:

- `{ok, Formatted}` com o numero formatado, ou `{error, invalid}` se a entrada
  nao for um numero de telefone valido.

Exemplo:

```erlang
1> brutils:format_phone(<<"11994029275">>).
{ok,<<"(11)99402-9275">>}
2> brutils:format_phone(<<"1635014415">>).
{ok,<<"(16)3501-4415">>}
```

### remove_symbols_phone

Remove pontuacao comum de uma string de telefone: `(`, `)`, `-`, `+` e espacos.
Pontos NAO sao removidos.

Argumentos:

- `Phone` (`binary()`): o numero de telefone contendo simbolos a serem removidos.

Retorna:

- `binary()`: um novo binario com os simbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_phone(<<"+55 (11) 99402-9275">>).
<<"5511994029275">>
```

### remove_international_dialing_code

Remove o codigo internacional brasileiro (`55`) de um numero de telefone: se a entrada
contiver `55` e tiver mais de 11 caracteres (ignorando espacos), a primeira ocorrencia
de `55` e removida; caso contrario, a entrada e retornada sem alteracoes. Note as bordas:
um `+` inicial e preservado, e o `55` removido e a primeira ocorrencia onde quer que apareca.

Argumentos:

- `Phone` (`binary()`): o numero de telefone, possivelmente com o codigo internacional.

Retorna:

- `binary()`: o numero sem o codigo internacional, ou a entrada original.

Exemplo:

```erlang
1> brutils:remove_international_dialing_code(<<"5511994029275">>).
<<"11994029275">>
2> brutils:remove_international_dialing_code(<<"+5511994029275">>).
<<"+11994029275">>
```

### generate_phone

Gera um numero de telefone valido aleatorio, de tipo aleatorio sem argumentos,
ou do tipo informado (`mobile` ou `landline`).

Retorna:

- `binary()`: um numero de telefone valido aleatorio.

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

Um numero de passaporte brasileiro possui 2 letras maiusculas seguidas de 6 digitos.
Nao ha digito verificador, entao a validade nao informa existencia. Note a divisao de
responsabilidades: `is_valid_passport` e estrita (sensivel a caixa e sem remocao de simbolos),
enquanto `format_passport` e mais tolerante, convertendo para maiusculas e removendo simbolos
antes de validar. Assim, a mesma entrada pode falhar em uma e passar na outra.

### is_valid_passport

Retorna se o numero de passaporte fornecido e valido: exatamente 2 letras maiusculas
seguidas de exatamente 6 digitos. Letras minusculas e simbolos tornam a entrada invalida.
Use `format_passport/1` para normalizar antes, se necessario.

Argumentos:

- `Passport` (`term()`): o numero de passaporte a ser validado. Qualquer termo
  que nao seja binario retorna `false` e a funcao nunca gera excecao.

Retorna:

- `boolean()`: `true` se a entrada corresponder ao formato, `false` caso contrario.

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

Normaliza e formata um numero de passaporte: converte letras ASCII para maiusculas,
remove os simbolos `-`, `.` e espacos, e depois valida o resultado.

Argumentos:

- `Passport` (`binary()`): um numero de passaporte, possivelmente com letras minusculas
  ou simbolos.

Retorna:

- `{ok, Formatted}` com o passaporte normalizado em maiusculas, ou
  `{error, invalid}` se a entrada nao normalizar para um valor valido.

Exemplo:

```erlang
1> brutils:format_passport(<<"ab-123456">>).
{ok,<<"AB123456">>}
2> brutils:format_passport(<<"111111">>).
{error,invalid}
```

### remove_symbols_passport

Remove os simbolos `-`, `.` e espacos de uma string de passaporte. Apenas esses
tres caracteres sao removidos, e a caixa das letras e preservada.

Argumentos:

- `Passport` (`binary()`): a string de passaporte contendo simbolos a serem removidos.

Retorna:

- `binary()`: um novo binario com os simbolos especificados removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_passport(<<"Ab -. 123456">>).
<<"Ab123456">>
```

### generate_passport

Gera um numero de passaporte valido aleatorio: 2 letras maiusculas uniformes
seguidas de 6 digitos uniformes.

Retorna:

- `binary()`: um numero de passaporte valido aleatorio.

Exemplo:

```erlang
1> brutils:generate_passport().
<<"AP051847">>
2> brutils:generate_passport().
<<"ZN446187">>
```

## Placa de Veiculo

Existem dois padroes brasileiros de placa:

| Tipo atomico | Padrao | Exemplo |
|---|---|---|
| `old_format` | `LLLNNNN` - 3 letras + 4 digitos | `ABC1234` |
| `mercosul` | `LLLNLNN` - 3 letras, digito, letra, 2 digitos | `ABC1D23` |

A validacao ignora caixa das letras e remove espacos nas extremidades; formatacao
e conversao sempre retornam letras maiusculas.

### is_valid_license_plate

Retorna se a placa fornecida e valida, aceitando qualquer um dos padroes na forma
de um argumento, ou um padrao especifico quando o tipo atomico e informado.

Argumentos:

- `Plate` (`term()`): a placa a ser validada. Qualquer termo que nao seja binario
  retorna `false` e a funcao nunca gera excecao.
- `Type` (`old_format | mercosul`, opcional): restringe a validacao a um dos padroes.
  Qualquer outro valor gera excecao.

Retorna:

- `boolean()`: `true` se a placa corresponder ao padrao esperado.

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

Formata uma placa valida para exibicao: placas do formato antigo recebem um hifen
apos as letras, enquanto placas Mercosul permanecem sem separador, ambas em maiusculas.

Argumentos:

- `Plate` (`binary()`): uma placa de veiculo, em qualquer caixa de letras.

Retorna:

- `{ok, Formatted}` com a placa formatada, ou `{error, invalid}` se a entrada
  nao corresponder a nenhum dos padroes.

Exemplo:

```erlang
1> brutils:format_license_plate(<<"abc1234">>).
{ok,<<"ABC-1234">>}
2> brutils:format_license_plate(<<"abc1e34">>).
{ok,<<"ABC1E34">>}
```

### remove_symbols_license_plate

Remove o hifen (`-`) de uma string de placa. Apenas o hifen e removido;
qualquer outro caractere e preservado.

Argumentos:

- `Plate` (`binary()`): a string da placa contendo hifens a serem removidos.

Retorna:

- `binary()`: um novo binario com os hifens removidos.

Exemplo:

```erlang
1> brutils:remove_symbols_license_plate(<<"ABC-123">>).
<<"ABC123">>
```

### convert_license_plate_to_mercosul

Converte uma placa do formato antigo para o padrao Mercosul, substituindo o digito
na quinta posicao por uma letra (`0` -> `A`, `1` -> `B`, ... `9` -> `J`). Uma placa
ja no formato Mercosul gera erro, em vez de ser tratada como no-op.

Argumentos:

- `Plate` (`binary()`): uma placa do formato antigo, em qualquer caixa de letras.

Retorna:

- `{ok, Converted}` com a placa Mercosul convertida, ou `{error, invalid}`
  se a entrada nao for uma placa valida do formato antigo.

Exemplo:

```erlang
1> brutils:convert_license_plate_to_mercosul(<<"ABC4567">>).
{ok,<<"ABC4F67">>}
2> brutils:convert_license_plate_to_mercosul(<<"ABC1D23">>).
{error,invalid}
```

### get_format_license_plate

Detecta o padrao de uma placa, retornando o atom correspondente (`old_format`
para `LLLNNNN` e `mercosul` para `LLLNLNN`). O resultado pode ser usado diretamente
em `is_valid_license_plate/2`.

Argumentos:

- `Plate` (`binary()`): a placa a ser inspecionada, em qualquer caixa de letras.

Retorna:

- `{ok, old_format | mercosul}`, ou `{error, invalid}` se a entrada nao
  corresponder a nenhum dos padroes.

Exemplo:

```erlang
1> brutils:get_format_license_plate(<<"abc1234">>).
{ok,old_format}
2> brutils:get_format_license_plate(<<"ABC1D23">>).
{ok,mercosul}
```

### generate_license_plate

Gera uma placa valida aleatoria, Mercosul sem argumentos, ou no padrao fornecido
(`<<"LLLNNNN">>` ou `<<"LLLNLNN">>`, sem diferenciar maiusculas de minusculas).

Retorna:

- `{ok, Plate}` com a placa gerada; a forma com padrao retorna `{error, invalid}`
  para formatos desconhecidos.

Exemplo:

```erlang
1> brutils:generate_license_plate().
{ok,<<"WMF1O31">>}
2> brutils:generate_license_plate(<<"LLLNNNN">>).
{ok,<<"BFX5517">>}
```

## Titulo de Eleitor

Um titulo de eleitor brasileiro e lido da direita para a esquerda:

| Campo | Digitos | Posicao |
|---|---|---|
| numero sequencial | 8 (ou 9 em alguns titulos de SP/MG) | inicio |
| unidade federativa | 2 | antes dos digitos verificadores |
| digitos verificadores | 2 | final |

Titulos normalmente possuem 12 digitos; titulos de Sao Paulo e Minas Gerais podem
ter 13 (um digito sequencial extra que o checksum ignora). Os codigos de UF vao de
`01` (SP) a `27` (TO), com `28` (`ZZ`) para titulos emitidos no exterior.

### is_valid_voter_id

Retorna se o titulo de eleitor fornecido e valido: tamanho correto para sua UF,
codigo em faixa valida, e ambos os digitos verificadores correspondendo ao valor esperado.
Esta funcao nao verifica a existencia do titulo; ela apenas valida o formato da string.

Argumentos:

- `VoterId` (`term()`): o titulo a ser validado, um binario de 12 ou 13 digitos.
  Qualquer termo que nao seja binario retorna `false` e a funcao nunca gera excecao.

Retorna:

- `boolean()`: `true` se o titulo for estruturalmente valido, `false` caso contrario.

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

Formata um titulo de eleitor valido de 12 digitos para exibicao com espacos visuais
(`NNNN NNNN NN NN`). Titulos validos de 13 digitos de SP/MG retornam `{error, invalid}`:
como a mascara nao comporta o digito extra, eles sao rejeitados em vez de truncados.

Argumentos:

- `VoterId` (`binary()`): um titulo de eleitor de 12 digitos contendo apenas numeros.

Retorna:

- `{ok, Formatted}` com o titulo formatado, ou `{error, invalid}`.

Exemplo:

```erlang
1> brutils:format_voter_id(<<"690847092828">>).
{ok,<<"6908 4709 28 28">>}
2> brutils:format_voter_id(<<"3476353100183">>).
{error,invalid}
```

### generate_voter_id

Gera um titulo de eleitor valido aleatorio de 12 digitos, emitido no exterior (`ZZ`)
sem argumentos, ou para a unidade federativa informada (codigo de duas letras,
case-insensitive).

Retorna:

- `{ok, VoterId}` com o titulo gerado; a forma com UF retorna `{error, invalid}`
  para codigos desconhecidos.

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

# Novos Utilitarios e Reportar Bugs

Caso queira sugerir novas funcionalidades ou reportar bugs, basta criar
uma nova [issue][github-issues] e iremos lhe responder por la.

(Para saber mais sobre github issues, confira a [documentacao oficial do GitHub][github-issues-doc]).

# Duvidas? Ideias?

Duvidas de como utilizar a biblioteca? Novas ideias para o projeto?
Quer compartilhar algo com a gente? Fique a vontade para criar um topico no nosso
[Discussions][github-discussions] que iremos interagir por la.

(Para saber mais sobre github discussions, confira a
[documentacao oficial do GitHub][github-discussions-doc]).

# Contribuindo com o Codigo do Projeto

Sua colaboracao e sempre muito bem-vinda! Enquanto este repositorio ainda nao possui um
`CONTRIBUTING.md`, voce pode contribuir abrindo discussao, issue ou pull request com contexto
claro sobre a proposta.

Antes de abrir um PR, recomendamos:

1. Garantir que o codigo compila com `rebar3 compile`.
2. Rodar os testes com `rebar3 eunit --cover`.
3. Rodar os testes de propriedade com `rebar3 proper -n 200 -c`.
4. Verificar a analise estatica com `rebar3 xref`, `rebar3 dialyzer` e `rebar3 edoc`.

Nao hesite em nos perguntar utilizando o [GitHub Discussions][github-discussions] caso
haja qualquer dificuldade ou duvida. Toda ajuda conta.

Vamos construir juntos!

[github-discussions-doc]: https://docs.github.com/pt/discussions
[github-discussions]: https://github.com/brazilian-utils/erlang/discussions
[github-issues-doc]: https://docs.github.com/pt/issues/tracking-your-work-with-issues/creating-an-issue
[github-issues]: https://github.com/brazilian-utils/erlang/issues
