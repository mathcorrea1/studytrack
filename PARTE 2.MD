Projeto Prático

Objetivo
Desenvolver um Aplicativo com o framework Flutter, de acordo com o tema escolhido.

Importante
1. Ler atentamente os requisitos funcionais e não-funcionais para o
desenvolvimento do aplicativo. O correto entendimento dos requisitos faz parte
do processo avaliativo.
2. Ler atentamente as instruções sobre como entregar a versão final do aplicativo,
sobre a apresentação do aplicativo em funcionamento, bem como sobre os
critérios de avaliação.
3. O aplicativo pode ser desenvolvido individualmente ou em duplas e corresponde
a 100% da nota da Avaliação Final.

Requisitos Funcionais
RF001 Autenticação de Usuários

O aplicativo deve permitir a autenticação de usuários com o serviço
Firebase Authentication:
● O aplicativo deve permitir que os usuários façam login utilizando
seu endereço de e-mail e senha previamente registrados.
● A interface de login deve permitir também a recuperação de senha.
A interface de usuário deve fornecer feedback claro durante o processo de
login, indicando o progresso e quaisquer erros que ocorram.

RF002 Registro de Usuários

O aplicativo deve permitir o registro de usuários com o serviços Firebase
Authentication:
● O aplicativo deve permitir que os usuários se registrem utilizando
um endereço de e-mail válido e uma senha segura.
● No processo de registros é necessário incluir os campos adicionais
(nome, telefone, entre outros), além do e-mail e da senha. Essas
informações deverão ser armazenadas na coleção usuários do
Firebase Firestore.
A interface de usuário deve fornecer feedback claro durante o processo de
registro, indicando o progresso e quaisquer erros que ocorram.

RF003 Inserção de Dados

O aplicativo deve permitir a inserção de dados em duas coleções distintas
do Firebase Firestore.
Cada coleção deve ser composta por pelo menos cinco campos. A
identificação dos campos, bem como o tipo de dados é de livre escolha.

O aplicativo deve exibir uma mensagem de confirmação ao usuário,
indicando que os dados foram (ou não) inseridos com sucesso.
A inserção deve garantir que todos os dados, em todas as coleções, sejam
separados por usuário. Assim, apenas o usuário logado no aplicativo
poderá ter acesso aos seus dados.

RF004 Atualização de Dados

O aplicativo deve permitir que os usuários atualizem informações
existentes armazenadas no Firebase Firestore de forma precisa e eficiente.
A atualização de dados deve ser realizada em pelo menos duas coleções.
O processo de atualização deve ser rápido e eficiente, garantindo uma
experiência de usuário satisfatória.
Em caso de falha na atualização dos dados, o sistema deve fornecer
feedback adequado ao usuário e permitir tentativas adicionais.

RF005 Recuperação de Dados

O aplicativo deve ser capaz de recuperar informações armazenadas no
Firebase Firestore. A exibição dos dados deve ser realizada em tempo real,
através da classe StreamBuilder e do widget ListView ou GridView.
As informações recuperadas devem refletir com precisão os dados
armazenados no Firebase Firestore.
O processo de recuperação de informações deve ser rápido e eficiente,
garantindo uma experiência de usuário responsiva.
Em caso de falha na recuperação dos dados, o sistema deve fornecer
feedback adequado ao usuário e permitir tentativas adicionais.
A recuperação de dados deve ser realizada em pelo menos duas coleções
do banco de dados.

RF006 Pesquisa de Dados

O aplicativo deve permitir que os usuários realizem pesquisas eficazes e
ordenem os resultados em dados armazenados no Firebase Firestore, a
fim de encontrar e visualizar informações relevantes conforme necessário.
A implementação da Pesquisa de Dados é diferente da Recuperação de
Dados, assim, uma interface gráfica deve ser elaborada exclusivamente
para pesquisa. A coleção utilizada no procedimento de pesquisa é de livre
escolha do desenvolvedor.
O usuário tem a opção de ordenar os resultados da pesquisa com base em
critérios específicos, como data, relevância, ordem alfabética, etc.
A pesquisa não deve ser sensível a maiúsculas e minúsculas, fornecendo
resultados precisos independentemente da capitalização dos termos de
pesquisa.

RF007 Consumo API

O aplicativo deve ser capaz de consumir qualquer tipo de API REST para
troca de dados com serviços externos.

Requisitos Não-Funcionais
■ O aplicativo deve ser desenvolvido com o Flutter SDK.
■ O aplicativo deve ser integrado à plataforma de serviços Google Firebase.
■ A versão final do aplicativo deve ser publicada no Firebase Hosting.
■ O design deve ser intuitivo e fácil de usar, com botões e controles claramente
identificáveis.

