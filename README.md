# Introduction

This project contains integrations for various monitoring tools with the PagerDuty
Agent.

It currently include support for:

- Zabbix


## Developing

See the Agent project at https://github.com/PagerDuty/pdagent for setup
instructions for Pydev, IntelliJ IDEA, Scons and Vagrant.

See the file `zabbix-testing.txt` for Zabbix build and test instructions.


### Building Packages

Follow the same steps as in the Agent project. (there is no `SVC_KEY` in
`pdagenttestinteg/util.sh` to edit)

### Zabbix Testing

The scons integration test for Zabbix only runs standalone tests for the
`pd-zabbix` command line script. You should also test actual Zabbix integration
using the public Zabbix Integration Guide.

For details, see `zabbix-testing.txt`.


### Release Packages

Follow the same steps as in the Agent project. This project shares the same production signing keys and S3 bucket as Agent.


