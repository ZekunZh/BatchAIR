# Deep Learning with R on Azure Batch AI

An example of how to use Azure [Batch AI](https://azure.microsoft.com/services/batch-ai/) to perform distributed hyperparameter tuning of a model implemented in [Keras for R](https://keras.rstudio.com/).

The example adapts the mnist_cnn.R example script to test different network structures. An R script defines the set of hyperparameters to be tested and generates a series of job configuration files to be run on a Batch AI cluster. The script runs a triggers a Batch AI job for each hyperparameter set through the Azure CLI before retrieving the output from each job and identifying the optimum hyperparameter set.

## Pre-requisites

You will need the following to run these examples:
- an [Azure subscription](https://azure.microsoft.com/en-gb/free/search/?OCID=AID631183_SEM_6SWb2WFu&dclid=CJuhw5yo4tsCFZFh0wodQ3oLEg)
- an Ubuntu Server 16.04 LTS Virtual Machine or an Ubuntu Data Science Virtual Machine (search for these the [Azure portal](https://portal.azure.com/))
- [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#supported-storage-drivers) (this is already installed on the DSVM)
- [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) if your VM has GPU attached (already installed on GPU-enabled DSVMs)

## Setup instructions

### 1. Clone repository
- ssh into the Ubuntu VM and clone the repository


    ```
    git clone https://github.com/angusrtaylor/BatchAIR.git
    cd BatchAIR
    ```

### 2. Pull docker image

- Pull the docker image

    ```
    docker pull angusrtaylor/kerasr
    ```
    Note: If your VM has a GPU attached, pull the angusrtaylor/kerasr-gpu image. Replace subsequent docker commands in these instructions with nvidia-docker.

    This image contains all further pre-requisites for these instructions including:

    - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
    - R
    - tensorflow
    - keras (python library)
    - keras (R library)

    ##### Optional
    If you want to execute docker without having to sudo each time then you need to run the following:
    ```bash
    sudo groupadd docker
    sudo usermod -aG docker $USER
    ```
    You may need to log out and log back in again for changes to take effect. Instructions from https://docs.docker.com/engine/installation/linux/linux-postinstall/#manage-docker-as-a-non-root-user


### 2. Create BatchAI resources

- Start a docker container and run a bash session

    ```
    CID="$(docker run -v $(pwd):/BatchAIR -dit kerasr)"
    docker exec -it ${CID} bash
    cd BatchAIR
    ```
- Login to Azure using the Azure CLI
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
- Set resources names (feel free to change these but be sure to adapt the job_template.json file if you do)
    ```
    BATCHAIR_RG=batchai
    BATCHAIR_SA=batchairsa
    BATCHAIR_WS=batchairws
    BATCHAIR_CLUST=batchaicluster
    ```

- Create storage account
    ```
    az storage account create -n ${BATCHAIR_SA} --sku Standard_LRS -g ${BATCHAIR_RG} -l eastus
    ```

    Note: Batch AI is currently only available in select regions. Here we select East US for all resources.

- Create file shares for scripts, dataset, outputs and logs. Upload training script
    ```
    az storage share create -n logs --account-name ${BATCHAIR_RG}
    az storage share create -n resources --account-name ${BATCHAIR_SA}
    az storage share create -n output --account-name ${BATCHAIR_SA}
    az storage directory create -n R -s resources --account-name ${BATCHAIR_SA}
    az storage directory create -n mnist -s resources --account-name ${BATCHAIR_SA}
    az storage file upload -s resources --source R/mnist_cnn.R --path R --account-name ${BATCHAIR_SA}
    ```
- Create Batch AI workspace
    ```
    az batchai workspace create -l eastus -g ${BATCHAIR_RG} -n ${BATCHAIR_WS}
    ```
- Create a Batch AI cluster, specifying te admin username and password for each cluster VM, setting the VM image and size and the number of minimum and maximum number of nodes (for cluster auto-scaling).
    ```
    az batchai cluster create -g ${BATCHAIR_RG} -w ${BATCHAIR_WS} -n ${BATCHAIR_CLUST} --user-name <user> --password <password> --image UbuntuLTS --vm-size Standard_NC6 --max 4 --min 4
    ```
    Note: Examples will run much faster if you use a vm-size that has GPU (such as Standard_NC6).
    
    Also note: you need to check that you have enough cores quota for your VM size. To check this, go to the Azure portal and search for *Batch AI* in *All services*. Look at your core quotas for your subscription and region in *Usage + quotas*.

### 3. Download the MNIST dataset

- Within your running the docker container, run
    ```
    Rscript R/get_mnist.R
    ```
- Upload data set to the file share
    ```
    az storage file upload -s resources --source mnist/mnist.rds --path mnist --account-name ${BATCHAIR_SA}
    ```

### 4. Run the hyperparameter tuning script
- Run the grid_search.R script to perform the hyperparameter tuning
    ```
    Rscript R/grid_search.R --w ${BATCHAIR_WS} --c ${BATCHAIR_CLUST} --e <experiment-name> --g ${BATCHAIR_RG} --s ${BATCHAIR_SA} --gpu TRUE
    ```

    Note: if not using a GPU cluster, set --gpu to FALSE.
    
    Also note: experiment-name must be unique.

## Useful links

- [BatchAI github](https://github.com/Azure/BatchAI)
- [RStudio Keras](https://keras.rstudio.com/index.html)