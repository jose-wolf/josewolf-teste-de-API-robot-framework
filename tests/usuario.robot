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
