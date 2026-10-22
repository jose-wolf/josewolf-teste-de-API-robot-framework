*** Settings ***
Documentation    Suíte de testes do endpoint /usuarios da API ServeRest
Resource         ../resource/endpoint/usuario.resource
Suite Setup      Conectar na API ServeRest

*** Test Cases ***
Cenário 01: Cadastrar um novo usuário com sucesso
    [Documentation]    Deve criar um novo usuário com sucesso
    ...                - Cenário positivo
    [Tags]             positivo    post    smoke
    ${payload}=        Criar dados de usuário válido
    ${resposta}=       Cadastrar usuário na API        ${payload}
    Validar cadastro com sucesso                       ${resposta}

Cenário 02: Não deve permitir cadastrar usuário com e-mail duplicado
    [Documentation]    Não deve criar um novo usuário devido a e-mail já cadastrado
    ...                - Cenário negativo
    [Tags]             negativo    post
    ${payload}=          Criar dados de usuário válido
    Cadastrar usuário na API       ${payload}
    ${resposta_erro}=    Cadastrar usuário na API    ${payload}
    Validar retorno da API         ${resposta_erro}    400    Este email já está sendo usado

Cenário 03: Não deve permitir cadastrar usuário com e-mail em branco
    [Documentation]    Não deve criar um novo usuário com o campo email vazio
    ...                - Cenário negativo
    [Tags]             negativo    post
    ${payload}=          Criar dados de usuário válido
    Set To Dictionary    ${payload}    email=${EMPTY}
    ${resposta_erro}=    Cadastrar usuário na API    ${payload}
    Validar retorno da API    ${resposta_erro}    400    email não pode ficar em branco    campo=email

Cenário 04: Deve listar todos os usuários cadastrados
    [Documentation]    Deve retornar a lista de todos os usuários cadastrados
    ...                - Cenário positivo
    [Tags]             positivo    get
    ${resposta}=       Listar todos os usuários cadastrados
    Validar listagem de usuários    ${resposta}

Cenário 05: Buscar um usuário específico por ID com sucesso
    [Documentation]    Deve retornar os dados do usuário consultado pelo _id
    ...                - Cenário positivo
    [Tags]             positivo    get
    ${payload}=              Criar dados de usuário válido
    ${resposta_cadastro}=    Cadastrar usuário na API    ${payload}
    ${id_gerado}=            Set Variable    ${resposta_cadastro.json()}[_id]
    ${resposta_busca}=       Buscar usuário por ID    ${id_gerado}
    Validar busca de usuário por ID    ${resposta_busca}    ${payload}

Cenário 06: Não deve buscar usuário com _id inexistente
    [Documentation]    Não deve retornar usuário ao buscar por _id inexistente
    ...                - Cenário negativo
    [Tags]             negativo    get
    ${id_inexistente}=    Set Variable    1234567890abcdef
    ${resposta_busca}=    Buscar usuário por ID    ${id_inexistente}
    Validar retorno da API    ${resposta_busca}    400    Usuário não encontrado

Cenário 07: Deve editar os dados de um usuário com sucesso
    [Documentation]    Cria um usuário, altera o nome dele via PUT e valida a alteração
    ...                - Cenário positivo
    [Tags]             positivo    put
    ${payload}=              Criar dados de usuário válido
    ${resposta_cadastro}=    Cadastrar usuário na API    ${payload}
    ${id_gerado}=            Set Variable    ${resposta_cadastro.json()}[_id]
    Set To Dictionary        ${payload}    nome=Fulano Editado QA
    ${resposta_edicao}=      Editar usuário na API    ${id_gerado}    ${payload}
    Validar retorno da API   ${resposta_edicao}    200    Registro alterado com sucesso

Cenário 08: Deve criar usuário via PUT se não existir cadastro
    [Documentation]    Caso o _id enviado no PUT não exista, deve criar um novo usuário (status 201)
    ...                - Cenário positivo
    [Tags]             positivo    put
    ${payload}=            Criar dados de usuário válido
    ${id_inexistente}=     Set Variable    1234567890abcdeg
    ${resposta_edicao}=    Editar usuário na API    ${id_inexistente}    ${payload}
    Validar cadastro com sucesso    ${resposta_edicao}

Cenário 09: Não deve atualizar dados com e-mail duplicado
    [Documentation]    Não deve permitir atualizar via PUT usando um e-mail que já pertence a outro usuário
    ...                - Cenário negativo
    [Tags]             negativo    put
    ${payload}=              Criar dados de usuário válido
    Cadastrar usuário na API    ${payload}
    ${outro_id}=             Set Variable    outroid123456789
    ${resposta_edicao}=      Editar usuário na API    ${outro_id}    ${payload}
    Validar retorno da API   ${resposta_edicao}    400    Este email já está sendo usado

Cenário 10: Deve deletar o usuário com sucesso
    [Documentation]    Deverá apagar os dados do usuário cadastrado com sucesso
    ...                - Cenário positivo
    [Tags]             positivo    delete
    ${payload}=              Criar dados de usuário válido
    ${resposta_cadastro}=    Cadastrar usuário na API    ${payload}
    ${id_gerado}=            Set Variable    ${resposta_cadastro.json()}[_id]
    ${resposta_exclusao}=    Deletar usuário na API    ${id_gerado}
    Validar retorno da API   ${resposta_exclusao}    200    Registro excluído com sucesso

Cenário 11: Não deve deletar usuário com _id inexistente
    [Documentation]    Ao tentar deletar um ID inexistente, deve retornar status 200 e mensagem 'Nenhum registro excluído'
    ...                - Cenário negativo
    [Tags]             negativo    delete
    ${id_inexistente}=       Set Variable    123456789outroid
    ${resposta_exclusao}=    Deletar usuário na API    ${id_inexistente}
    Validar retorno da API   ${resposta_exclusao}    200    Nenhum registro excluído