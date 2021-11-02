# BUILD STAGE
FROM python:3.7-buster as builder
WORKDIR /home/kedro

# install project requirements
RUN pip install --upgrade pip
COPY ./src .

RUN pip install pip-tools && \
    pip-compile ./requirements.in --output-file ./requirements.txt && \
    python setup.py clean --all bdist_egg


# RUN STAGE
FROM python:3.7-buster as runner

# install cron dependencies
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y cron && \
    touch /var/log/cron.log

# install build whl file
COPY --from=builder /home/kedro/dist/kedro_devops-0.1-py3-none-any.whl /tmp/kedro_devops-0.1-py3-none-any.whl
RUN pip install --upgrade pip && pip install /tmp/kedro_devops-0.1-py3-none-any.whl 

# add kedro user
ARG KEDRO_UID=999
ARG KEDRO_GID=0
RUN groupadd -f -g ${KEDRO_GID} kedro_group && \
    useradd -l -d /home/kedro -s /bin/bash -g ${KEDRO_GID} -u ${KEDRO_UID} kedro

# copy the whole project except what is in .dockerignore
WORKDIR /home/kedro
RUN chown -R kedro:${KEDRO_GID} /home/kedro
USER kedro
RUN chmod -R a+w /home/kedro

EXPOSE 8888

# run the kedro pipeline every 5 minutes and dump the logs in the cron_logs.log file
RUN echo "*/5 * * * * python -m kedro_devops.run > /home/kedro/cron_logs.log 2>&1"

# run the cron as entrypoint
CMD ["cron", "-f"]
