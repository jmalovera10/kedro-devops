FROM python:3.7-buster as builder
WORKDIR /home/kedro

RUN pip install --no-cache-dir --upgrade pip
COPY ./src .

RUN pip install --no-cache-dir pip-tools && \
    # kedro build-reqs
    pip-compile requirements.in --output-file requirements.txt && \
    # kedro package
    python setup.py clean --all bdist_wheel

# -----------------------------

# RUN STAGE
FROM python:3.7-buster as runner

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y cron

COPY --from=builder /home/kedro/dist/kedro_devops-0.1-py3-none-any.whl /tmp/kedro_devops-0.1-py3-none-any.whl
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir /tmp/kedro_devops-0.1-py3-none-any.whl

WORKDIR /home/kedro

COPY . .

RUN chmod +x executor.sh && touch conf/local/credentials.yml

RUN echo "* * * * * root bash /home/kedro/executor.sh >> /home/kedro/cron_logs.log 2>&1" >> /etc/crontab

RUN touch /var/log/cron.log

CMD ["cron","-f"]
