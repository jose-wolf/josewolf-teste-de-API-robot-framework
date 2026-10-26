*** Settings ***
Documentation    Suíte de testes do endpoint /produtos da API ServeRest
Resource         ../resource/endpoint/produto.resource
Suite Setup      Preparar suíte de produtos

*** Test Cases ***
Cenário 01: Cadastrar um novo produto com sucesso
    [Documentation]    Deve criar um novo produto enviando token de administrador
    ...                - Cenário positivo
    [Tags]             positivo    post    smoke
    ${payload}=        Criar dados de produto válido
    ${resposta}=       Cadastrar produto na API        ${payload}
    Validar cadastro com sucesso                       ${resposta}

Cenário 02: Não deve permitir cadastrar produto com nome duplicado
    [Documentation]    Não deve criar produto quando já existe outro com o mesmo nome
    ...                - Cenário negativo
    [Tags]             negativo    post
    ${payload}=          Criar dados de produto válido
    Cadastrar produto na API       ${payload}
    ${resposta_erro}=    Cadastrar produto na API    ${payload}
    Validar retorno da API         ${resposta_erro}    400    Já existe produto com esse nome

Cenário 03: Não deve permitir cadastrar produto sem token de autenticação
    [Documentation]    Deve retornar 401 quando o header Authorization estiver vazio/ausente
    ...                - Cenário negativo
    [Tags]             negativo    post    auth
    ${payload}=          Criar dados de produto válido
    ${resposta_erro}=    Cadastrar produto na API    ${payload}    token=${EMPTY}
    Validar retorno da API    ${resposta_erro}    401    Token de acesso ausente, inválido, expirado ou usuário do token não existe mais

Cenário 04: Não deve permitir cadastrar produto com usuário que não é administrador
    [Documentation]    Deve retornar 403 quando o token pertencer a um usuário com administrador=false
    ...                - Cenário negativo
    [Tags]             negativo    post    auth
    ${token_comum}=      Obter token de acesso       administrador=false
    ${payload}=          Criar dados de produto válido
    ${resposta_erro}=    Cadastrar produto na API    ${payload}    token=${token_comum}
    Validar retorno da API    ${resposta_erro}    403    Rota exclusiva para administradores

Cenário 05: Deve listar todos os produtos cadastrados
    [Documentation]    Deve retornar a lista de produtos (rota pública, não exige token)
    ...                - Cenário positivo
    [Tags]             positivo    get
    ${resposta}=       Listar todos os produtos cadastrados
    Validar listagem de produtos    ${resposta}

Cenário 06: Buscar um produto específico por ID com sucesso
    [Documentation]    Deve retornar os dados do produto consultado pelo _id
    ...                - Cenário positivo
    [Tags]             positivo    get
    ${payload}=              Criar dados de produto válido
    ${resposta_cadastro}=    Cadastrar produto na API    ${payload}
    ${id_gerado}=            Set Variable    ${resposta_cadastro.json()}[_id]
    ${resposta_busca}=       Buscar produto por ID       ${id_gerado}
    Validar busca de produto por ID    ${resposta_busca}    ${payload}

Cenário 07: Não deve buscar produto com _id inexistente
    [Documentation]    Deve retornar 400 ao buscar produto por _id que não existe
    ...                - Cenário negativo
    [Tags]             negativo    get
    ${id_inexistente}=    Set Variable    1234567890abcdef
    ${resposta_busca}=    Buscar produto por ID    ${id_inexistente}
    Validar retorno da API    ${resposta_busca}    400    Produto não encontrado

Cenário 08: Deve editar os dados de um produto com sucesso
    [Documentation]    Cria um produto, altera seus dados via PUT e valida a alteração
    ...                - Cenário positivo
    [Tags]             positivo    put
    ${payload}=              Criar dados de produto válido
    ${resposta_cadastro}=    Cadastrar produto na API    ${payload}
    ${id_gerado}=            Set Variable    ${resposta_cadastro.json()}[_id]
    Set To Dictionary        ${payload}      preco=${299}
    ${resposta_edicao}=      Editar produto por ID       ${id_gerado}    ${payload}
    Validar retorno da API   ${resposta_edicao}    200    Registro alterado com sucesso

Cenário 09: Deve deletar um produto com sucesso
    [Documentation]    Cria um produto e realiza sua exclusão via DELETE
    ...                - Cenário positivo
    [Tags]             positivo    delete
    ${payload}=              Criar dados de produto válido
    ${resposta_cadastro}=    Cadastrar produto na API    ${payload}
    ${id_gerado}=            Set Variable    ${resposta_cadastro.json()}[_id]
    ${resposta_exclusao}=    Deletar produto na API      ${id_gerado}
    Validar retorno da API   ${resposta_exclusao}    200    Registro excluído com sucesso

Cenário 10: Não deve deletar produto com _id inexistente
    [Documentation]    Ao tentar deletar um ID inexistente, deve retornar status 200 e mensagem 'Nenhum registro excluído'
    ...                - Cenário negativo
    [Tags]             negativo    delete
    ${id_inexistente}=       Set Variable    123456789outroid
    ${resposta_exclusao}=    Deletar produto na API    ${id_inexistente}
    Validar retorno da API   ${resposta_exclusao}    200    Nenhum registro excluído