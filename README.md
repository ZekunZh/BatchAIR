# Deep Learning with R on Azure Batch AI

Examples of how to use Azure Batch AI for deep learning models implemented in Keras for R. Examples include:

- distributed hyperparameter tuning
- distributed batch scoring (to follow)
- distributed training (to follow)

## Pre-requisites

You will need the following to run these examples:
- an [Azure subscription](https://azure.microsoft.com/en-gb/free/search/?OCID=AID631183_SEM_6SWb2WFu&dclid=CJuhw5yo4tsCFZFh0wodQ3oLEg)

## Setup instructions

### 1. Create DLVM

Follow these instructions to create an [Ubuntu Data Learning Virtual Machine](https://azuremarketplace.microsoft.com/marketplace/apps/microsoft-ads.dsvm-deep-learning. This VM image comes with several pre-requisites pre-installed including Azure CLI, Azure Python SDK, docker, R, Anaconda, Keras and Tensorflow.

- Go to the Azure [portal](https://ms.portal.azure.com/)

- Click *Create a resource* and search for Deep Learning Virtual Machine

- Provision a Linux DLVM in East US region

### 2. Setup BatchAI Cluster

- In the DLVM terminal:
 

### 2. Create BatchAI resources
- Login to Azure
```
az login
```
- List subscriptions
```
az account list -o table
```
- Set subscription
```
az account set --subscription "<subscription-name>"
```
- Create storage account
```
az storage account create -n batchairsa --sku Standard_LRS -g batchair -l eastus
```
- Create file share for scripts
```
az storage share create -n scripts --account-name batchairsa
az storage directory create -n R -s scripts --account-name batchairsa
```
- Create file share for logs
```
az storage share create -n logs --account-name batchairsa
```
- Upload training script to file share
```
az storage file upload -s scripts --source R/mnist_cnn.R --path R --account-name batchairsa
```
- Create Batch AI workspace and experiment
```
az batchai workspace create -l eastus -g <rg-name> -n <workspace-name>
az batchai experiment create -g batchair -w batchairws -n experiment1
```
- Create a Batch AI cluster, specifying te admin username and password for each cluster VM, setting the VM image and size and the number of minimum and maximum number of nodes (for cluster auto-scaling).
    ```
    az batchai cluster create -g batchair -w batchairws -n batchaircluster --user-name <user> --password <password> --image UbuntuLTS --vm-size Standard_NC6 --max 4 --min 4
    ```
Note: you eed to check that you have enough cores quota for your VM size. To check this, go to the Azure portal and search for *Batch AI* in *All services*. Look at your core quotas for your subscription and region in *Usage + quotas*.
- Submit job on cluster
```
az batchai job create -c batchaircluster -n test1 -g batchair -w batchairws -e experiment1 -f job.json --storage-account-name batchairsa
```

### 2. Prepare docker image
```
##### Optional
If you want to execute docker without having to sudo each time then you need to run the following:
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```
You may need to log out and log back in again for changes to take effect. Instructions from https://docs.docker.com/engine/installation/linux/linux-postinstall/#manage-docker-as-a-non-root-user

- Build the docker image:
```
cd batchair/docker/cpu
docker build -t batchair .
```
- If you need to adapt the docker image, make the required changes and rebuild. Upload to your own docker hub account with
```
docker login
```
- Test docker image with an interactive session with
```
docker run -it -v $(pwd)/R:/scripts batchair /bin/bash
```





- Download the mnist dataset
```
CID="$(docker run -dit -v $(pwd)/R:/scripts angusrtaylor/batchair /bin/bash)"
docker exec ${CID} Rscript --vanilla scripts/get_mnist.R
docker cp ${CID}:mnist.rds $(pwd)/mnist/
docker stop ${CID}
docker rm ${CID}
```


## Useful links

- [BatchAI github](https://github.com/Azure/BatchAI)
- [RStudio Keras](https://keras.rstudio.com/index.html)
- [Installing Docker on Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/#supported-storage-drivers)