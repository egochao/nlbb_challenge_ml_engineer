# Base image
FROM python:3.9-slim AS python-base
ENV PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  POETRY_VERSION=1.1.11 \
  POETRY_PATH=/opt/poetry \
  VENV_PATH=/opt/venv
ENV PATH="$POETRY_PATH/bin:$VENV_PATH/bin:$PATH"


FROM python-base AS installs
RUN apt-get update \
  && apt-get install gcc git curl build-essential -y \
  && apt-get install libgomp1 -y \
  && apt-get clean \
  && curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python \
  && mv /root/.poetry $POETRY_PATH \
  && python -m venv $VENV_PATH \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src
COPY poetry.lock pyproject.toml ./
RUN poetry config virtualenvs.create false \
  && poetry install --no-interaction --no-ansi -vvv

FROM python-base AS jupter_image
RUN apt-get update && apt-get install libgomp1 -y
COPY --from=installs $VENV_PATH $VENV_PATH
WORKDIR /usr/src
COPY . .

EXPOSE 8887
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token=''", "--allow-root", "--NotebookApp.password=''"]
