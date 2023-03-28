# Módulo 2 - Executing Spark on Dataproc

## O Ecossistema Hadoop
- Apache Hadoop (2006) projeto de código aberto para criação de cluster de computadores com processamento distribuído
	- Armazenamento no HDFS (HDs das máquinas do cluster)
	- Processamento dos dados com MapReduce
	- Favoreceu o crescimento de todo um ecossistema (Hive, Pig, Presto e Spark)
	
- O Apache Spark - mecanismo de análise de alto desempenho para dados em lote e streaming.
	- Processamento em memória (até 100x mais rápido)
	- RDDs (Resilient distributed dataset)

Dataproc supera as limitações físicas de clusters locais:
- A falta de separação entre armazenamento e computação limita a capacidade e o escalonamento rápido.
- Muito da complexidade e sobrecarga do OSS Hadoop tem a ver com suposições que existiam no data center.
Sem essas limitações permite muito mais opções economizando tempo, dinheiro e esforço.

**Dataproc** é um ambiente gerenciado do Hadoop e do Spark.
- executa a maioria dos jobs com alterações mínimas, sem abandonar as ferramentas do Hadoop
- escalona a qualquer momento
- Configuração de jobs flexível (Clusters específicos)




O Spark é capaz de misturar diferentes tipos de aplicativos e ajustar como usa os recursos disponíveis. Usa um modelo de programação declarativo (você diz ao sistema o que quer e ele faz a implementação). Possui vários módulos:
- Spark SQL
- Spark Core (Scala, Java, Python, SQL e R)
- Spark MLLib

## Hadoop na nuvem usando o Dataproc

Como e por que considerar o processamento de job do Hadoop na nuvem usando o Dataproc no Google Cloud

- aproveita as ferramentas de código aberto para processamento em lote, consultas, streaming e machine learning.
- A automação do Dataproc ajuda a criar clusters rapidamente, gerenciá-los com facilidade e economizar desativando-os quando quiser
- Facilita a migração SEM redesenvolvimento -Não é preciso aprender novas ferramentas para usar o Dataproc
- O Spark, o Hadoop, o Pig e o Hive são atualizados com frequência.


Vantagens do Dataproc:
- Baixo custo - O Dataproc custa US$ 0,01 por CPU virtual por cluster por hora, além dos outros recursos que você usa. Os clusters têm instâncias preemptivas com preços de computação mais baixos. Você paga pelos itens quando os usa. O Dataproc cobra segundo a segundo com um período mínimo de um minuto. 
- Muito rápido. Os clusters são iniciados, escalonados e desligados rapidamente. Essas operações levam 90 segundos ou menos em média. 
- Clusters redimensionáveis. Eles são criados e escalonados rapidamente com vários tipos de VMs, tamanhos de disco, número de nós e opções de rede. 
- Ecossistema de código aberto. Use ferramentas, bibliotecas e documentação do Spark e do Hadoop. O Dataproc fornece atualizações frequentes para versões do Spark, Hadoop, Pig e Hive. Não é preciso aprender novas ferramentas ou APIs e é possível mover pipelines ETL ou projetos atuais sem redesenvolvimento. 
- Integrado. A integração com Cloud Storage, BigQuery e Cloud BigTable garante que os dados não serão perdidos. Com o Cloud Logging e o Cloud Monitoring, uma plataforma de dados completa é fornecida. É possível usar o Dataproc para fazer ETL de terabytes de dados brutos de registro no BigQuery para geração de relatórios. 
- Gerenciado. Interaja facilmente com clusters e jobs do Spark ou Hadoop sem a ajuda de um administrador ou software especial usando o console do Cloud, o SDK do Cloud ou a API REST do Dataproc. Depois de trabalhar em um cluster, desative-o para não gastar com um cluster ocioso. 
- Controle de versão. Ele permite alternar entre diferentes versões do Apache Spark, Apache Hadoop e outras ferramentas.
- Muito disponível. Execute clusters com nós primários e defina jobs para reiniciar em caso de falha para garantir a disponibilidade de clusters e jobs.
- Ferramentas de desenvolvimento. Várias maneiras de gerenciar um cluster, com o console do Cloud, o SDK do Cloud, APIs RESTful e acesso SSH. 
- Ações de inicialização. Execute-as para instalar ou personalizar as configurações e bibliotecas quando o cluster for criado.
- Configuração automática ou manual. O Dataproc configura automaticamente hardware e software em clusters, além de permitir o controle manual. 

