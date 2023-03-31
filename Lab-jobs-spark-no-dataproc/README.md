# LAB - Como executar jobs do Apache Spark no Cloud Dataproc

### Visão geral
Neste laboratório, você aprenderá a migrar código do Apache Spark para o Cloud Dataproc. Você seguirá uma sequência de etapas, movendo cada vez mais componentes do job para os serviços do GCP:

- Executar o código original do Spark no Cloud Dataproc (migração lift-and-shift)

- Substituir o HDFS pelo Google Cloud Storage (nativo da nuvem)

- Automatizar tudo para executar em clusters específicos dos jobs (otimizado para a nuvem)

### Objetivos
Neste laboratório, você aprenderá o seguinte:

- Migrar jobs do Spark para o Cloud Dataproc

- Modificar jobs do Spark para usar o Cloud Storage em vez do HDFS

- Otimizar jobs do Spark para executar em clusters específicos

**O que você usará?**

- Cloud Dataproc

- Apache Spark

### Cenário

Você está migrando uma carga de trabalho do Spark para o Cloud Dataproc e modificando o código aos poucos para aproveitar os recursos e os serviços nativos do GCP.

## Parte 1: migração lift-and-shift

### Migre jobs do Spark para o Cloud Dataproc

Você criará um cluster do Cloud Dataproc. Depois, executará um notebook do Jupyter importado que usa o Sistema de Arquivos Distribuído do Hadoop (HDFS, na sigla em inglês) padrão do cluster para armazenar os dados de origem. Por fim, você processará esses dados como faria em qualquer cluster do Hadoop, usando o Spark. A atividade demonstra que é possível migrar muitas cargas de trabalho de análise que contêm código do Spark, como os notebooks do Jupyter, para um ambiente do Cloud Dataproc sem alterações.

### Configure e inicie um cluster do Cloud Dataproc
1. No Console do GCP, no menu de navegação, na seção Big Data, clique em Dataproc.

2. Clique em Criar cluster.

3. Digite sparktodp em Nome do Cluster.

4. Na seção Controle de Versões, clique em Alterar e selecione 2.0 (Debian 10, Hadoop 3.2, Spark 3.1).

Essa versão inclui Python3, que é necessário para o código de amostra usado no laboratório.

5. Clique em Selecionar.

6. Na seção Componentes > Gateway de componente, selecione Ativar gateway de componente.

7. Em Componentes opcionais, selecione Jupyter Notebook.

8. Clique em Criar.

### Clone o repositório de origem do laboratório

No Cloud Shell, você clona o repositório Git do laboratório e copia os arquivos necessários para o intervalo do Google Cloud Storage que o Cloud Dataproc usa como o diretório inicial dos notebooks do Jupyter.

1. Para clonar o repositório do Git do laboratório, digite este comando no Cloud Shell:

`git -C ~ clone https://github.com/GoogleCloudPlatform/training-data-analyst`

2. Para localizar o intervalo padrão do Google Cloud Storage que o Cloud Dataproc usa, digite este comando no Cloud Shell:

```
export DP_STORAGE="gs://$(gcloud dataproc clusters describe sparktodp --region=us-central1 --format=json | jq -r '.config.configBucket')"
```

3. Para copiar os notebooks de amostra para a pasta de trabalho do Jupyter, digite este comando no Cloud Shell:
```
gsutil -m cp ~/training-data-analyst/quests/sparktobq/*.ipynb $DP_STORAGE/notebooks/jupyter
```

### Faça login no notebook do Jupyter

Você já pode acessar as interfaces da Web assim que o cluster terminar de iniciar. Clique no botão "Atualizar" para verificar se a implantação já terminou neste estágio.

1. Na página "Clusters" do Dataproc, aguarde até que seu cluster termine de iniciar e clique no nome dele para abrir a página Detalhes do cluster.

2. Clique em Interfaces da Web.

3. Clique no link Jupyter para abrir uma nova guia do Jupyter no navegador.

A página inicial do Jupyter será aberta. Aqui você vê o conteúdo do diretório /notebooks/jupyter no Google Storage, que agora inclui os notebooks do Jupyter de amostra usados no laboratório.

4. Na guia Files, clique na pasta GCS e, em seguida clique em 01_spark.ipynb notebook para abri-lo.

5. Clique em Cell e em Run All para executar todas as células no notebook.

6. Use Page Up para voltar ao começo do notebook. Acompanhe a execução de cada célula e as respostas que aparecem abaixo delas.

Você pode mover pelas células e examinar o código que está sendo processado, para ver o que o notebook está fazendo. Preste atenção especialmente ao local em que os dados são salvos e processados.