O que deverá ser entregue?
O aplicativo poderá ser desenvolvido individualmente ou em dupla.
A entrega do projeto deverá ser realizada por meio de um repositório público no GitHub.
Para isso, os alunos devem:
1. Criar um repositório público no GitHub;
2. Disponibilizar no repositório todo o código-fonte do aplicativo, devidamente
organizado;
3. Garantir que o projeto possa ser compilado e executado a partir dos arquivos
disponibilizados no repositório.
4. O link do repositório deve estar acessível publicamente no momento da
correção.
Deverá ser elaborado um vídeo de apresentação do aplicativo, com duração máxima de
4 (quatro) minutos, contendo:
● Demonstração do aplicativo em funcionamento;
● Apresentação de trechos do código-fonte, com foco nas partes relacionadas aos
critérios de avaliação (rubricas) do projeto.
● O vídeo deve ser entregue por meio do link do Youtube, GDrive, ou similar.
A entrega será realizada por meio de um arquivo de texto contendo as seguintes
informações:
● Nome completo dos alunos;
● Endereço de publicação do App no Firebase Hosting
● Código de matrícula dos alunos;
● Link para o repositório do projeto no GitHub.
● Link para o vídeo
Importante: projetos entregues sem o vídeo de apresentação terão a nota zerada.

Critérios de Avaliação
● A identificação de cópias indiscriminadas de código-fonte da internet, ou de
colegas da turma, ocasionará nota zero para todos os envolvidos.

[10%] RF001: Autenticação de Usuários Pontuação
A aplicação permite que os usuários façam login utilizando seu endereço de
e-mail e senha previamente registrados no serviço Firebase Authentication.
A interface de login inclui uma opção para recuperação de senha, permitindo
que os usuários solicitem a redefinição de sua senha por e-mail, conforme
especificado nos requisitos.
A interface de usuário fornece feedback claro e informativo durante o
processo de login, indicando o progresso da operação e exibindo mensagens
de erro quando ocorrem problemas.

[10%] RF002: Registro de Usuários Pontuação
A aplicação permite que os usuários se registrem utilizando um endereço de
e-mail válido e uma senha segura no serviço Firebase Authentication.
No processo de registro, a aplicação coleta e armazena três campos
adicionais além do e-mail e da senha na coleção "usuários" do Firebase
Firestore, conforme especificado nos requisitos.
O registro de usuário inclui validação da senha, verificando se ela atende aos
critérios de segurança, como comprimento mínimo, presença de caracteres
especiais e combinação de letras maiúsculas e minúsculas, garantindo a
segurança das contas dos usuários.
A interface de usuário fornece feedback claro e informativo durante o
processo de registro, indicando o progresso da operação e exibindo
mensagens de erro quando ocorrem problemas.

[20%] RF003: Inserção de Dados Pontuação
A aplicação permite a inserção de dados em quatro coleções distintas do
Firebase Firestore, cada uma composta por pelo menos cinco campos,
conforme especificado nos requisitos.

Os campos das coleções são identificados e possuem tipos de dados
apropriados para armazenar as informações correspondentes, garantindo a
integridade e consistência dos dados inseridos.
Após a inserção dos dados, a aplicação exibe uma mensagem de
confirmação ao usuário, indicando se os dados foram inseridos com
sucesso ou se ocorreu algum erro durante o processo.
A integração com o Firebase Firestore é realizada de forma eficiente e
segura, garantindo que os dados sejam armazenados corretamente e que
apenas o usuário autorizado tenha acesso aos seus próprios dados.

[15%] RF004: Atualização de Dados Pontuação
A aplicação permite a atualização de informações em pelo menos duas
coleções distintas do Firebase Firestore, conforme especificado nos
requisitos.
Em caso de falha na atualização dos dados, o sistema fornece feedback
adequado ao usuário, indicando o motivo da falha.
A integração com o Firebase Firestore é realizada de forma eficiente e
segura, garantindo que as atualizações de dados sejam realizadas
corretamente e que as informações sejam refletidas de maneira consistente
em todas as coleções relacionadas.

[20%] RF005: Recuperação de Dados Pontuação
A aplicação utiliza a classe StreamBuilder e o widget ListView para exibir as
informações recuperadas do Firebase Firestore em tempo real, garantindo
que quaisquer atualizações nos dados sejam refletidas imediatamente na
interface do usuário.
As informações recuperadas do Firebase Firestore refletem com precisão os
dados armazenados, garantindo que qualquer alteração nos dados seja
apresentada de maneira consistente na interface do usuário em tempo real.
A recuperação de dados é realizada a partir de duas coleções distintas.

[15%] RF006: Pesquisa de Dados Pontuação
A aplicação implementa um sistema de pesquisa eficaz em uma coleção

específica do Firebase Firestore, permitindo que os usuários encontrem
informações relevantes conforme necessário.
A aplicação elabora uma interface gráfica exclusiva para pesquisa,
facilitando aos usuários a inserção de termos de pesquisa e a visualização
dos resultados retornados de maneira clara e organizada.
Os usuários têm a opção de ordenar os resultados da pesquisa com base
em critérios específicos, como data, relevância, ordem alfabética, etc.,
proporcionando uma experiência personalizada e adaptada às necessidades
do usuário.
A pesquisa não diferencia maiúsculas e minúsculas, garantindo que os
resultados sejam precisos independentemente da capitalização dos termos
de pesquisa fornecidos pelos usuários.

[10%] RF007: Consumir API Pontuação
O aplicativo deverá consumir uma API pública.