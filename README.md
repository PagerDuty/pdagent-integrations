
See http://www.pagerduty.com/docs/guides/agent-install-guide/ for the PagerDuty
Agent Install Guide and related integration guides.

# Introduction

This project contains integrations for various monitoring tools with the
PagerDuty Agent.

It currently include support for:

- Nagios
- Sensu
- Zabbix

## Developing

See the Agent project at https://github.com/PagerDuty/pdagent for setup
instructions for Pydev, IntelliJ IDEA, Scons and Vagrant.

See the file `zabbix-testing.txt` for Zabbix build and test instructions,
`nagios-testing.txt` for Nagios build and test instructions, and the file
`sensu-testing.txt` for Sensu build and test instructions.


### Building Packages

Follow the same steps as in the Agent project. (there is no `SVC_KEY` in
`pdagenttestinteg/util.sh` to edit)

### Zabbix Testing

The scons integration test for Zabbix only runs standalone tests for the
`pd-zabbix` command line script. You should also test actual Zabbix integration
using the public Zabbix Integration Guide.

For details, see `zabbix-testing.txt`.


### Release Packages

Follow the same steps as in the Agent project.

#License
Copyright (c) 2013-2014, PagerDuty, Inc. <info@pagerduty.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
  * Neither the name of the copyright holder nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.


