FROM tensorflow/tensorflow:latest-py3

ENV APP=pycon-pokemon
ENV JUPYTER_PATH=/srv/apps/$APP/app

# Install system requirement
RUN apt-get update && \
    apt-get install -y \
        apt-transport-https

# Create initial dirs
RUN mkdir -p /srv/apps/$APP/app /srv/apps/$APP/logs
WORKDIR /srv/apps/$APP/app

# Install pip requirements
COPY requirements.txt /srv/apps/$APP/app/
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir -r requirements.txt
ENV PYTHONPATH='$PYTHONPATH:/srv/apps/$APP/app'

# Clean up
RUN apt-get purge -y --auto-remove \
        apt-transport-https && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        $HOME/.cache/pip/*

# Copy application
COPY . /srv/apps/$APP/app/

EXPOSE 80

ENTRYPOINT ["./run"]
