# "Building Batch Data Pipelines on Google Cloud"



## Módulo 1: Introduction to Building Batch Data Pipelines

- EL -  Os dados são importados "como estão";
- ELT - os dados brutos são carregados no sistema e transformados quando necessário;
- ETL - integração de dados - a transformação ocorre em um serviço intermediário (Ex. Dados transformados no DataFlow antes de serem carregados no Big Query)

### Considerações sobre a qualidade

A informação pode ser:
- válida - De acordo com as regras do negócio
- precisa - De acordo com a realidade objetiva
- completa - Ausência de dados corrompidos
- consistente - Operações corretas (Ex. de problema: duas operações que **deveriam** ser iguais têm resultados **diferentes**.
- uniforme - Os valores dos dados da mesma coluna, em linhas diferentes significam a mesma coisa e estão na mesma unidade de medida

ELT no BigQuery geralmente pode ajudar a corrigir muitos problemas de qualidade de dados:

- registros duplicados fazem parecer que um tipo de evento é mais comum > Remover duplicatas > cláusula COUNT DISTINCT do BigQuery

- Dados inválidos podem ser filtrados usando uma **View** do BigQuery e todos podem acessar a view em vez dos dados brutos

### Operações no Big Query

Podemos usar Visualizações para filtrar as linhas com problemas de qualidade. Ex:

- Remover quantidades menores que zero usando uma cláusula WHERE. 
- Após fazer um GROUP BY, é possível descartar grupos com menos de 10 registros usando a cláusula HAVING. 
- Lidar com NULLS e BLANKS.
	- NULL significa ausência de dados
	- BLANK é uma string vazia. 
- Pode filtrar tanto NULLS quanto BLANKS ou apenas NULLs ou apenas BLANKs. 
- É possível contar valores não NULL usando COUNTIF e usar a instrução IF para desprezar valores específicos. 

Problemas de consistência geralmente se devem a duplicatas. Você espera que algo seja único mas não é,  e os totais não batem, por exemplo. 
- COUNT fornece o número de linhas em uma tabela que contêm um valor não null. 
- COUNT DISTINCT fornece o número de valores únicos.
- Se forem diferentes, existem valores **duplicados**. 
- E Se você executar um GROUP BY, e algum grupo contiver mais de uma linha, quer dizer que há duas ou mais ocorrências desse valor.

Outro motivo de problemas de consistência é ter caracteres extras em campos. Exemplo: ao receber carimbos de data/hora, alguns podem incluir um fuso horário. Ou strings com preenchimento. Use funções de string para limpar esses dados antes de transmitir.

Para garantir a precisão, teste os dados em relação a valores conhecidos. Por exemplo, se você tem um pedido, pode calcular o subtotal da quantidade vezes o valor do item e verificar se a conta está correta. 

Também é possível verificar se um valor que está sendo inserido pertence à lista canônica de valores aceitáveis. Para fazer isso, use SQL IN.

Para completude, identifique todos os valores ausentes e filtre ou substitua esses valores por algo razoável. Se o valor ausente é NULL, o SQL tem funções como NULLIF, COUNTIF, COALESCE etc. para filtrar valores que estão ausentes nos cálculos.

Você pode usar UNION de outra origem para considerar os meses com dados ausentes. 

O processo automático de detecção de quedas de dados e solicitação de itens de dados para preencher as lacunas é a "adição retroativa de dados"(**backfilling**). É um recurso de alguns serviços de transferência de dados. 

Ao carregar dados, verifique a integridade do arquivo com valores de checksum (hash, MD5)

O que acontece se você armazena um valor em centímetros e começar a receber valores em milímetros? Seu data warehouse vai ter dados não uniformes. É preciso ter proteção contra isso.
Use SQL cast para evitar que tipos de dados mudem em uma tabela. Use a função SQL FORMAT() para indicar as unidades com clareza. Documente para facilitar a identificação.

### Limitações do ELT

Quando processos de ELT não são o suficiente deve ser feito o ETL

Ex. 1: Uso de uma API externa para traduzir um texto (Não pode ser feito usando SQL)
ex. 2: Analisar o fluxo de ações de determinado cliente em um período (É possível usar "windows agregations" para isso, mas é bem mais simples usar lógica da programação)

**Arquitetura de Referência do Google Cloud**:

- **E**xtrair dados do **Pub/Sub**, do Cloud Storage, do Cloud Spanner, do Cloud SQL etc. 
- **T**ransformar os dados usando o **Dataflow**.
- Fazer o pipeline do Dataflow gravar(**L**oad) no **BigQuery**.

Quando fazer isso? 
- Os dados brutos precisarem de controle de qualidade, transformação ou enriquecimento antes de serem carregados no BigQuery;
- For difícil fazer transformações no SQL. 
- O carregamento de dados precisar ser contínuo (**Streaming**)
- Quando quiser integrar sistemas de integração contínua /entrega contínua (CI/CD)e realizar testes de unidade em todos os componentes.

Serviços de transformação e processamento de dados que o Google Cloud oferece: 

- **Dataflow**
	- serviço de processamento de dados sem servidor
	- totalmente gerenciado 
	- baseado no Apache Beam
	- compatível com pipelines de processamento de dados em batch e streaming
	- templates fornecidos pelo Google Cloud para início rápido
- **Dataproc** - serviço de Cluster Baseado no Apache Hadoop
- Cloud Data Fusion -  interface gráfica simples de usar(pipelines podem ser implantados em escala em clusters do Dataproc)

### ETL para resolver problemas de qualidade de dados

Quais necessidades não podem ser facilmente atendidas usando Dataflow e BigQuery?

- Baixa latência e alta capacidade de processamento 
	- As consultas do BigQuery estão sujeitas a latência de algumas centenas de milissegundos(Usando BI Engine), e;  
	- Transmissão de cerca de um milhão de linhas por segundo para uma tabela do BigQuery. (Costumavam ser 100.000 linhas, mas recentemente aumentaram para 1 milhão de linhas por projeto)
- Para menor latência ou maior capacidade de processamento, o **Cloud Bigtable** pode ser um coletor melhor para os pipelines de processamento de dados.
- Reutilizar pipelines Spark - Altos investimentos em Hadoop e no Spark.

- Necessidade de criação de pipeline visual. 
	- O Dataflow requer que o código de pipelines de dados seja escrito em Java ou Python.
- Se analistas de dados e usuários não técnicos precisam criar pipelines de dados, use o **Cloud Data Fusion** > "Drag and drop

O **Dataproc** é um serviço gerenciado para processamento em lote, consultas, streaming e machine learning. É um serviço para cargas de trabalho do Hadoop e é muito econômico ao considerar a eliminação de tarefas relacionadas a executar o Hadoop em um servidor dedicado e as atividades relacionadas a manutenção. Ele também tem recursos robustos, como escalonamento automático e integração pronta com produtos do Google Cloud, como o BigQuery.

O **Cloud Data Fusion** é um serviço totalmente gerenciado nativo da nuvem de integração de dados corporativos para criar e gerenciar pipelines de dados. Ele pode ser usado para preencher data warehouses, garantir a consistência dos dados e fazer transformações e limpeza. Usuários sem experiência com programação podem criar pipelines com elementos gráficos para atender às exigências empresariais, como conformidades regulatórias, sem precisar que uma equipe de TI escreva um pipeline do Dataflow.
O Data Fusion também tem uma API flexível para a equipe de TI criar scripts que automatizam a execução.

Independente do que o ETL usa, Dataflow, Dataproc ou Data Fusion, alguns aspectos fundamentais precisam ser considerados. 

1. **Linhagem dos dados**: De onde os dados vieram, por quais processos eles passaram e em que condições estão são aspectos da linhagem.
Ao conhecer a linhagem, você sabe para que tipos de uso os dados são adequados. Se os dados geram resultados estranhos, verifique a linhagem para descobrir se pode corrigir a causa.
A linhagem também ajuda com confiança e conformidade regulatória. 

2. **Metadados**. Você precisa acompanhar a linhagem dos dados na sua organização a fim de descobrir e identificar os usos adequados.

No Google Cloud, o **Data Catalog** oferece opções de descoberta de dados, mas você precisa adicionar identificadores (labels). Um identificador é um par de chave-valor que ajuda a organizar recursos. 

No BigQuery, você pode anexar identificadores a conjuntos de dados, tabelas e visualizações. 
Identificadores são úteis para gerenciar recursos complexos, porque podem ser filtrados com base nos identificadores. Eles são a primeira etapa para montar um catálogo de dados.

Os identificadores também são úteis no Cloud Billing. Ao anexar identificadores a instâncias do Compute Engine, a buckets e a pipelines do Dataflow, é possível analisar com detalhes sua fatura do Cloud, porque o sistema de faturamento recebe informações dos identificadores e você pode detalhar a cobrança por identificador. 

O Data Catalog é um serviço de gerenciamento de metadados e descoberta de dados altamente escalonável e totalmente gerenciado. Ele é sem servidor e não exige configuração ou gerenciamento de infraestrutura. Ele fornece controles de nível de acesso e respeita as ACLs de origem para leitura, gravação e pesquisa dos ativos de dados, dando a você controle de acesso de nível empresarial. Pense no Data Catalog como metadados como serviço. É um serviço de gerenciamento de metadados para catalogar recursos de dados usando APIs personalizadas e IU, oferecendo visualização unificada dos dados, onde quer que estejam. 
- Ele suporta tags esquematizadas, como Enum, Bool, DateTime, e não apenas tags de texto simples, fornecendo metadados corporativos complexos e organizados.
- Ele oferece descoberta unificada de dados de todos os recursos de dados, distribuídos entre vários projetos e sistemas. 
- Ele vem com uma IU de pesquisa simples e fácil de usar para encontrar ativos de dados de maneira rápida e fácil, com a mesma tecnologia de pesquisa do Google utilizada pelo Gmail e pelo Drive. 
- Como um catálogo central, ele também fornece um sistema de catalogação flexível e robusto para captura de metadados técnicos, automaticamente, e empresariais, com tags, em um formato estruturado. 

Uma das melhores coisas da descoberta de dados é que ela se integra à API Cloud Data Loss Prevention. Use para descobrir e classificar dados confidenciais, tornando os sistemas mais inteligentes e simplificando o processo de governança de dados. 

O Data Catalog capacita os usuários para anotar metadados empresariais de maneira colaborativa e é um dos pilares da governança de dados. Especificamente, o Data Catalog disponibiliza todos os metadados sobre os conjuntos de dados para seus usuários pesquisarem, não importa onde os dados estejam armazenados.

O Data Catalog possibilita agrupar conjuntos de dados com tags, sinalizar que determinadas colunas contêm dados confidenciais etc. Por que isso é útil? Caso você tenha muitos conjuntos de dados com muitas tabelas acessadas por usuários que tenham níveis de acesso diferentes, o Data Catalog fornece uma experiência de usuário unificada para descoberta rápida desses conjuntos de dados. Não é mais preciso procurar tabelas específicas nos bancos de dados, que talvez não sejam acessíveis por todos os usuários.