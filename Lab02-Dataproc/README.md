# Preparação para PDE: operação e manutenção de clusters do Cloud Dataproc

Conhecimentos avaliados:

- Criar um cluster com acesso a um bucket de preparação do Cloud Storage

- Executar jobs do PySpark com argumentos de entrada

- Fazer upgrade da configuração do nó mestre em um cluster existente

- Resolver um problema de desempenho de capacidade do cluster

- Fazer upgrade do número de nós de trabalho em um cluster

## Cenário do desafio
Agora você trabalha com engenharia de dados na empresa MJTelco. Parabéns pelo novo emprego!

A equipe de cientistas de dados da MJTelco pretende transferir um aplicativo de machine learning preditivo para um cluster do Cloud Dataproc. O aplicativo é escrito em Python e executado no Spark. O app leva muito tempo para ser executado, mesmo com dados de amostra. Por isso, os cientistas de dados criaram uma referência executando um programa no data center. Eles tentaram executar a referência em um cluster do Cloud Dataproc, mas está demorando mais do que o planejado. Sua tarefa é executar o programa de referência no Cloud Dataproc e fazer ajustes na configuração do cluster para atender aos requisitos dos cientistas.

Observação: o programa de referência é um aplicativo PySpark. Ele calcula o valor de PI. O valor de entrada determina quantas iterações são usadas no cálculo.

## Requisitos
Se o programa de referência receber um valor de entrada 220, e caso o job seja concluído em menos de 75 segundos, os requisitos serão atendidos.

Assim, quando o programa de referência for enviado com o valor de entrada 20, o job será concluído em menos de 75 segundos. Quando ele é enviado com o valor de entrada 220 obrigatório, o job leva cerca de 2 minutos para ser executado, o que não atende ao requisito.

### Tarefa 1: prepare o aplicativo PySpark de referência

Crie um bucket do Cloud Storage para seu cluster do Cloud Dataproc. Dê ao bucket o mesmo nome do projeto. Copie o aplicativo Python Spark de referência para o bucket do projeto.

O aplicativo foi compartilhado com você em um bucket do Cloud Storage: gs://cloud-training/preppde/benchmark.py

### Tarefa 2: crie um cluster do Cloud Dataproc com as mesmas configurações usadas pelo analista de dados
Os cientistas de dados estão usando um cluster mínimo do Cloud Dataproc que consiste em um nó mestre e dois nós de trabalho. Todas as instâncias são do tipo n1-standard-2.

Crie um cluster do Cloud Dataproc chamado mjtelco usando a versão 2.0 (Debian 10, Hadoop 3.2, Spark 3.1) com um nó mestre n1-standard-2 e dois nós de trabalho n1-standard-2 na região us-central1 e na zona us-central1-a. Nas outras configurações, use o padrão.

### Tarefa 3: demonstre o job de referência executado corretamente sem o valor de entrada obrigatório
Envie o job em Python ao cluster e dê a ele o nome mjtelco-test-1. Defina o argumento de entrada do job com o valor 20. Em Máximo de reinicializações por hora, digite 1.

O job deve levar menos de 75 segundos para ser executado com sucesso.

### Tarefa 3: demonstre o job de referência executado corretamente sem o valor de entrada obrigatório
Envie o job em Python ao cluster e dê a ele o nome mjtelco-test-1. Defina o argumento de entrada do job com o valor 20. Em Máximo de reinicializações por hora, digite 1.

O job deve levar menos de 75 segundos para ser executado com sucesso.


### Tarefa 5: faça upgrade do nó mestre

Sua segunda tarefa é melhorar o desempenho do cluster e reduzir o tempo necessário para executar o job de referência.

Atualize o nó mestre para uma instância de quatro CPUs, n1-standard-4.

### Tarefa 6: demonstre que o job de referência é concluído em menos tempo
Quando o nó mestre atualizado estiver em execução, envie o job em Python novamente ao cluster. Dê ao job o nome de mjtelco-test-3. Defina o argumento de entrada do job com o valor 220. Em Máximo de reinicializações por hora, digite 1.

O job deve levar cerca de 2 minutos para ser executado com sucesso.

### Tarefa 7: amplie o cluster
Você está chegando perto, mas o job ainda não está sendo concluído dentro do tempo necessário (menos de 75 segundos) quando recebe o valor de entrada 220.

Adicione mais três nós de trabalho n1-standard-2 para fazer upgrade do cluster para um total de cinco nós de trabalho.

### Tarefa 8: envie o job e verifique se o desempenho está melhor
Quando os nós adicionais estiverem em execução, envie o job novamente. Envie o job Python ao cluster e dê a ele o nome mjtelco-test-4. Defina o argumento de entrada do job com o valor 220. Em Máximo de reinicializações por hora, digite 1.

O job de referência será concluído no tempo necessário (menos de 75 segundos).

## Solução:

### Tarefa 1: