# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:22.04

ARG cnb_uid=1000
ARG cnb_gid=1000
ARG stack_id="openfunction.py39"

# Required by python/runtime: libexpat1, libffi6, libmpdecc2.
# Required by dotnet/runtime: libicu60
# Required by go/runtime: tzdata (Go may panic without /usr/share/zoneinfo)
RUN apt-get update && apt-get install -y --no-install-recommends \
  libexpat1 \
  libffi7 \
  libmpdec3 \
  libicu70 \
  libc++1-12 \
  tzdata \
  libonig5  \
  libsqlite3-0 \
  libxml2 \
  libyaml-0-2 \
  locales \
  openssl \
  ca-certificates \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

LABEL io.buildpacks.stack.id=${stack_id}

RUN groupadd cnb --gid ${cnb_gid} && \
  useradd --uid ${cnb_uid} --gid ${cnb_gid} -m -s /bin/bash cnb

RUN apt-get update && apt-get install -y --no-install-recommends \
  wget \
  build-essential \
  libffi-dev \
  zlib1g-dev \
  libssl-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/* && \
  cd /opt && wget --no-check-certificate https://www.python.org/ftp/python/3.9.17/Python-3.9.17.tgz && tar xzf Python-3.9.17.tgz && cd Python-3.9.17 && \
#  sed -i '214,217s/^#//' Modules/Setup && \
  /bin/bash -c "./configure && make -j8 && make -j8 install" && \
  ln -sf /usr/local/bin/python3.17 /usr/bin/python3 && python3 -m pip install --upgrade pip setuptools wheel && \
  cd /opt && rm -rf Python-3.9.17

ENV CNB_USER_ID=${cnb_uid}
ENV CNB_GROUP_ID=${cnb_gid}
ENV CNB_STACK_ID=${stack_id}
