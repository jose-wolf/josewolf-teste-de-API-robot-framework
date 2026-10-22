*** Settings ***
Documentation    Arquivo base com bibliotecas, conexão global e validações genéricas da API ServeRest
Library          RequestsLibrary
Library          Collections
Library          String

*** Variables ***
${BASE_URL}      https://serverest.dev

*** Keywords ***
Conectar na API ServeRest
    Create Session    alias=serverest    url=${BASE_URL}    disable_warnings=1

Validar retorno da API
    [Documentation]    Valida o status code e a mensagem de um campo do JSON (por padrão 'message').
    [Arguments]        ${resposta}    ${status_esperado}    ${mensagem_esperada}    ${campo}=message
    Status Should Be              ${status_esperado}    ${resposta}
    Should Be Equal As Strings    ${resposta.json()}[${campo}]    ${mensagem_esperada}