A primeira célula de código recupera o arquivo de dados de origem, que é um trecho da conferência KDD Cup competition from the Knowledge, Discovery, and Data (KDD) de 1999. Os dados são relacionados a eventos de detecção de invasões de computador.

```
!wget https://archive.ics.uci.edu/ml/machine-learning-databases/kddcup99-mld/kddcup.data_10_percent.gz
```

Na segunda célula de código, os dados de origem são copiados para o sistema de arquivos padrão do Hadoop (local).
```
!hadoop fs -put kddcup* /
```
Na terceira célula de código, o comando mostra o conteúdo do diretório padrão do sistema de arquivos HDFS no cluster.
```
!hadoop fs -ls /
```
### Leia os dados

Os dados são arquivos CSV no formato gzip. No Spark, podemos ler esses arquivos diretamente usando o método textFile e dividir cada linha com vírgulas para fazer a análise.

O código em Python do Spark começa na célula In[4]. O código desta célula inicializa o Spark SQL, usa o Spark para ler os dados de origem como texto e retorna as cinco primeiras linhas.
```
from pyspark.sql import SparkSession, SQLContext, Row
spark = SparkSession.builder.appName("kdd").getOrCreate()
sc = spark.sparkContext
data_file = "hdfs:///kddcup.data_10_percent.gz"
raw_rdd = sc.textFile(data_file).cache()
raw_rdd.take(5)
```
O código da célula In [5] divide cada linha usando , como delimitador e, depois, as analisa usando um esquema inline preparado no código.
```
csv_rdd = raw_rdd.map(lambda row: row.split(","))
parsed_rdd = csv_rdd.map(lambda r: Row(
    duration=int(r[0]),
    protocol_type=r[1],
    service=r[2],
    flag=r[3],
    src_bytes=int(r[4]),
    dst_bytes=int(r[5]),
    wrong_fragment=int(r[7]),
    urgent=int(r[8]),
    hot=int(r[9]),
    num_failed_logins=int(r[10]),
    num_compromised=int(r[12]),
    su_attempted=r[14],
    num_root=int(r[15]),
    num_file_creations=int(r[16]),
    label=r[-1]
    )
)
parsed_rdd.take(5)
```
### Análise do Spark
O código da célula In [6] cria um contexto do Spark SQL e, depois, cria um DataFrame do Spark usando esse contexto e os dados de entrada analisados na etapa anterior. Para selecionar e exibir os dados das linhas, use o método .show() do DataFrame para gerar uma visualização que resume uma contagem dos campos selecionados.
```
sqlContext = SQLContext(sc)
df = sqlContext.createDataFrame(parsed_rdd)
connections_by_protocol = df.groupBy('protocol_type').count().orderBy('count', ascending=False)
connections_by_protocol.show()
```
O método .show() produz uma tabela semelhante a esta:

+-------------+------+
|protocol_type| count|
+-------------+------+
|         icmp|283602|
|          tcp|190065|
|          udp| 20354|
+-------------+------+


Também é possível usar o SparkSQL para consultar os dados analisados armazenados no DataFrame. O código da célula In [7] registra uma tabela temporária (connections) e se refere a ela na consulta SparkSQL posterior.
```
df.registerTempTable("connections")
attack_stats = sqlContext.sql("""
    SELECT
      protocol_type,
      CASE label
        WHEN 'normal.' THEN 'no attack'
        ELSE 'attack'
      END AS state,
      COUNT(*) as total_freq,
      ROUND(AVG(src_bytes), 2) as mean_src_bytes,
      ROUND(AVG(dst_bytes), 2) as mean_dst_bytes,
      ROUND(AVG(duration), 2) as mean_duration,
      SUM(num_failed_logins) as total_failed_logins,
      SUM(num_compromised) as total_compromised,
      SUM(num_file_creations) as total_file_creations,
      SUM(su_attempted) as total_root_attempts,
      SUM(num_root) as total_root_acceses
    FROM connections
    GROUP BY protocol_type, state
    ORDER BY 3 DESC
    """)
attack_stats.show()
```
Quando a consulta terminar, você verá uma resposta semelhante a este exemplo resumido:

+-------------+---------+----------+--------------+--
|protocol_type|    state|total_freq|mean_src_bytes|
+-------------+---------+----------+--------------+--
|         icmp|   attack|    282314|        932.14|
|          tcp|   attack|    113252|       9880.38|
|          tcp|no attack|     76813|       1439.31|
...
...
|          udp|   attack|      1177|          27.5|
+-------------+---------+----------+--------------+--

Agora você também pode exibir esses dados visualmente usando gráficos de barras.

