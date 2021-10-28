FROM python:3.7-buster

# install cron dependencies
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y cron && \
    touch /var/log/cron.log

# install project requirements
COPY src/requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt && rm -f /tmp/requirements.txt

# install build whl file
COPY src/*.whl /tmp/kedro_devops.whl
RUN pip install /tmp/kedro_devops.whl && rm -f /tmp/kedro_devops.whl

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

RUN echo "*/5 * * * * python -m kedro_devops.run > /home/kedro/cron_logs.log 2>&1"

CMD ["cron", "-f"]
