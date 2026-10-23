*** Settings ***
Documentation    Keywords de ação e validação do endpoint /produtos
Resource         ../base.resource
Resource         ../endpoint/login.resource

*** Variables ***
${TOKEN_ADMIN}    ${NONE}

*** Keywords ***
Preparar suíte de produtos
    Conectar na API ServeRest
    ${token}=    Obter token de acesso    administrador=true
    Set Suite Variable    ${TOKEN_ADMIN}    ${token}

# -- Criando produtos --
Criar dados de produto válido
    ${aleatorio}=    Generate Random String    length=6    chars=[LOWER]
    ${payload}=      Create Dictionary
    ...              nome=Produto QA ${aleatorio}
    ...              preco=${150}
    ...              descricao=Produto de teste automatizado
    ...              quantidade=${10}
    RETURN           ${payload}

# --- Ação POST ---
Cadastrar produto na API
    [Arguments]    ${payload}    ${token}=${TOKEN_ADMIN}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resposta}=   POST On Session      alias=serverest    url=/produtos    json=${payload}    headers=${headers}    expected_status=any
    RETURN         ${resposta}

# --- Ação GET ---
Listar todos os produtos cadastrados
    ${resposta}=   GET On Session       alias=serverest    url=/produtos    expected_status=any
    RETURN         ${resposta}

Buscar produto por ID
    [Arguments]    ${id_produto}
    ${resposta}=   GET On Session       alias=serverest    url=/produtos/${id_produto}    expected_status=any
    RETURN         ${resposta}

# --- Ação PUT ---
Editar produto por ID
    [Arguments]    ${id_produto}    ${payload_atualizado}    ${token}=${TOKEN_ADMIN}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resposta}=   PUT On Session       alias=serverest    url=/produtos/${id_produto}    json=${payload_atualizado}    headers=${headers}    expected_status=any
    RETURN         ${resposta}

# --- Ação DELETE ---
Deletar produto na API
    [Arguments]    ${id_produto}    ${token}=${TOKEN_ADMIN}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resposta}=   DELETE On Session    alias=serverest    url=/produtos/${id_produto}    headers=${headers}    expected_status=any
    RETURN         ${resposta}

# --- Validações ---
Validar listagem de produtos
    [Arguments]    ${resposta}
    Status Should Be                 200    ${resposta}
    Dictionary Should Contain Key    ${resposta.json()}    produtos

Validar busca de produto por ID
    [Arguments]    ${resposta_busca}    ${payload_enviado}
    Status Should Be                200    ${resposta_busca}
    Should Be Equal As Strings      ${resposta_busca.json()}[nome]          ${payload_enviado}[nome]
    Should Be Equal As Integers     ${resposta_busca.json()}[preco]         ${payload_enviado}[preco]
    Should Be Equal As Strings      ${resposta_busca.json()}[descricao]     ${payload_enviado}[descricao]
    Should Be Equal As Integers     ${resposta_busca.json()}[quantidade]    ${payload_enviado}[quantidade]