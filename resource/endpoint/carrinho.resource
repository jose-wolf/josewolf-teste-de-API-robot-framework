*** Settings ***
Documentation    Keywords de ação e validação do endpoint /carrinhos
Resource         ../base.resource
Resource         ../endpoint/produto.resource

*** Variables ***
${TOKEN_ADMIN}    ${None}
${ID_PRODUTO_PADRAO}    ${None}

*** Keywords ***

Preparar suíte de carrinhos
    Conectar na API ServeRest
    ${token}=    Obter token de acesso    administrador=true
    Set Suite Variable    ${TOKEN_ADMIN}    ${token}
    ${payload_produto}=    Criar dados de produto válido
    ${resposta_produto}=    Cadastrar produto na API    ${payload_produto}    token=${TOKEN_ADMIN}
    Set Suite Variable    ${ID_PRODUTO_PADRAO}    ${resposta_produto.json()}[_id]

# -- Criando os dados de carrinho --
Criar dados de carrinho válido
    [Arguments]    ${id_produto}=${ID_PRODUTO_PADRAO}    ${quantidade}=${1}
    ${item}=    Create Dictionary    idProduto=${id_produto}    quantidade=${quantidade}
    ${lista_produtos}=    Create List    ${item}
    ${payload}=    Create Dictionary    produtos=${lista_produtos}
    RETURN    ${payload}

# -- Ação Post --
Cadastrar carrinho na API
    [Arguments]    ${payload}    ${token}=${TOKEN_ADMIN}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resposta}=   POST On Session      alias=serverest    url=/carrinhos    json=${payload}    headers=${headers}    expected_status=any
    RETURN         ${resposta}

# -- Ação GET --
Listar todos os carrinhos cadastrados
    ${resposta}=   GET On Session       alias=serverest    url=/carrinhos    expected_status=any
    RETURN         ${resposta}

Buscar carrinho por ID
    [Arguments]    ${id_carrinho}
    ${resposta}=   GET On Session       alias=serverest    url=/carrinhos/${id_carrinho}    expected_status=any
    RETURN         ${resposta}

# -- ação delete --

Concluir compra na API
    [Arguments]    ${token}=${TOKEN_ADMIN}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resposta}=   DELETE On Session    alias=serverest    url=/carrinhos/concluir-compra    headers=${headers}    expected_status=any
    RETURN         ${resposta}

Cancelar compra na API
    [Arguments]    ${token}=${TOKEN_ADMIN}
    ${headers}=    Create Dictionary    Authorization=${token}
    ${resposta}=   DELETE On Session    alias=serverest    url=/carrinhos/cancelar-compra    headers=${headers}    expected_status=any
    RETURN         ${resposta}

# -- Validações --

Validar listagem de carrinhos
    [Arguments]    ${resposta}
    Status Should Be                 200    ${resposta}
    Dictionary Should Contain Key    ${resposta.json()}    carrinhos
    
Validar busca de carrinho por ID
    [Arguments]    ${resposta_busca}    ${id_carrinho_esperado}
    Status Should Be                 200    ${resposta_busca}
    Should Be Equal As Strings       ${resposta_busca.json()}[_id]    ${id_carrinho_esperado}
    Dictionary Should Contain Key    ${resposta_busca.json()}         produtos
    Dictionary Should Contain Key    ${resposta_busca.json()}         precoTotal