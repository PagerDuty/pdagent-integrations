#
# Check that pd-zabbix enqueues events.
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

# stop pdagent
stop_agent

# zabbix command line must enqueue correctly
test_zabbix_trigger() {

  # clear outqueue
  test -d $OUTQUEUE_DIR
  sudo find $OUTQUEUE_DIR -type f -exec rm -f {} \;

  $BIN_PD_ZABBIX DUMMY_SERVICE_KEY trigger \
"name:Zabbix server has just been restarted
id:13502
status:PROBLEM
hostname:Zabbix server
ip:127.0.0.1
value:1
event_id:70
severity:High"

  test $(sudo find $OUTQUEUE_DIR -type f | wc -l) -eq 1

  sudo find $OUTQUEUE_DIR -type f -name "*.txt" \
    | xargs sudo sed -i -r 's/"agent_id":"[a-f0-9-]+"/"agent_id":"SOME_ID"/g'
  sudo find $OUTQUEUE_DIR -type f -name "*.txt" \
    | xargs sudo sed -i -r 's/"queued_at":"[0-9]{4}(-[0-9]{2}){2}T[0-9]{2}(:[0-9]{2}){2}Z"/"queued_at":"SOME_TIME"/g'

  sudo diff \
      $(sudo find $OUTQUEUE_DIR -type f -name "*.txt" | tail -n1) \
      $(dirname $0)/test_10_zabbix.pdq1.txt

}

test_zabbix_resolve() {

  # clear outqueue
  test -d $OUTQUEUE_DIR
  sudo find $OUTQUEUE_DIR -type f -exec rm -f {} \;

  $BIN_PD_ZABBIX DUMMY_SERVICE_KEY resolve \
"name:Zabbix server has just been restarted
id:13502
status:OK
hostname:Zabbix server
ip:127.0.0.1
value:0
event_id:126
severity:High"

  test $(sudo find $OUTQUEUE_DIR -type f | wc -l) -eq 1
  test $(sudo find $OUTQUEUE_DIR -type f -name "*.txt" | wc -l) -eq 1

  sudo find $OUTQUEUE_DIR -type f -name "*.txt" \
    | xargs sudo sed -i -r 's/"agent_id":"[a-f0-9-]+"/"agent_id":"SOME_ID"/g'
  sudo find $OUTQUEUE_DIR -type f -name "*.txt" \
    | xargs sudo sed -i -r 's/"queued_at":"[0-9]{4}(-[0-9]{2}){2}T[0-9]{2}(:[0-9]{2}){2}Z"/"queued_at":"SOME_TIME"/g'

  sudo diff \
      $(sudo find $OUTQUEUE_DIR -type f -name "*.txt" | tail -n1) \
      $(dirname $0)/test_10_zabbix.pdq2.txt

}

test_zabbix_trigger
test_zabbix_resolve