O código da última célula, In [8], usa a função mágica do Jupyter %matplotlib inline para redirecionar matplotlib para renderizar uma figura inline no notebook, em vez de apenas jogar os dados em uma variável. Essa célula exibe o gráfico de barras usando a consulta attack_stats da etapa anterior.
```
%matplotlib inline
ax = attack_stats.toPandas().plot.bar(x='protocol_type', subplots=True, figsize=(10,25))
```
Depois da execução de todas as células no notebook, a primeira parte da resposta será semelhante ao gráfico abaixo. Role para baixo no seu notebook para ver o gráfico completo.

## Parte 2: separe a computação e o armazenamento

### Modifique jobs do Spark para usar o Cloud Storage em vez do HDFS

Usando este notebook de amostra de "migração lift-and-shift" original, você criará agora uma cópia que separa os requisitos de armazenamento do job dos requisitos de computação. Neste caso, basta substituir as chamadas ao sistema de arquivos do Hadoop por chamadas ao Google Storage. Para isso, você substitui as referências a hdfs:// por referências a gs:// no código e faz as mudanças necessárias nos nomes das pastas.

Para começar, você usa o Cloud Shell para colocar uma cópia dos dados de origem em um novo intervalo do Cloud Storage.

1. No Cloud Shell, crie um intervalo de armazenamento para os dados de origem
```
export PROJECT_ID=$(gcloud info --format='value(config.project)')
gsutil mb gs://$PROJECT_ID
```
2. No Cloud Shell, copie os dados de origem para o intervalo.
```
wget https://archive.ics.uci.edu/ml/machine-learning-databases/kddcup99-mld/kddcup.data_10_percent.gz
gsutil cp kddcup.data_10_percent.gz gs://$PROJECT_ID/
```
Aguarde até o comando anterior terminar e o arquivo ser copiado para o novo intervalo.

3. Volte à guia do notebook do Jupyter 01_spark no navegador.

4. Clique em File e em Make a Copy.

5. Quando a cópia abrir, clique no título 01_spark-Copy1 e altere o nome para De-couple-storage.

6. Abra a guia do Jupyter do notebook 01_spark.

7. Clique em File e em Save and checkpoint para salvar o notebook.

8. Clique em File e em Close and Halt para fechar o notebook.

Se for solicitado, clique em Leave ou em Cancel para confirmar.

9. Volte à guia do notebook do Jupyter De-couple-storage no navegador, se necessário.

Você não precisa mais das células que fazem o download e a cópia dos dados para o sistema de arquivos HDFS interno do cluster, então remova essas células.

Para excluir uma célula, clique nela e depois clique no ícone cut selected cells (símbolo de tesoura) na barra de ferramentas do notebook.

10. Exclua as células de comentário iniciais e as três primeiras células de código ( In [1], In [2] e In [3]) para que o notebook comece com a seção Reading in Data.

Agora você altera o código da primeira célula, que define o local de origem e lê os dados de origem. Ela ainda se chama In[4], a menos que você tenha executado o notebook novamente. Atualmente a célula contém este código:

from pyspark.sql import SparkSession, SQLContext, Row
spark = SparkSession.builder.appName("kdd").getOrCreate()
sc = spark.sparkContext
data_file = "hdfs:///kddcup.data_10_percent.gz"
raw_rdd = sc.textFile(data_file).cache()
raw_rdd.take(5)

11. Substitua o conteúdo da célula In [4] pelo código abaixo. A única alteração aqui é criar a variável para armazenar o nome de um intervalo do Google Cloud Storage e apontar data_file para o intervalo que usamos para armazenar os dados de origem.

from pyspark.sql import SparkSession, SQLContext, Row
gcs_bucket='[Your-Bucket-Name]'
spark = SparkSession.builder.appName("kdd").getOrCreate()
sc = spark.sparkContext
data_file = "gs://"+gcs_bucket+"//kddcup.data_10_percent.gz"
raw_rdd = sc.textFile(data_file).cache()
raw_rdd.take(5)

Depois que você substituir o código, a primeira célula ficará semelhante à imagem abaixo, com o ID do seu projeto do laboratório como o nome do intervalo:

[]

12. Na célula que você atualizou, substitua o espaço reservado [Your-Bucket-Name] pelo nome do intervalo de armazenamento que você criou na primeira etapa desta seção. Você criou esse intervalo usando o ID do projeto como nome. Esse ID aparece aqui no painel de informações de login do laboratório, no lado esquerdo. Substitua todo o texto do espaço reservado, inclusive os colchetes [].
13. Clique em Cell e em Run All para executar todas as células no notebook.