Ele tem duas maneiras de personalizar clusters: componentes opcionais e ações de inicialização.
- Componentes opcionais podem ser selecionados ao implantar pelo console ou pela linha de comando e incluem Anaconda, Hive, WebHCat, Jupyter Notebook, Zeppelin Notebook, Druid, Presto e Zookeeper. 
- Com ações de inicialização, personalize o cluster especificando executáveis ou scripts que o Dataproc vai executar em todos os nós do cluster do Dataproc imediatamente após a configuração dele. 

Veja um exemplo de como criar um cluster do Dataproc usando o SDK do Cloud. E vamos especificar um script de shell HBase para a inicialização dos clusters. Scripts de inicialização pré-criados podem ser usados na configuração de cluster do Hadoop, como Flink, Jupyter e outros. Veja o link do repositório do GitHub para saber mais. 


Arquitetura do cluster. 

Um cluster do Dataproc pode conter workers secundários preemptivos ou não preemptivos, mas não ambos. 

O conjunto de arquitetura é parecido com o esperado no local.

Você tem um cluster de VMs para processamento e discos permanentes para armazenamento por HDFS. Também há VMs de nó primário em um conjunto de nós de trabalho. Eles podem pertencer a um grupo gerenciado de instâncias, outra maneira de garantir que as VMs desse grupo sejam todas do mesmo modelo. Você pode ativar mais VMs do que o necessário para redimensionar o cluster com base nas demandas e leva poucos minutos para fazer upgrade ou downgrade do cluster. Não considere um cluster como de longa duração. Ative-os quando precisar de processamento de computação e depois desative-os. Também é possível persisti-los indefinidamente.

O que acontece com o armazenamento em disco ao desativar clusters? Ele desaparece e por isso o recomendável é usar o armazenamento fora do cluster conectando-se a outros produtos. 
- Em vez de usar HDFS nativo em um cluster, é possível usar um cluster de buckets no Cloud Storage com o conector HDFS. É fácil adaptar o código Hadoop atual para usar o Cloud Storage em vez do HDFS. Altere o prefixo para este armazenamento de hdfs:// para gs://
- E quanto ao Hbase fora do cluster? Considere escrever no Cloud BigTable. 
- E as grandes cargas de trabalho? Considere ler esses dados no BigQuery e fazer as cargas de trabalho analíticas lá.

O uso do Dataproc envolve uma sequência de eventos: instalação, configuração, otimização, utilização e monitoramento. 

1. Instalação é a criação do cluster, e é possível fazê-la pelo console ou pela linha de comando usando o comando da gcloud. Também é possível exportar um arquivo YAML de um cluster atual ou criar um cluster de um arquivo YAML. Você pode criar um cluster de uma configuração do Terraform ou usar a API REST.

2. Configuração - O cluster pode ser definido como uma única VM, para manter o custo baixo. O padrão é com um único nó primário. A alta disponibilidade tem três nós. É possível escolher uma região e uma zona ou permitir que o serviço escolha a zona. O endpoint padrão é global, mas definir um endpoint regional pode oferecer maior isolamento e, em alguns casos, menor latência. 

O nó primário é onde o namenode HDFS é executado, bem como o nó YARN e os drivers do job. 

A replicação HDFS é padronizada para 2 no Dataproc. 

