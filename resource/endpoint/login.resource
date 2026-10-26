*** Settings ***
Documentation    Keywords de ação e validação da rota /login
Resource         ../base.resource
Resource         ../endpoint/usuario.resource

*** Variables ***
${USUARIO_PADRAO}    ${NONE}

*** Keywords ***
Preparar suíte de login
    Conectar na API ServeRest
    ${usuario}=    Criar usuário cadastrado para login
    Set Suite Variable    ${USUARIO_PADRAO}    ${usuario}

Criar usuário cadastrado para login
    [Arguments]    ${administrador}=true
    ${usuario}=    Criar dados de usuário válido    administrador=${administrador}
    Cadastrar usuário na API    ${usuario}
    RETURN         ${usuario}

Obter token de acesso
    [Documentation]    Cria um usuário, realiza o login e retorna o token Bearer.
    [Arguments]    ${administrador}=true
    ${usuario}=    Criar usuário cadastrado para login    ${administrador}
    ${payload_login}=    Extrair credenciais para login    ${usuario}
    ${resposta}=    Realizar login na API    ${payload_login}
    RETURN    ${resposta.json()}[authorization] 

Extrair credenciais para login
    [Arguments]    ${usuario}=${USUARIO_PADRAO}
    ${payload_login}=    Create Dictionary
    ...                  email=${usuario}[email]
    ...                  password=${usuario}[password]
    RETURN               ${payload_login}

Realizar login na API
    [Arguments]    ${payload_login}
    ${resposta}=    POST On Session    alias=serverest    url=/login    json=${payload_login}    expected_status=any
    RETURN          ${resposta}

Validar login com sucesso
    [Arguments]    ${resposta}
    Validar retorno da API           ${resposta}    200    Login realizado com sucesso
    Dictionary Should Contain Key    ${resposta.json()}    authorization
    Should Contain                   ${resposta.json()}[authorization]    Bearer