Você verá exatamente a mesma resposta de quando o arquivo foi carregado e executado no armazenamento de cluster interno. Para mover os arquivos de dados de origem para o Google Cloud Storage, basta alterar as referências à origem de hdfs:// para gs://.

## Parte 3: implante jobs do Spark
### Otimize jobs do Spark para execução em clusters específicos

Agora, você criará um arquivo Python independente para implantação como um job do Cloud Dataproc. Ele fará as mesmas funções deste notebook. Para isso, você adiciona comandos mágicos às células do Python em uma cópia deste notebook para gravar o conteúdo das células em um arquivo. Você também adiciona um manipulador de parâmetros de entrada para definir o local do intervalo de armazenamento quando o script em Python é chamado. Isso facilita a portabilidade do código.

1. No menu De-couple-storage Jupyter Notebook, clique em File e selecione Make a Copy.

2. Quando a cópia abrir, clique em De-couple-storage-Copy1 e altere o nome para PySpark-analysis-file.

3. Abra a guia do Jupyter de De-couple-storage.

4. Clique em File e em Save and checkpoint para salvar o notebook.

5. Clique em File e em Close and Halt para fechar o notebook.

Se for solicitado, clique em Leave ou em Cancel para confirmar.

6. Volte à guia do notebook do Jupyter PySpark-analysis-file no navegador, se necessário.

7. Clique na primeira célula na parte superior do notebook.

8. Clique em Insert e selecione Insert Cell Above.

9. Cole o código abaixo na primeira célula de código nova. Ele importa a biblioteca e faz a manipulação dos parâmetros.

%%writefile spark_analysis.py
import matplotlib
matplotlib.use('agg')
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--bucket", help="bucket for input and output")
args = parser.parse_args()
BUCKET = args.bucket

O comando mágico do Jupyter %%writefile spark_analysis.py cria um novo arquivo de resposta para conter o script independente do Python. Você adiciona uma variação dele às demais células para adicionar o conteúdo de cada uma ao arquivo de script.

O código também importa o módulo matplotlib e define explicitamente o back-end de plotagem padrão por meio de matplotlib.use('agg'), para que o código de plotagem seja executado fora de um notebook do Jupyter.

10. No início das demais células de código Python, digite %%writefile -a spark_analysis.py. Elas são as cinco células com o rótulo In [x].

%%writefile -a spark_analysis.py

Por exemplo, a próxima célula deverá ficar como o código abaixo.

%%writefile -a spark_analysis.py
from pyspark.sql import SparkSession, SQLContext, Row
spark = SparkSession.builder.appName("kdd").getOrCreate()
sc = spark.sparkContext
data_file = "gs://{}/kddcup.data_10_percent.gz".format(BUCKET)
raw_rdd = sc.textFile(data_file).cache()
#raw_rdd.take(5)

11. Repita esta etapa digitando %%writefile -a spark_analysis.py no início de cada célula de código até você chegar ao final.

12. Na última célula, onde o gráfico de barras do Pandas é plotado, remova o comando mágico %matplotlib inline.

Observação: se você não remover essa diretiva mágica do Jupyter inline matplotlib, seu script falhará quando você o executar.

13. Selecione a última célula de código no notebook e, na barra de menu, clique em Insert e em Insert Cell Below.

14. Cole o código abaixo na célula nova.

%%writefile -a spark_analysis.py
ax[0].get_figure().savefig('report.png');

15. Adicione outra célula ao final do notebook e cole este código:

%%writefile -a spark_analysis.py
import google.cloud.storage as gcs
bucket = gcs.Client().get_bucket(BUCKET)
for blob in bucket.list_blobs(prefix='sparktodp/'):
    blob.delete()
bucket.blob('sparktodp/report.png').upload_from_filename('report.png')
16. Adicione uma célula ao final do notebook e cole este código:

%%writefile -a spark_analysis.py
connections_by_protocol.write.format("csv").mode("overwrite").save(
    "gs://{}/sparktodp/connections_by_protocol".format(BUCKET))

### Teste a automação





OBSERVÇÕES:

- Gateway de componente? O que é? 
	- É o acesso à interface Web dos componentes do Dataproc, ex: YARN e o Jupyter
- Não criou o cluster por excesso de quota de CPUs -> Mudei os workers node para n2-standard-2
- O Google está me derrubando acusando de não seguir o lab (??) -> Vou tentar criar com N1-standard-2 --> Funcionou


no cluster só aparece o último job, criado pelo script

No YARN aparecem todos os 4 jobs

cloudshell download spark_analysis.py submit_onejob.sh