Os componentes opcionais do ecossistema Hadoop incluem Anaconda, Python Distribution and Package Manager, Hive WebHCat, Jupyter Notebook e Zeppelin Notebook. 

As propriedades do cluster são valores usados por arquivos de configuração para inicializações mais dinâmicas. 

Rótulos de usuário marcam o cluster para intenções de soluções ou relatórios.

Os nós de trabalho de nó primário e os nós de trabalho preemptivos têm opções de VM separadas, como vCPU, memória e armazenamento. Os nós preemptivos incluem o gerenciador de nós, mas não executam o HDFS.

Há um número mínimo de nós de trabalho. O padrão é 2. O número máximo de nós é determinado por uma cota e o número de SSDs anexados a cada worker.

É possível especificar ações de inicialização, como scripts de inicialização que personalizam nós de trabalho. Defina metadados para que as VMs compartilhem informações de estado. 

3. Otimização - VMs preemptivas podem ajudar a reduzir o custo.

Elas podem ser retiradas de serviço a qualquer momento e dentro de 24 horas. O aplicativo pode precisar ser projetado para evitar a perda de dados. Tipos de máquina personalizados especificam o equilíbrio de memória e CPU para ajustar a VM à carga para que você não desperdice recursos. 
Use uma imagem personalizada para pré-instalar o software para que o nó personalizado fique operacional em menos tempo do que ficaria se você instalasse um tempo de inicialização com um script de inicialização. Também é possível usar um disco de inicialização SSD permanente. 

4. Utilização 
Os jobs podem ser enviados pelo console, pelo comando gcloud ou pela API REST.

Eles podem ser iniciados com serviços como Dataproc Workflow e Cloud Composer. 

Não use interfaces diretas do Hadoop para enviar jobs, porque os metadados não estarão disponíveis para gerenciamento de jobs e clusters.

E por segurança, eles são desativados por padrão. 

Os jobs não podem ser reinicializados. Mas é possível criar jobs reinicializáveis pela linha de comando ou API REST. Eles precisam ser projetados para serem idempotentes e para detectar a sucessão e restaurar o estado. 

5. Por fim, depois de enviar seu job, convém monitorá-lo. Faça isso com o Cloud Monitoring ou crie um painel personalizado com gráficos
e configure as políticas de alertas para receber notificações caso ocorram incidentes. Todos os detalhes de HDFS, YARN, métricas sobre um job específico ou métricas gerais do cluster, como utilização de CPU, uso de disco e rede, podem ser monitorados no Cloud Monitoring.


## Cloud Storage no lugar de HDFS


Vamos falar mais sobre como usar o Google Cloud Storage em vez do sistema de arquivos nativo do Hadoop, o HDFS. 

As velocidades de rede eram lentas. Por isso mantínhamos os dados o mais próximo possível do processador.

Agora, com a rede de petabits, **armazenamento e computação são independentes** e o tráfego move-se rapidamente pela rede. Seus clusters Hadoop locais precisam de armazenamento local no disco, já que o mesmo servidor executa, calcula e armazena os jobs. Essa é uma das primeiras áreas para otimização. É possível executar o HDFS na nuvem elevando e transferindo cargas de trabalho do Hadoop para o Dataproc. Essa é a primeira etapa para a nuvem e não requer alterações de código. Apenas funciona! 

Mas o HDFS na nuvem é uma solução inferior a longo prazo. Isso se deve ao modo como o HDFS funciona nos clusters, com tamanho de bloco, localidade dos dados e replicação dos dados no HDFS.

Para o tamanho do bloco no HDFS, você está vinculando o desempenho de entrada e saída ao hardware onde o servidor está sendo executado. Novamente, o armazenamento não é elástico nesse cenário.

