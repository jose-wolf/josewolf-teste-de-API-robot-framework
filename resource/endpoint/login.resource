*** Settings ***

Resource    ../base.resource
Resource    ../endpoint/usuario.resource


*** Keywords ***

Preparar suíte de login
    Conectar na API ServeRest
    Criar usuário cadastrado para login

Criar usuário cadastrado para login
    ${usuario}=          Criar dados de usuário válido
    Cadastrar usuário na API    ${usuario}
    RETURN    ${usuario}

Extrair credenciais para login
    [Arguments]    ${usuario}
    ${payload_login}=    Create Dictionary
    ...    email=${usuario}[email]
    ...    password=${usuario}[password]
    RETURN               ${payload_login}

Realizar login na API
    [Arguments]    ${payload_login}
    ${resposta}=    POST On Session    alias=serverest    url=/login    json=${payload_login}    expected_status=any
    RETURN          ${resposta}
    
Validar login com sucesso
    [Arguments]    ${resposta}
    Should Be Equal As Integers    ${resposta.status_code}    200
    Should Be Equal As Strings    ${resposta.json()}[message]    Login realizado com sucesso
    Dictionary Should Contain Key    ${resposta.json()}    authorization
    Should Contain    ${resposta.json()}[authorization]    Bearer

Validar login sem email
    [Arguments]    ${resposta}
    Should Be Equal As Integers    ${resposta.status_code}    400
    Should Be Equal As Strings    ${resposta.json()}[email]    email não pode ficar em branco


Validar login sem senha
    [Arguments]    ${resposta}
    Should Be Equal As Integers    ${resposta.status_code}    400
    Should Be Equal As Strings    ${resposta.json()}[password]    password não pode ficar em branco

Validar login sem dados prenchidos
    [Arguments]    ${resposta}
    Should Be Equal As Integers    ${resposta.status_code}    400
    Should Be Equal As Strings    ${resposta.json()}[email]    email não pode ficar em branco
    Should Be Equal As Strings    ${resposta.json()}[password]    password não pode ficar em branco

Validar erro de credenciais inválidas
    [Arguments]    ${resposta}
    Should Be Equal As Integers    ${resposta.status_code}        401
    Should Be Equal As Strings     ${resposta.json()}[message]    Email e/ou senha inválidos