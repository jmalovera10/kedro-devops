FROM quay.io/astronomer/ap-airflow:1.10.12-buster-onbuild

RUN pip install --user kedro_devops-0.1-py3-none-any.whl
