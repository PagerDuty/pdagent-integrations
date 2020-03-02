# Linux Build Instructions

These instructions assume you're running this on a Mac with Vagrant installed,
and that the project directory ends up mounted in the VM at `/vagrant`. (this
should happen automatically)

## One-time setup of GPG keys:

See the same section of this file in the pdagent project.

## Ubuntu

Building the .deb:

    scons local-repo \
        gpg-home=build-linux/gnupg \
        virt=agent-minimal-ubuntu1204

Install & test the .deb:

    vagrant ssh agent-minimal-ubuntu1204

Install the PagerDuty Agent using the Agent Install Guide on the PagerDuty
website (under http://www.pagerduty.com/docs/). Then install the development
build as follows:

    sudo apt-key add /vagrant/target/tmp/GPG-KEY-pagerduty
    sudo sh -c 'echo "deb file:///vagrant/target deb/" \
      >/etc/apt/sources.list.d/pdagent-integrations.list'
    sudo apt-get update
    sudo apt-get install pdagent-integrations

    /usr/share/pdagent-integrations/bin/pd-zabbix  # should run but fail with IndexError

Uninstall & test cleanup:

    sudo apt-get --yes remove pdagent-integrations

    /usr/share/pdagent-integrations/bin/pd-zabbix  # should not exist

## CentOS / RHEL

Building the .rpm:

    scons local-repo \
        gpg-home=/gpg/path/used/earlier \
        virt=agent-minimal-centos65

Install & test the .rpm:

    vagrant ssh agent-minimal-centos65

Install the PagerDuty Agent using the Agent Install Guide on the PagerDuty
website (under http://www.pagerduty.com/docs/). Then install the development
build as follows:

```
sudo sh -c 'cat >/etc/yum.repos.d/pdagent-integrations.repo <<EOF
[pdagent-integrations]
name=PDAgent Integrations
baseurl=file:///vagrant/target/rpm
enabled=1
gpgcheck=1
gpgkey=file:///vagrant/target/tmp/GPG-KEY-pagerduty
EOF'
sudo yum install -y pdagent-integrations
```

    /usr/share/pdagent-integrations/bin/pd-zabbix  # should run but fail with IndexError
    /usr/share/pdagent-integrations/bin/pd-zabbix  # should fail with an error

Uninstall & test cleanup:

    sudo yum remove -y pdagent-integrations

    /usr/share/pdagent-integrations/bin/pd-zabbix  # should not exist