Você está no cluster. Se ficar sem espaço em disco permanente, vai precisar de um redimensionamento, mesmo sem precisar de mais poder computacional. Para localidade de dados, há preocupações semelhantes sobre o armazenamento de dados em discos permanentes individuais. Isso acontece em casos de replicação. Para que o HDFS seja altamente disponível, ele replica três cópias de cada bloco para armazenamento. Seria bom ter uma solução de armazenamento gerenciada separadamente das restrições de seu cluster. 

A rede do Google permite novas soluções para Big Data. A malha de rede Jupiter em um data center do Google oferece mais de um petabit por segundo de largura de banda. Isso é cerca de duas vezes a quantidade de tráfego trocado em toda a Internet pública. Consulte a estimativa anual de tráfego da Internet da Cisco.

Se você desenhar uma linha na rede, a largura de banda bisseccional é a taxa de comunicação na qual os servidores de um lado da linha se comunicam com os servidores do outro lado. Com a largura de banda suficiente, qualquer servidor pode se comunicar com outro em velocidades de rede totais. Com a largura de banda bisseccional petabit, a comunicação é tão rápida que não faz mais sentido transferir arquivos e armazená-los localmente. Em vez disso, faz sentido usar os dados de onde eles estão armazenados.
Dentro de um data center do Google, o nome interno da camada de armazenamento massivamente distribuído é Colossus, e a rede dentro do data center é Jupiter. Os clusters do Dataproc têm a vantagem de aumentar e diminuir as VMs de que precisam enquanto transferem as necessidades de armazenamento permanente com a rede Jupiter ultrarrápida para produtos como o Cloud Storage, que é controlado pelo Colossus nos bastidores. 

Veja uma sequência histórica de gerenciamento de dados a seguir.

Antes de 2006, Big Data significava grandes bancos de dados. O design do banco de dados surgiu quando o armazenamento era barato e o processamento era caro. Por volta de 2006, o processamento distribuído de Big Data ficou prático com o Hadoop. 

Por volta de 2010, foi lançado o BigQuery, o primeiro de muitos serviços de Big Data desenvolvidos pelo Google. Por volta de 2015, o Google lançou o Dataproc, que fornece um serviço gerenciado para criar clusters Hadoop e Spark e gerenciar o processamento de dados. Um dos maiores benefícios do Hadoop na nuvem é a separação entre computação e armazenamento.

Com o Cloud Storage como back-end, é possível tratar os próprios clusters como recursos efêmeros. Você só paga pela capacidade de computação quando está executando algum job. Além disso, o Cloud Storage é o serviço de armazenamento escalonável e durável, conectado a muitos outros projetos do Google Cloud. Ele pode ser um substituto imediato para seu back-end HDFS para Hadoop. O resto do seu código funcionaria. Também é possível usar o conector do Cloud Storage manualmente em seus clusters Hadoop fora da nuvem, se ainda não quiser migrar todo o cluster para a nuvem. 

Com o HDFS, é preciso provisionar em excesso os dados atuais e os dados que possa ter e usar o disco permanente por toda parte. Com o Cloud Storage, você paga exatamente pelo que precisa ao usá-lo. 

O Cloud Storage é otimizado para grandes operações paralelas em massa. Ele tem uma taxa de transferência muito alta, mas uma latência significativa. Se você tiver jobs grandes que executam vários blocos pequenos, pode ser melhor usar o HDFS. Além disso, convém evitar iterar sequencialmente em muitos diretórios aninhados em um único job. 

O uso do Cloud Storage em vez do HDFS oferece benefícios importantes devido ao serviço distribuído, incluindo a eliminação de gargalos e pontos únicos de falha.

No entanto, há algumas desvantagens, incluindo os desafios apresentados pela renomeação de objetos e a incapacidade de anexar a objetos. O Cloud Storage é, na essência, um armazenamento de objetos. Ele apenas simula um diretório de arquivos. Portanto, as renomeações de diretório no HDFS não são as mesmas do Cloud Storage, mas novos autores de commit de saída orientados ao armazenamento atenuam isso, como você vê aqui. 

