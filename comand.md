We don't maintain a detailed changelog.  For details of changes, please see
either the `Open edX Release Notes`_ or the `GitHub commit history`_.

tutor images build openedx \
    --build-arg EDX_PLATFORM_REPOSITORY=https://github.com/williamsmiths/edx-platform.git \
    --build-arg EDX_PLATFORM_VERSION=dtu.v1.0.0


tutor images build openedx \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --docker-arg="--cache-from" \
    --docker-arg="docker.io/konghuan42/openedx:dtu.v1.0.0"

tutor config save --set DOCKER_IMAGE_OPENEDX=docker.io/konghuan42/openedx:dtu.v1.0.0
tutor images build openedx
tutor images push openedx


DOCKER_IMAGE_OPENEDX: "docker.io/konghuan42/openedx:dtu.v1.0.0"



tutor images build all
tutor images build mfe

tutor images build --no-cache mfe 


1. Tag từ overhangio/openedx-mfe:20.0.0-indigo → konghuan42/openedx-mfe:20.0.0-indigo
docker tag overhangio/openedx-mfe:20.0.0-indigo konghuan42/openedx-mfe:20.0.0-indigo

2. Push lên Docker Hub
docker push konghuan42/openedx-mfe:20.0.0-indigo

docker tag overhangio/openedx:20.0.1 kongubuntu/openedx:20.0.1
docker tag overhangio/openedx-learning:20.0.0 kongubuntu/openedx-learning:20.0.0
docker tag overhangio/openedx-learner-dashboard:20.0.0 kongubuntu/openedx-learner-dashboard:20.0.0


docker login
docker push kongubuntu/openedx:20.0.1
docker push kongubuntu/openedx-learning:20.0.0
docker push kongubuntu/openedx-learner-dashboard:20.0.0



DOCKER_IMAGE_OPENEDX: kongubuntu/openedx:20.0.1
DOCKER_IMAGE_OPENEDX_LEARNING: kongubuntu/openedx-learning:20.0.0
DOCKER_IMAGE_OPENEDX_LEARNER_DASHBOARD: kongubuntu/openedx-learner-dashboard:20.0.0



nano /home/cvs/.local/share/tutor/config.yml

tutor config save


tutor config save \
  --set SMTP_HOST=smtp.gmail.com \
  --set SMTP_PORT=587 \
  --set SMTP_USE_SSL=false  \
  --set SMTP_USE_TLS=true \
  --set SMTP_USERNAME=YOURUSERNAME@gmail.com \
  --set SMTP_PASSWORD='YOURPASSWORD'


.. _Open edX Release Notes: https://docs.openedx.org/en/latest/community/release_notes/index.html
.. _GitHub commit history: https://github.com/openedx/edx-platform/commits/master


cvs@cvs:~/tutor$ source env/bin/activate
nano /home/cvs/.local/share/tutor/config.yml
tutor local logs mfe
tutor plugins enable mfe

## cập nhật UI mfe
tutor local stop
docker rm -f tutor_local-mfe-1
tutor config save --set DOCKER_IMAGE_OPENEDX_MFE=konghuan42/openedx-mfe:v20.0.1
docker rmi konghuan42/openedx-mfe:v20.0.1

## sửa lại images theo docker hub
nano /home/cvs/.local/share/tutor/env/local/docker-compose.override.yml

tutor local restart mfe
tutor local restart

