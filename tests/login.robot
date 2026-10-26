*** Settings ***
Documentation    Suíte de testes do endpoint /login da API ServeRest
Resource         ../resource/endpoint/login.resource
Suite Setup      Preparar suíte de login

*** Test Cases ***
Cenário 01: Realizar login com sucesso
    [Documentation]    Efetua o login com um usuário válido e valida o token Bearer
    ...                - Cenário positivo
    [Tags]             positivo    login    smoke
    ${payload_login}=    Extrair credenciais para login
    ${resposta}=         Realizar login na API    ${payload_login}
    Validar login com sucesso    ${resposta}

Cenário 02: Não deve realizar login sem e-mail
    [Documentation]    Tenta efetuar login com o campo email em branco
    ...                - Cenário negativo
    [Tags]             negativo    login
    ${payload_login}=    Extrair credenciais para login
    Set To Dictionary    ${payload_login}    email=${EMPTY}
    ${resposta}=         Realizar login na API    ${payload_login}
    Validar retorno da API    ${resposta}    400    email não pode ficar em branco    campo=email

Cenário 03: Não deve realizar login sem senha
    [Documentation]    Tenta efetuar login com o campo password em branco
    ...                - Cenário negativo
    [Tags]             negativo    login
    ${payload_login}=    Extrair credenciais para login
    Set To Dictionary    ${payload_login}    password=${EMPTY}
    ${resposta}=         Realizar login na API    ${payload_login}
    Validar retorno da API    ${resposta}    400    password não pode ficar em branco    campo=password

Cenário 04: Não deve realizar login sem dados preenchidos
    [Documentation]    Tenta efetuar login com os campos email e password em branco
    ...                - Cenário negativo
    [Tags]             negativo    login
    ${payload_login}=    Create Dictionary    email=${EMPTY}    password=${EMPTY}
    ${resposta}=         Realizar login na API    ${payload_login}
    Validar retorno da API    ${resposta}    400    email não pode ficar em branco       campo=email
    Validar retorno da API    ${resposta}    400    password não pode ficar em branco    campo=password

Cenário 05: Não deve realizar login com e-mail não cadastrado
    [Documentation]    Tenta efetuar login com um e-mail inexistente na base
    ...                - Cenário negativo
    [Tags]             negativo    login
    ${payload_login}=    Extrair credenciais para login
    Set To Dictionary    ${payload_login}    email=email_inexistente@teste.com
    ${resposta}=         Realizar login na API    ${payload_login}
    Validar retorno da API    ${resposta}    401    Email e/ou senha inválidos

Cenário 06: Não deve realizar login com senha incorreta
    [Documentation]    Tenta efetuar login com e-mail válido, porém com senha incorreta
    ...                - Cenário negativo
    [Tags]             negativo    login
    ${payload_login}=    Extrair credenciais para login
    Set To Dictionary    ${payload_login}    password=senhaincorreta123
    ${resposta}=         Realizar login na API    ${payload_login}
    Validar retorno da API    ${resposta}    401    Email e/ou senha inválidos