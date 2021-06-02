#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Fortinet Corporation. All rights reserved.
# Licensed under the GNU License. See LICENSE in the project root for license information.
#-------------------------------------------------------------------------------------------------------------

# Use Python 2.7 on CentOS 7 as base image
FROM centos/python-27-centos7

USER root

RUN yum -y update \
&&  yum clean all \
&&  yum -y install epel-release \
&&  yum -y install openssh-server git net-tools initscripts nfs-utils

# Workaround for running SSH Server
# https://qiita.com/ShikiSouma/items/8a47082e0067e102c5c4
RUN mv /usr/bin/systemctl /usr/bin/systemctl.old \
&& curl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py > /usr/bin/systemctl \
&& chmod +x /usr/bin/systemctl

# Enable the SCL for all bash scripts
ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

# Install/upgrade pip2, install Ansible 2.9 and some Python libs
RUN . /opt/app-root/etc/scl_enable \
&& curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output /root/get-pip.py \
&& pip install --upgrade "pip < 21.0" \
&& /usr/bin/python /root/get-pip.py \
&& /opt/rh/python27/root/usr/bin/python /root/get-pip.py \
&& /usr/bin/pip install netaddr pexpect fortiosapi==0.11.1 jinja2==2.10.1 ansible==2.9.17\
&& /opt/rh/python27/root/usr/bin/pip install netaddr pexpect fortiosapi==0.11.1 jinja2==2.10.1

ENV container docker

RUN /usr/sbin/sshd-keygen
RUN echo 'root:PLEASE_CHANGE_ROOT_PASSWORD' | chpasswd
COPY ./screen /usr/bin/
RUN chmod +x /usr/bin/screen
RUN echo 'defshell -bash' >> /root/.screenrc
EXPOSE 22

# https://docs.ansible.com/ansible/devel/reference_appendices/config.html#cfg-in-world-writable-dir
ENV ANSIBLE_CONFIG=/root/ansible.cfg
