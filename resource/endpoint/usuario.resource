*** Settings ***
Documentation    Keywords de ação e validação do endpoint /usuarios
Resource         ../base.resource


*** Variables ***
${USUARIO_PADRAO}    ${None}


*** Keywords ***
# --- Massa de Dados ---
Criar dados de usuário válido
    [Arguments]    ${administrador}=true
    ${aleatorio}=    Generate Random String    length=6    chars=[LOWER]
    ${payload}=      Create Dictionary
    ...              nome=Fulano QA
    ...              email=fulano_${aleatorio}@qa.com.br
    ...              password=teste123
    ...              administrador=${administrador}
    RETURN           ${payload}

# --- Ações (POST, GET, PUT, DELETE) ---
Cadastrar usuário na API
    [Arguments]    ${payload}
    ${resposta}=    POST On Session    alias=serverest    url=/usuarios    json=${payload}    expected_status=any
    RETURN          ${resposta}

Listar todos os usuários cadastrados
    ${resposta}=    GET On Session     alias=serverest    url=/usuarios    expected_status=any
    RETURN          ${resposta}

Buscar usuário por ID
    [Arguments]    ${id_usuario}
    ${resposta}=    GET On Session     alias=serverest    url=/usuarios/${id_usuario}    expected_status=any
    RETURN          ${resposta}

Editar usuário na API
    [Arguments]    ${id_usuario}    ${payload_atualizado}
    ${resposta}=    PUT On Session     alias=serverest    url=/usuarios/${id_usuario}    json=${payload_atualizado}    expected_status=any
    RETURN          ${resposta}

Deletar usuário na API
    [Arguments]    ${id_usuario}
    ${resposta}=    DELETE On Session    alias=serverest    url=/usuarios/${id_usuario}    expected_status=any
    RETURN          ${resposta}

# --- Validações Específicas de /usuarios ---
Validar cadastro com sucesso
    [Arguments]    ${resposta}
    Validar retorno da API    ${resposta}    201    Cadastro realizado com sucesso
    Should Not Be Empty       ${resposta.json()}[_id]

Validar listagem de usuários
    [Arguments]    ${resposta}
    Status Should Be                 200    ${resposta}
    Dictionary Should Contain Key    ${resposta.json()}    usuarios

Validar busca de usuário por ID
    [Arguments]    ${resposta_busca}    ${payload_enviado}
    Status Should Be              200    ${resposta_busca}
    Should Be Equal As Strings    ${resposta_busca.json()}[nome]     ${payload_enviado}[nome]
    Should Be Equal As Strings    ${resposta_busca.json()}[email]    ${payload_enviado}[email]