O DistCp é uma ferramenta essencial para mover dados. Recomendamos usar um modelo baseado em push para dados que você sabe que vai precisar. O modelo baseado em pull pode ser útil se há muitos dados que talvez você nunca precise migrar.

**Rever questão da renomeação de diretório no Cloud Storage e DistCP, Push/pulls (??)**



## Como otimizar o Dataproc

1.  Onde estão seus dados e onde está seu cluster? 

- Garanta que a região de seus dados e a zona de seu cluster estejam fisicamente próximas
- Se a zona for omitida na criação do cluster será alocada automaticamente e pode não ser a mesma dos dados.



2. Seu tráfego de rede está sendo afunilado?

- Verifique regras ou rotas de rede que afunilem o tráfego do Cloud Storage por um pequeno número de gateways de VPN antes de chegar ao cluster.
- Evitar gargalos na configuração de rede do Google Cloud.

3. São quantos arquivos de entrada e partições do Hadoop? 

- Acima de 10 mil arquivos de entrada --> Combinar ou unir os dados em tamanhos de arquivo maiores.
- Se mesmo assim tiver grandes conjuntos de dados maiores que aproximadamente 50 mil partições do Hadoop --> ajustar a configuração fs.gs.block.size para um valor maior de acordo.

4. O tamanho do disco permanente limita a taxa de transferência? 

- Um disco permanente para uma quantidade pequena de dados limitará seu desempenho por que escalona linearmente com o tamanho do volume.

5. Você alocou VMs suficientes para seu cluster? 

- Entender as cargas de trabalho é importante para saber o tamanho do cluster.
- Protótipos e comparações com dados e jobs reais é para estimar a alocação de VMs, que podem ser redimendionados conforme necessidade do escopo do job.

## Otimizar o Armazenamento do Dataproc



Em algumas condições o HDFS local tem vantagem:

- Os jobs exigem muitas operações de metadados. Ex: milhares de partições e diretórios, com tamanho de arquivo pequeno.

- Dados do HDFS modificados com frequência ou renomeação de diretórios. Os objetos do Cloud Storage são imutáveis e renomear um diretório é algo trabalhoso porque consiste em copiar todos os objetos para uma nova chave e excluí-los posteriormente. 

- Você usa muito a operação de acréscimo(append) em arquivos HDFS. 

- As cargas de trabalho envolvem I/O pesado. Ex: muitas gravações particionadas.

- Cargas de trabalho de I/O especialmente sensíveis à latência. Ex: você precisa de latência de um dígito e milissegundos por operação de armazenamento.



Em geral, recomenda-se usar o Cloud Storage como fonte de dados **inicial e final** em um pipeline de Big Data. 
	- Ex: se um fluxo de trabalho contém cinco jobs do Spark em série, o primeiro job recupera os dados iniciais do Cloud Storage e grava os dados aleatórios e a saída do job intermediário no HDFS. O job final do Spark grava os resultados no Cloud Storage. 


Dataproc + Cloud Storage permite reduzir os requisitos de disco e economizar custos colocando seus dados lá em vez de no HDFS. -->  discos menores para o cluster.
Separar o armazenamento e a computação reduz bastante os custos.
OBS: Mesmo com o armazenamento de dados no Cloud Storage, o cluster do Dataproc precisa de HDFS para determinadas operações, como armazenamento de arquivos de controle e recuperação ou agregação de registros. Ele também precisa de espaço em disco local não HDFS para o embaralhamento.

Você pode reduzir o tamanho do disco por worker se não usar muito o HDFS local.

**Opções para ajustar o tamanho do HDFS local**: 

- Diminua o tamanho total do HDFS local diminuindo o tamanho dos discos permanentes primários do primário e dos workers. 

	O disco permanente primário contém o volume de inicialização e as bibliotecas do sistema, portanto, aloque pelo menos 100 gigabytes.

