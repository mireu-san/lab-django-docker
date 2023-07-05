# Base image
FROM python:3.9-alpine3.13

# Metadata
LABEL maintainer="https://github.com/mireu-san"

# Set environment variables
ENV PYTHONBUFFERED 1

# Copy requirements files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy application code
COPY ./app /app

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 8000

# Set build argument for dev environment
ARG DEV=false

# Install dependencies
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt ; fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Set the PATH environment variable
ENV PATH="/py/bin:$PATH"

# Set the user to run the container
USER django-user
