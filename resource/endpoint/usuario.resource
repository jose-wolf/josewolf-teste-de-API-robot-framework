*** Settings ***

Resource    ../base.resource

*** Keywords ***
# --- Método Post / usuário ***
Criar dados de usuário válido
    ${aleatorio}=    Generate Random String    length=6    chars=[LOWER]
    ${payload}=      Create Dictionary
    ...              nome=Fulano QA
    ...              email=fulano_${aleatorio}@qa.com.br
    ...              password=teste123
    ...              administrador=true
    RETURN           ${payload}

Cadastrar usuário na API
    [Arguments]    ${payload}
    ${resposta}=    POST On Session    alias=serverest    url=/usuarios    json=${payload}    expected_status=any
    RETURN    ${resposta}

Validar cadastro com sucesso
    [Arguments]    ${resposta}
    Should Be Equal As Integers    ${resposta.status_code}    201
    Should Be Equal As Strings     ${resposta.json()}[message]    Cadastro realizado com sucesso
    Should Not Be Empty    ${resposta.json()}[_id]

Validar erro de e-mail duplicado
    [Arguments]    ${resposta}
    Should Be Equal As Strings    ${resposta.json()}[message]    Este email já está sendo usado