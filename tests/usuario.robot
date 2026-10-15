*** Settings ***

Resource         ../resource/endpoint/usuario.resource
Test Setup       Conectar na API ServeRest

*** Test Cases ***

Cenário 01: Cadastrar um novo usuário com sucesso
    [Documentation]    Deve criar um novo usuário com sucesso
    ...    Cenário positivo
    ${payload}=     Criar dados de usuário válido
    ${resposta}=    Cadastrar usuário na API        ${payload}
    Validar cadastro com sucesso                    ${resposta}

Cenário 02: Não deve permitir cadastrar usuário com e-mail duplicado
    [Documentation]    Deve criar um novo usuário com sucesso
    ...    Cenário negativo
    ${payload}=          Criar dados de usuário válido
    Cadastrar usuário na API    ${payload}
    ${resposta_erro}=    Cadastrar usuário na API    ${payload}
    Validar erro de e-mail duplicado    ${resposta_erro}

Cenário 03: Não deve permitir cadastrar usuário com e-mail em branco
    [Documentation]    Deve criar um novo usuário com sucesso
    ...    Cenário negativo
    ${payload}=    Criar dados de usuário válido
    Set To Dictionary    ${payload}    email=${EMPTY}
    ${resposta_erro}=    Cadastrar usuário na API    ${payload}

Cenário 04: Deve listar todos os usuários cadastrados
    [Documentation]    Deve retornar todos os usuarios cadastrados
    ...    - Cenario positivo
    ${resposta}=    Listar todos os usuários cadastrados
    Validar listagem de usuarios    ${resposta}
    
Cenário 05: Buscar um usuário específico por ID com sucesso
    [Documentation]    Deve retorna o usuário com sucesso
    ...    - Cenário positivo
    ${payload}=    Criar dados de usuário válido
    ${resposta_cadastro}=    Cadastrar usuário na API    ${payload}
    ${id_gerado}=    Set Variable    ${resposta_cadastro.json()}[_id]
    ${resposta_busca}=    Buscar usuário por ID    ${id_gerado}
    Validar busca de usuário por _ID    ${resposta_busca}    ${payload}

Cenário 06: Não deve buscar usuário com _id inexistente
    [Documentation]    Não deve retornar usuário com _id inexistente
    ...    - Cenário negativo
    ${id_inexistente}=    Set Variable    1234567890abcdef
    ${resposta_busca}=    Buscar usuário por ID    ${id_inexistente}
    Validar erro de busca de usuário por _ID inexistente    ${resposta_busca}

Cenário 07: Deve editar os dados de um usuário com sucesso
    [Documentation]    Cria um usuário, altera o nome dele via PUT e valida a alteração
    ...    - Cenário positivo
    ${payload}=    Criar dados de usuário válido
    ${resposta_cadastro}=    Cadastrar usuário na API    ${payload}
    ${id_gerado}=            Set Variable    ${resposta_cadastro.json()}[_id]
    Set To Dictionary        ${payload}    nome=Fulano Editado QA
    ${resposta_edicao}=      Editar usuário na API    ${id_gerado}    ${payload}
    Validar edição com sucesso    ${resposta_edicao}
    Log To Console    ${resposta_edicao.json()};
    
Cenário 08: Deve criar usuário se não existir cadastro
    [Documentation]    Caso os dados editados não exista, deverá ser feito o cadastro com sucesso
    ...    - Cenário positivo
    ${payload}=    Criar dados de usuário válido
    ${id_inexistente}=     Set Variable    1234567890abcdeg
    ${resposta_edicao}=    Editar usuário na API    ${id_inexistente}    ${payload}
    Validar cadastro com sucesso                    ${resposta_edicao}

Cenário 09: Não deve atualizar dados com email duplicado
    [Documentation]    Não deve atualizar dados, caso já tenha dados existentes
    ...    - Cenário negativo
    ${payload}=    Criar dados de usuário válido
    ${resposta_cadastro}=    Cadastrar usuário na API    ${payload}
    ${outro_id}=             Set Variable    outroid123456789
    ${resposta_edicao}=      Editar usuário na API    ${outro_id}    ${payload}
    Validar edição duplicada    resposta=${resposta_edicao}
    Log To Console    ${resposta_edicao}

Cenário 10: Deve deletar o usuário com sucesso
    [Documentation]    Deverá apagar os dados do usuário com sucesso
    ...    - Cenário positivo
    ${payload}=    Criar dados de usuário válido
    ${resposta_cadastro}    Cadastrar usuário na API    ${payload}
    ${id_gerado}=    Set Variable    ${resposta_cadastro.json()}[_id]
    ${resposta_exclusao}=    Deletar usuário na API    ${id_gerado}
    Validar exclusão com sucesso    resposta=${resposta_exclusao}
    Log To Console    resposta=${resposta_exclusao}

Cenário 11: Deve deletar o usuário com sucesso
    [Documentation]    Ao tentar deletar um ID inexistente, deve retornar status 200
    ...    - Cenário negativo
    ${id_inexistente}=    Set Variable    123456789outroid
    ${resposta_exclusao}=    Deletar usuário na API    ${id_inexistente}
    Validar nenhum registro excluído    ${resposta_exclusao}
    Log To Console    ${resposta_exclusao}