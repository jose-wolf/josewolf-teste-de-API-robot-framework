*** Settings ***
Documentation    Suíte de testes do endpoint /carrinhos da API ServeRest
Resource         ../resource/endpoint/carrinho.resource
Suite Setup      Preparar suíte de carrinhos

*** Test Cases ***
Cenário 01: Cadastrar um novo carrinho com sucesso
    [Documentation]    Deve criar um novo carrinho com um produto válido
    ...                - Cenário positivo
    [Tags]             positivo    post    smoke
    [Teardown]         Cancelar compra na API
    ${payload}=        Criar dados de carrinho válido
    ${resposta}=       Cadastrar carrinho na API         ${payload}
    Validar cadastro com sucesso                         ${resposta}

Cenário 02: Não deve permitir ter mais de um carrinho ativo para o mesmo usuário
    [Documentation]    Deve retornar 400 ao tentar criar um segundo carrinho com o mesmo usuário
    ...                - Cenário negativo
    [Tags]             negativo    post
    [Teardown]         Cancelar compra na API
    ${payload}=          Criar dados de carrinho válido
    Cadastrar carrinho na API       ${payload}
    ${resposta_erro}=    Cadastrar carrinho na API    ${payload}
    Validar retorno da API          ${resposta_erro}    400    Não é permitido ter mais de 1 carrinho

Cenário 03: Não deve permitir cadastrar carrinho com produto inexistente
    [Documentation]    Deve retornar 400 ao enviar um idProduto que não existe
    ...                - Cenário negativo
    [Tags]             negativo    post
    ${payload}=          Criar dados de carrinho válido    id_produto=1234567890abcdef
    ${resposta_erro}=    Cadastrar carrinho na API         ${payload}
    Validar retorno da API    ${resposta_erro}    400    Produto não encontrado

Cenário 04: Não deve permitir cadastrar carrinho com quantidade maior que o estoque
    [Documentation]    Deve retornar 400 quando a quantidade solicitada ultrapassa o estoque do produto (10)
    ...                - Cenário negativo
    [Tags]             negativo    post
    ${payload}=          Criar dados de carrinho válido    quantidade=${999}
    ${resposta_erro}=    Cadastrar carrinho na API         ${payload}
    Validar retorno da API    ${resposta_erro}    400    Produto não possui quantidade suficiente

Cenário 05: Não deve permitir cadastrar carrinho sem token de autenticação
    [Documentation]    Deve retornar 401 quando o header Authorization estiver vazio
    ...                - Cenário negativo
    [Tags]             negativo    post    auth
    ${payload}=          Criar dados de carrinho válido
    ${resposta_erro}=    Cadastrar carrinho na API         ${payload}    token=${EMPTY}
    Validar retorno da API    ${resposta_erro}    401    Token de acesso ausente, inválido, expirado ou usuário do token não existe mais

Cenário 06: Deve listar todos os carrinhos cadastrados
    [Documentation]    Deve retornar a lista de todos os carrinhos cadastrados na API
    ...                - Cenário positivo
    [Tags]             positivo    get
    ${resposta}=       Listar todos os carrinhos cadastrados
    Validar listagem de carrinhos    ${resposta}

Cenário 07: Buscar um carrinho específico por ID com sucesso
    [Documentation]    Cria um carrinho, consulta pelo _id gerado e valida os dados
    ...                - Cenário positivo
    [Tags]             positivo    get
    [Teardown]         Cancelar compra na API
    ${payload}=              Criar dados de carrinho válido
    ${resposta_cadastro}=    Cadastrar carrinho na API    ${payload}
    ${id_gerado}=            Set Variable    ${resposta_cadastro.json()}[_id]
    ${resposta_busca}=       Buscar carrinho por ID       ${id_gerado}
    Validar busca de carrinho por ID    ${resposta_busca}    ${id_gerado}

Cenário 08: Não deve buscar carrinho com _id inexistente
    [Documentation]    Deve retornar 400 ao buscar carrinho por _id que não existe
    ...                - Cenário negativo
    [Tags]             negativo    get
    ${id_inexistente}=    Set Variable    1234567890abcdef
    ${resposta_busca}=    Buscar carrinho por ID    ${id_inexistente}
    Validar retorno da API    ${resposta_busca}    400    Carrinho não encontrado

Cenário 09: Deve concluir uma compra (excluir carrinho) com sucesso
    [Documentation]    Cria um carrinho e finaliza a compra via DELETE /carrinhos/concluir-compra
    ...                - Cenário positivo
    [Tags]             positivo    delete
    ${payload}=              Criar dados de carrinho válido
    Cadastrar carrinho na API    ${payload}
    ${resposta_conclusao}=   Concluir compra na API
    Validar retorno da API   ${resposta_conclusao}    200    Registro excluído com sucesso

Cenário 10: Deve cancelar uma compra e reabastecer o estoque com sucesso
    [Documentation]    Cria um carrinho e cancela a compra via DELETE /carrinhos/cancelar-compra
    ...                - Cenário positivo
    [Tags]             positivo    delete
    ${payload}=                 Criar dados de carrinho válido
    Cadastrar carrinho na API    ${payload}
    ${resposta_cancelamento}=   Cancelar compra na API
    Validar retorno da API      ${resposta_cancelamento}    200    Registro excluído com sucesso. Estoque dos produtos reabastecido