FROM ubuntu:22.04 AS build-image

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt-get update
RUN apt-get -qq upgrade
RUN apt-get -qq install build-essential libssl-dev wget curl apt-utils git ca-certificates
RUN apt update
RUN apt-get -qq install curl software-properties-common apt-transport-https lsb-release
RUN curl -fsSL https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/erlang.gpg
RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get update
RUN apt-get -qq upgrade
# RUN apt list --all-versions erlang-base-hipe
# RUN apt-get -qq install erlang-base-hipe
RUN apt-get -qq install nodejs
RUN apt-get -qq install erlang-dev
RUN apt-get -qq install erlang-parsetools
RUN apt-get -qq install erlang-os-mon
RUN apt-get -qq install erlang-xmerl
RUN apt-get -qq install elixir
RUN elixir --version
RUN npm install --global npm

RUN useradd -m rc --uid=1001 && echo "rc:qwer1234" | chpasswd

COPY ./mix* /home/rc/build/
RUN chown -R rc: /home/rc/build/
USER rc

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /home/rc/build

RUN mix deps.get

ENV MIX_ENV prod
RUN mix deps.compile email_guard
RUN mix deps.compile

ARG APP_REVISION
ENV APP_REVISION=${APP_REVISION}
ARG BACK_ONLY
ENV BACK_ONLY=${BACK_ONLY}

USER root
COPY . /home/rc/build/
RUN chown -R rc: /home/rc/build/
USER rc

RUN ./build-front.sh
RUN mix release --version ${APP_REVISION}
RUN cd /home/rc/build/_build/prod/rel/ && tar -czvf /home/rc/build/rc.tar.gz rc