- Aumente o tamanho total do HDFS local aumentando o tamanho do disco permanente primário para workers. 
	Considere esta opção com cuidado. É raro ter cargas de trabalho com melhor desempenho usando HDFS com discos permanentes padrão em comparação com o uso do Cloud Storage ou HDFS local com SSD. Anexe até oito SSDs a cada worker e use esses discos para o HDFS. Essa é uma boa opção se você precisa usar o HDFS para cargas com muitas E/Ss e precisa de latência de um dígito de milissegundos. Use um tipo de máquina que tenha CPUs e memória no worker para comportar os discos E use discos permanentes SSD para seu primário ou workers como um disco primário.
	
- Impacto da geografia e das regiões nos dados e jobs.

	A latência das solicitações pode aumentar quando elas são feitas de uma região diferente daquela onde os recursos estão armazenados.
	Além disso, se os recursos dos serviços e seus dados permanentes estiverem em regiões diferentes, chamadas para serviços do Google Cloud poderão copiar todos os dados necessários de uma zona para outra antes do processamento (!!!). Isso pode ter um impacto severo no desempenho.
	

Além do armazenamento no Cloud Storage, alguns dados podem ser mais adequados para armazenamento em produtos projetados explicitamente para Big Data:

- Cloud Bigtable para armazenar muitos dados **esparsos** - API compatível com HBase que oferece baixa latência e alta escalonabilidade para se adaptar aos seus jobs. 
- BigQuery para Datawharehouse. 

- Replicar um cluster local do Hadoop em um cluster permanente do Dataproc, apesar de parecer a solução mais fácil **não é uma boa ideia**:

- Manter seus dados em um cluster HDFS permanente usando o Dataproc é mais caro do que armazenar seus dados no Cloud Storage

- Limita a integração com outros serviços do Google Cloud

**modelo efêmero**: Clusters pequenos, de curta duração e projetados para jobs específicos, ao invés de um grande cluster permanente e  multifuncional.

Usar um único cluster permanente do Dataproc para seus jobs é mais difícil de gerenciar do que mudar para clusters direcionados
05:31
que atendem jobs individuais ou áreas do job. A maneira mais econômica e flexível de migrar seu sistema Hadoop para o Google Cloud é deixar de pensar em clusters permanentes grandes e multifuncionais
05:46
e, em vez disso, pensar em clusters pequenos e de curta duração projetados para executar jobs específicos.

**Exclusão programada** . Um cronômetro pode marcar o tempo após o cluster entrar em um estado ocioso. Com um carimbo de data/hora, a contagem começa assim que a expiração for definida. É possível definir uma duração, o tempo em segundos para esperar antes de desligar automaticamente o cluster. Isso pode variar de no mínimo 10 minutos a no máximo 14 dias com uma granularidade de um segundo. 

## Otimizar modelos e o escalonamento automático do Dataproc


**Dataproc Workflow Template** é um arquivo YAML processado por um gráfico acíclico dirigido, ou DAG e pode:

1. Criar um novo cluster, 
2. Selecionar um cluster existente
3. Enviar jobs
4. Reter o envio de jobs até a conclusão de dependências
5. Excluir um cluster ao final do job.

Ele está disponível pelo comando da **gcloud** e pela **API REST** e não é acessado no console do Cloud (!!!).


O Dataproc Workflow Template se torna ativo quando é instanciado no DAG e pode ser enviado muitas vezes com vários valores de parâmetro.

É possível gravar um modelo in-line no comando da gcloud e listar fluxos de trabalho e metadados para ajudar a diagnosticar problemas.

