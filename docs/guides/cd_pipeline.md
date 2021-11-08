# Develop a CD Pipeline

In this exercise you will develop a CD pipeline that will build a Docker image from a Dockerfile and push it to a Docker registry in GCP. Then you will use this image to deploy a virtual machine that will execute de Kedro pipeline every 5 minutes.

## Objectives

- Build a Kedro Docker image
- Run and verify the image locally
- Add a container building step to the DevOps pipeline
- Add a container publish step to the DevOps pipeline
- Declare infrastructure as code (IaaC) using Terraform
- Declare infrastructure parameters
- Create a service account with IAM permissions for deployment
- Add a deployment step to the DevOps pipeline

## Prerequisites

If you intend to replicate this exercise as it is, I encourage you to [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this repo to your account.

It is necessary that you have [Docker](https://docs.docker.com/engine/install/) installed in your device and that you have a [GCP account](https://cloud.google.com/).

To develop this exercise you should have done the [setup steps in the README.md](../../README.md). It is also advisable that you do the [first exercise](ci_pipeline.md) before beginning this exercise so you may have more clarity about the DevOps pipeline structure. To begin, you must **checkout to the exercise branch named** `exercises/02-cd-pipeline` using

```
git checkout exercises/02-cd-pipeline
```

## Exercise

Add the following catalogs to your `conf/base/catalog.yml` file

```yaml
pokeapi:
  type: api.APIDataSet
  url: https://pokeapi.co/api/v2/pokemon
  params:
    limit: 100000
    offset: 0
    format: json

pokemons:
  type: pandas.ParquetDataSet
  filepath: data/01_raw/pokemons.parquet
```

Then add the following code to your `src/kedro_devops/pipelines/data_engineering/nodes/transform_uppercase.py` file

```python
import pandas as pd
from requests import Response


def transform_uppercase(data_set: Response) -> pd.DataFrame:
    """
    Transform a lowercase dataframe to uppercase.

    Args:
        data_set (APIDataSet): A raw api request

    Returns:
        pd.DataFrame: An uppercase dataframe
    """
    json_data = data_set.json()
    pokemons = json_data.get("results")
    data = pd.json_normalize(pokemons)
    return data.applymap(lambda x: x.upper())

```

This will process the [pokemon api](https://pokeapi.co/) data and transform it to uppercase. After this, we need to add a node to our pipeline that uses the modified `transform_uppercase` function and the catalogs that we added to the `conf/base/catalog.yml` file. To do this we need to open the `src/kedro_devops/pipelines/data_engineering/pipeline.py` file and add the following code:

```python
...
def create_pipeline(**kwargs) -> Pipeline:
    """
    Create a pipeline for data engineering.

    Returns:
        Pipeline: the data engineering pipeline.
    """
    return Pipeline([
        Node(
            transform_uppercase,
            inputs="pokeapi",
            outputs="pokemons",
            name="pokemons_uppercase")
    ])
```

Now that we have our pipeline, we need to add the following dependency to `src/requirements.in` to allow us to build and run the image locally.

```properties
...
kedro-docker
...
```

Then build and install the requirements using:

```bash
kedro build-reqs
pip install -r src/requirements.txt
```

Generate a `Dockerfile` using the following command:

```bash
kedro docker init
```

Modify the `Dockerfile` in the root directory of the project to look like this

```dockerfile
# BUILD STAGE
FROM python:3.7-buster as builder
WORKDIR /home/kedro

# install project requirements
RUN pip install --no-cache-dir --upgrade pip
COPY ./src .

RUN pip install --no-cache-dir pip-tools && \
    pip-compile requirements.in --output-file requirements.txt && \
    python setup.py clean --all bdist_wheel


# RUN STAGE
FROM python:3.7-buster as runner

# install cron dependencies
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y cron

# install build whl file
COPY --from=builder /home/kedro/dist/kedro_devops-0.1-py3-none-any.whl /tmp/kedro_devops-0.1-py3-none-any.whl
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir /tmp/kedro_devops-0.1-py3-none-any.whl

# add kedro user
WORKDIR /home/kedro

# copy necessary files
COPY . .

# add execution permissions to execution script
RUN chmod +x executor.sh && touch conf/local/credentials.yml

# add cron job to run kedro every minute
RUN echo "* * * * * root bash /home/kedro/executor.sh >> /home/kedro/cron_logs.log 2>&1" >> /etc/crontab

# configure cron job log file
RUN touch /var/log/cron.log

# run the cron as entrypoint
CMD ["cron","-f"]

```

Then build a container using the following command:

```bash
kedro docker build
```

After the container is built, we can run it locally using the Docker interface or by using the following command:

```bash
docker run -d --name kedro_devops kedro-devops
```

If you want to debug your running container you can do it from the Docker interface or by executing this command:

```bash
docker exec -it kedro_devops /bin/bash
```
