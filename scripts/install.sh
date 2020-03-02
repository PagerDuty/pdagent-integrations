#!/bin/bash

set +e

. ./make_common.env

OS=$1
if [[ $OS == "ubuntu" ]]
then
    wget -O - http://packages.pagerduty.com/GPG-KEY-pagerduty | \
        sudo apt-key add -
    sudo sh -c 'echo "deb http://packages.pagerduty.com/pdagent deb/" \
      >/etc/apt/sources.list.d/pdagent.list'

    sudo apt-key add /vagrant/target/tmp/GPG-KEY-pagerduty
    sudo sh -c 'echo "deb file:///usr/share/pdagent-integrations/target deb/" \
      >/etc/apt/sources.list.d/pdagent-integrations.list'

    sudo apt-get update

    sudo apt-get install -y --allow-unauthenticated pdagent

    if [ -z "$UPGRADE_FROM_VERSION" ]; then
        sudo apt-get install -y --allow-unauthenticated pdagent-integrations
    else
        sudo apt-get install -y --allow-unauthenticated pdagent-integrations=$UPGRADE_FROM_VERSION
        # to upgrade pdagent pkg, run `apt-get install`, not `apt-get upgrade`.
        # 'install' updates one pkg, 'upgrade' updates all installed pkgs.
        sudo apt-get install -y --allow-unauthenticated pdagent-integrations
    fi
elif [[ $OS == "centos" ]]
then
    sudo sh -c 'cat >/etc/yum.repos.d/pdagent.repo <<EOF
[pdagent]
name=PDAgent
baseurl=http://packages.pagerduty.com/pdagent/rpm
enabled=1
gpgcheck=1
gpgkey=http://packages.pagerduty.com/GPG-KEY-RPM-pagerduty
EOF'
    sudo sh -c 'cat >/etc/yum.repos.d/pdagent-integrations.repo <<EOF
[pdagent-integrations]
name=PDAgent-Integrations
baseurl=file:///usr/share/pdagent-integrations/target/rpm
enabled=1
gpgcheck=1
priority=20
gpgkey=file:///usr/share/pdagent-integrations/target/tmp/GPG-KEY-RPM-pagerduty
EOF'

    # both these repos contain the integrations package (pdagent repo has the
    # already-published integrations package, and pdagent-integrations repo has
    # our local, currently-being-built one.) In Redhat, apparently, determining
    # the correct repo is not well-defined. So we install a yum-priorities
    # plugin, which allows us to specify that the local repo takes priority.
    # (See the `priority=20` value in the `pdagent-integrations.repo` file.)
    sudo yum install -y yum-plugin-priorities
    sudo sh -c 'cat >/etc/yum/pluginconf.d/priorities.conf <<EOF
[main]
enabled=1
EOF'

    sudo yum install -y pdagent

    if [ -z "$UPGRADE_FROM_VERSION" ]; then
        sudo yum install -y pdagent-integrations
    else
        sudo yum install -y pdagent-integrations-$UPGRADE_FROM_VERSION
        sudo yum upgrade -y pdagent-integrations
    fi
else
    echo "Error: Expected 'ubuntu' or 'centos' as first argument"
    exit 1
fi
