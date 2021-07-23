## What ?
This repository is holding configurations related to creation of ElasticSearch APM server BOSH release

## Why ?
To provide latest version of ElasticSearch APM Server in the context of BOSH release

## How ?
In order to complete the task which should provide latest version of ElasticSearch APM Server
there are a few conditions that should be satisfied:
1. You have to have a configured local BOSH client
2. A file called `private.yml` under directory `config` with the following structure:
    ```
    ---
    blobstore:
      options:
         access_key_id: <access-key-id-required-to-push-new-blob-to-its-s3-bucket>
         secret_access_key: <secret-access-key-required-to-push-new-blob-to-its-s3-bucket>
   ```
3. Check which is the latest available version 
4. Export required AWS credentials which will give access to blobstore in the current working directory:
    ```
   export AWS_ACCESS_KEY_ID=<value>
   export AWS_SECRET_ACCESS_KEY=<value>
   export AWS_DEFAULT_REGION=<value>
   ```

<br>Once all of the above steps are completed we could execute `upgrade-blob.sh <VERSION>` script which will download the version of APM Server blob which we pass as input.</br>
The script will also replace the old blob version with the new one and will copy it into blobs directory.
<br>After that it will execute `bosh upload-blobs` which will send the new version to remote blobstore and immediately after that will update the files(`packaging` & `spec`) inside `packages/apm-server`</br>