Ex. de Workflow Template:
```
# the things we need pip-installed on the cluster
STARTUP_SCRIPT=gs://${BUCKET}/sparktobq/startup_script.sh
echo "pip install --upgrade --quiet google-compute-engine google-cloud-storage matplotlib" >
/tmp/startup_script.sh
gsutil cp /tmp/startup_script.sh $STARTUP_SCRIPT
# create new cluster for job
gcloud dataproc workflow-templates set-managed-cluster $TEMPLATE \
 --master-machine-type $MACHINE_TYPE \
 --worker-machine-type $MACHINE_TYPE \
 --initialization-actions $STARTUP_SCRIPT \
 --num-workers 2 \
 --image-version 1.4 \
 --cluster-name $CLUSTER
# steps in job
gcloud dataproc workflow-templates add-job \
 pyspark gs://$BUCKET/spark_analysis.py \
 --step-id create-report \
 --workflow-template $TEMPLATE \
 -- --bucket=$BUCKET


# submit workflow template
gcloud dataproc workflow-templates instantiate $TEMPLATE


```
Comentários:

- Pegamos o que precisa ser instalado no cluster usando scripts de inicialização e ecoando os comandos de instalação do pip, como vimos aqui, para instalar o matplotlib.

- É possível ter vários scripts de shell de inicialização executados.
- Vamos usar o comando da gcloud para criar um cluster antes de executar o job.
- Especificamos parâmetros de cluster como o modelo a ser usado e quais tipos de máquina e versões de imagem queremos.
- Depois precisamos adicionar um job ao cluster recém-criado.
- Aqui temos um job do Spark escrito em Python que existe em um bucket que controlamos.
- Por fim, precisamos enviar este modelo como um novo modelo de fluxo de trabalho.


**Escalonamento automático** fornece clusters que se adaptam às necessidades da empresa --> Os jobs não precisam de acompanhamento.
- Não há necessidade de intervir em um cluster fora da capacidade.
- É possível escolher entre workers padrão e preemptivos e economizar recursos, cotas e custos a qualquer momento.
- Políticas de escalonamento automático trazem controle e se baseiam na diferença entre a memória pendente e a disponível do YARN.
- Se precisar de mais memória, escalone verticalmente.
- Se precisar de menos, reduza a escala.
- Obedeça aos limites da VM e use o fator de escalonamento.

O escalonamento automático traz estas melhorias: 
- Controles ainda mais refinados.
	- As políticas podem ser modificadas a qualquer momento.
	- O intervalo mínimo de escalonamento mudou de 10 para 2 minutos.
	- Elas podem ser compartilhadas entre vários clusters.
- Está mais fácil entender o escalonamento.
	- Os painéis YARN e HDFS podem ser visualizados na página do cluster, e o histórico de decisões está disponível no Cloud Logging.
- A estabilidade é fornecida pela capacidade de escalonar jobs do MapReduce e do Spark sem perder o progresso.

O escalonamento oferece capacidade flexível para uma utilização mais eficiente, com decisões baseadas em métricas do **Hadoop YARN**.

- Ele deve ser usado com dados permanentes fora do cluster, não HDFS ou HBase no cluster.
- Funciona melhor com clusters que processam muitos jobs ou que processam um único job grande.
- Ele não é compatível com o Structured Streaming, um serviço criado com base no Spark SQL.
- Ele não pode ser escalonado para zero e não é bom para clusters sem uso.
	- Nesses casos, é igualmente rápido encerrar um cluster que está ocioso e criar um novo quando necessário --> Melhor usar **workflow** do Dataproc ou do Cloud Composer e a **exclusão programada**.

Ao trabalhar com escalonamento automático,é importante considerar a definição inicial de workers "**nodes minimum**" --> O cluster vai atingir a capacidade básica mais rapidamente do que com o escalonamento automático.
	
O máximo limita o número de nós de trabalho --> Se houver uma carga pesada no cluster, vai haver **escalonamento vertical**.

O escalonamento automático pode exigir vários **períodos de escalonamento**: scale-up factor, cooldown period e scale-down factor.
 
Um número mínimo secundário e um número máximo controlam a escala de workers preemptivos.