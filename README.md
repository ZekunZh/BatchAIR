# Deep Learning with R on Azure Batch AI

Examples of how to use Azure Batch AI for deep learning models implemented in Keras for R. Examples include:

- distributed hyperparameter tuning
- distributed batch scoring (to follow)
- distributed training (to follow)

## 1. Pre-requisites

You will need the following to run these examples:
- an [Azure subscription](https://azure.microsoft.com/en-gb/free/search/?OCID=AID631183_SEM_6SWb2WFu&dclid=CJuhw5yo4tsCFZFh0wodQ3oLEg)

## 2. Setup instructions

### 1. Create Azure resources

Follow these instructions to create an [Ubuntu Data Learning Virtual Machine](https://azuremarketplace.microsoft.com/marketplace/apps/microsoft-ads.dsvm-deep-learning. This VM image comes with several pre-requisites pre-installed including Azure CLI, Azure Python SDK, docker, R, Anaconda, Keras and Tensorflow.

- Go to the Azure [portal](https://ms.portal.azure.com/)

- Click *Create a resource* and search for Deep Learning Virtual Machine

- Provision a Linux DLVM in East US region

## 2. Prepare docker image
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

## 3. Setup BatchAI Cluster

- In Cloud Shell, run the following to create a Batch AI workspace:
    ```
    az batchai workspace create -l eastus -g <rg-name> -n <workspace-name>
    ```
- Create a Batch AI cluster, specifying te admin username and password for each cluster VM, setting the VM image and size and the number of minimum and maximum number of nodes (for cluster auto-scaling). Specifying --use-auto-storage sets up NFS and blob storage which are automatically mounted onto each cluster VM.
    ```
    az batchai cluster create -g <rg-name> -w <workspace-name> -n <cluster-name> --user-name <user> --password <password> --image UbuntuLTS --vm-size Standard_NC6 --max 4 --min 4 --use-auto-storage
    ```

Note: you eed to check that you have enough cores quota for your VM size. To check this, go to the Azure portal and search for *Batch AI* in *All services*. Look at your core quotas for your subscription and region in *Usage + quotas*.


## Useful links

- [BatchAI github](https://github.com/Azure/BatchAI)
- [RStudio Keras](https://keras.rstudio.com/index.html)
- [Installing Docker on Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/#supported-storage-drivers)