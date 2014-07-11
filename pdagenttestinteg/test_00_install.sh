#
# Installs the agent integrations.
#
# Copyright (c) 2013-2014, PagerDuty, Inc. <info@pagerduty.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#   * Neither the name of the copyright holder nor the
#     names of its contributors may be used to endorse or promote products
#     derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

. $(dirname $0)/util.sh

set -e
set -x

# install agent from internet, install integrations from build-target.
case $(os_type) in
  debian)
    wget -O - http://packages.pagerduty.com/GPG-KEY-pagerduty | \
        sudo apt-key add -
    sudo sh -c 'echo "deb http://packages.pagerduty.com/pdagent deb/" \
      >/etc/apt/sources.list.d/pdagent.list'

    sudo apt-key add /vagrant/target/tmp/GPG-KEY-pagerduty
    sudo sh -c 'echo "deb file:///vagrant/target deb/" \
      >/etc/apt/sources.list.d/pdagent-integrations.list'

    sudo apt-get update

    if [ -z "$UPGRADE_FROM_VERSION" ]; then
        sudo apt-get install -y pdagent-integrations
    else
        sudo apt-get install -y pdagent-integrations=$UPGRADE_FROM_VERSION
        # to upgrade pdagent pkg, run `apt-get install`, not `apt-get upgrade`.
        # 'install' updates one pkg, 'upgrade' updates all installed pkgs.
        sudo apt-get install -y pdagent-integrations
    fi
    ;;
  redhat)
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
baseurl=file:///vagrant/target/rpm
enabled=1
gpgcheck=1
priority=20
gpgkey=file:///vagrant/target/tmp/GPG-KEY-RPM-pagerduty
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
    if [ -z "$UPGRADE_FROM_VERSION" ]; then
        sudo yum install -y pdagent-integrations
    else
        sudo yum install -y pdagent-integrations-$UPGRADE_FROM_VERSION
        sudo yum upgrade -y pdagent-integrations
    fi
    ;;
  *)
    echo "Unknown os_type " $(os_type) >&2
    exit 1
esac

# check installation status.
test -e $BIN_PD_ZABBIX
test -e $BIN_PD_NAGIOS
