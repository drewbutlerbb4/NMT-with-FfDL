# Deploying OpenNMT using Fabric for Deep Learning

### Prerequisites

* `S3 CLI`: The [command-line interface](https://aws.amazon.com/cli/) to configure your Object Storage
* S3 based Object Storage: Provision an S3 based Object Storage from your Cloud provider. Take note of your Authentication Endpoints, Access Key ID and Secret
> For IBM Cloud, you can provision an Object Storage from [IBM Cloud Dashboard](https://console.bluemix.net/catalog/infrastructure/cloud-object-storage?taxonomyNavigation=apps) or from [SoftLayer Portal](https://control.softlayer.com/storage/objectstorage).

### 1. Uploading the Dataset to Cloud Object Storage

0. A sample dataset can be found [here](https://github.com/harvardnlp/sent-summary) for creating title's for articles. We will use the Gigaword dataset as an example.

1. Split your dataset into training data, training labels, validation data, and validation labels (this is already done for the Gigaword dataset).

2. Setup your S3 command with your Object Storage credentials.

```shell
s3_url=http://<Your object storage Authentication Endpoints>
export AWS_ACCESS_KEY_ID=<Your object storage Access Key ID>
export AWS_SECRET_ACCESS_KEY=<Your object storage Access Key Secret>

s3cmd="aws --endpoint-url=$s3_url s3"
```

3. Next, let us create 2 buckets, one for storing the training data and another one for storing the training results.
```shell
trainingDataBucket=<unique bucket name for training data storage>
trainingResultBucket=<unique bucket name for training result storage>

$s3cmd mb s3://$trainingDataBucket
$s3cmd mb s3://$trainingResultBucket
```

4. Upload your dataset.
```shell
dataDirectory = /path/to/data/directory
$s3cmd cp $dataDirectory/train.article.txt s3://$trainingDataBucket
$s3cmd cp $dataDirectory/train.title.txt s3://$trainingDataBucket
$s3cmd cp $dataDirectory/valid.article.filter.txt s3://$trainingDataBucket
$s3cmd cp $dataDirectory/valid.title.filter.txt s3://$trainingDataBucket
```

### 2. Change the manifest.yaml to Match your Environment

1. Download entrypoint.sh and manifest.yaml file.

2. Zip entrypoint.sh by going to the directory where entrypoint.sh is stored and then running

```shell
zip entrypoint.zip entrypoint.sh
```

3. Change the manifest.yaml

#### Configure Training Job Specifications

- name: The name of the training job
- description: The description for the training job
- version: The version of the training job
- gpus: The number of gpus that should be used
- cpus: The number of cpus that should be used
- memory: The amount of memory that should be used

```yaml
name: Sequence 2 Sequence on Gigaword
description: OpenNMT Seq2seq model trained on Gigaword dataset
version: "1.0"
gpus: 1
cpus: 8
memory: 16GB
```

#### Configure for S3 Object Storage

- Replace <training_data> with the name of the bucket containing the dataset
- Replace <training_results> with the bucket where the training results should go
- Replace <auth_url> with http://<Your object storage Authentication Endpoints>
- Replace <user_name> with your object storage Access Key ID
- Replace <password> with Your object storage Access Key Secret

```yaml
data_stores:
  - id: test-datastore
    type: mount_cos
    training_data:
      container: <training_data>
    training_results:
      container: <training_results>
    connection:
      auth_url: <auth_url>
      user_name: <user_name>
      password: <password>
```

#### Configure Command Flags

For Preprocessing:
- max_data_shard: Divides testing data into shards of this size (in bytes) during preprocessing. Can be used to split up large datasets into smaller components.
- save_data: Where the preprocessed data will be saved. Should include $DATA_DIR/ to save to S3 Object Storage

For Training:
- data: Where you stored the preprocessed data. Should be the same as -save_data in the preprocessing step
- save_model: Where the model will be stored. Should include $RESULT_DIR/ to save to S3 Object Storage.
- epochs: The number of epochs to be run.
- gpuid <optional>: Use -gpuid 0 to use supported CUDA devices. Omit this flag to only use cpu.

```yaml
framework:
  name: pytorch
  version: latest
  command: >
    bash entrypoint.sh;
    python OpenNMT-py/preprocess.py
     -train_src $DATA_DIR/train.article.txt
     -train_tgt $DATA_DIR/train.title.txt
     -valid_src $DATA_DIR/valid.article.filter.txt
     -valid_tgt $DATA_DIR/valid.title.filter.txt
     -max_shard_size 200000000
     -save_data $DATA_DIR/processed_data;
    python OpenNMT-py/train.py
      -data $DATA_DIR/processed_data
      -save_model $RESULT_DIR/model
      -epochs 1
      -gpuid 0;
```

4. Go to the FfDL UI and submit a training job with entrypoint.zip and manifest.yaml
