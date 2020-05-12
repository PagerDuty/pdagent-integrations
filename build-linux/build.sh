#!/bin/bash

OS=$1
if [[ $OS == "ubuntu" ]]
then
    dpkg -i /pd-agent-install/build-linux/release/deb/pdagent_integrations_1.6.2_all.deb
elif [[ $OS == "centos" ]]
then
    rpm --import /pd-agent-install/target/tmp/GPG-KEY-RPM-pagerduty
    yum install -y /pd-agent-install/build-linux/release/rpm/pdagent-integrations-1.6.2-1.noarch.rpm
fi
