*** Settings ***

Documentation    Keywords de ação e validação da rota /login
Resource    ../resource/base.resource
Resource    ../resource/endpoint/usuario.resource
Resource    ../resource/endpoint/login.resource

Suite Setup    Preparar suíte de login

*** Test Cases ***

Cenário 01: Realizar login com sucesso
    [Documentation]    Efetua o login com um usuário válido e valida o token
    ...    - Cenário positivo
    ${usuario_criado}=    Criar usuário cadastrado para login
    ${payload_login}=    Extrair credenciais para login    ${usuario_criado}
    ${resposta}=    Realizar login na API    ${payload_login}
    Validar login com sucesso    ${resposta}
    Log To Console    ${resposta.json()}

Cenário 02: Não deve realizar login sem email
    [Documentation]    Tenta efetuar login com o campo email em branco
    ...    - Cenário negativo
    ${usuario_criado}=    Criar usuário cadastrado para login
    ${payload_login}=    Extrair credenciais para login    ${usuario_criado}
    Set To Dictionary    ${payload_login}    email=${EMPTY}
    ${resposta}    Realizar login na API    payload_login=${payload_login}
    Validar login sem email    resposta=${resposta}
    Log To Console    ${resposta}

Cenário 03: Não deve realizar login sem senha
    [Documentation]    Tenta efetuar login com o campo email em branco
    ...    - Cenário negativo
    ${usuario_criado}=    Criar usuário cadastrado para login
    ${payload_login}=    Extrair credenciais para login    ${usuario_criado}
    Set To Dictionary    ${payload_login}    password=${EMPTY}
    ${resposta}    Realizar login na API    payload_login=${payload_login}
    Validar login sem senha    resposta=${resposta}
    Log To Console    ${resposta}

Cenário 04: Não deve realizar login sem dados preenchidos
    [Documentation]    Tenta efetuar login com o campo email e senha em brancos
    ...    - Cenário negativo
    ${usuario_criado}=    Criar usuário cadastrado para login
    ${payload_login}=    Extrair credenciais para login    ${usuario_criado}
    Set To Dictionary    ${payload_login}    email=${EMPTY}
    Set To Dictionary    ${payload_login}    password=${EMPTY}
    ${resposta}    Realizar login na API    payload_login=${payload_login}
    Validar login sem dados prenchidos    resposta=${resposta}
    Log To Console    ${resposta}

Cenário 05: Não deve realizar login com e-mail errado
    [Documentation]    Tenta efetuar login com um e-mail não cadastrado
    ...    - Cenário negativo
    ${usuario_criado}=    Criar usuário cadastrado para login
    ${payload_login}=    Extrair credenciais para login    ${usuario_criado}
    Set To Dictionary    ${payload_login}    email=email_inexistente@teste.com
    ${resposta}    Realizar login na API    payload_login=${payload_login}
    Validar erro de credenciais inválidas    resposta=${resposta}
    Log To Console    ${resposta}

Cenário 06: Não deve realizar login com senha errada
    [Documentation]    Tenta efetuar login com e-mail válido, porém com senha incorreta
    ...    - Cenário negativo
    ${usuario_criado}=    Criar usuário cadastrado para login
    ${payload_login}=    Extrair credenciais para login    ${usuario_criado}
    Set To Dictionary    ${payload_login}    password=senhainexistenteteste
    ${resposta}    Realizar login na API    payload_login=${payload_login}
    Validar erro de credenciais inválidas    resposta=${resposta}
    Log To Console    ${resposta}

