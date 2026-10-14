*** Settings ***

Documentation    Arquivo base com bibliotecas e conexão global da API ServeRest
Library          RequestsLibrary
Library          Collections
Library          String

*** Variables ***
${BASE_URL}      https://serverest.dev

*** Keywords ***
Conectar na API ServeRest
    Create Session    alias=serverest    url=${BASE_URL}    disable_warnings=1
    