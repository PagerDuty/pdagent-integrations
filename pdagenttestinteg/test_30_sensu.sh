#
# Checks commands that access local queue.
#
# Copyright (c) 2017, PagerDuty, Inc. <info@pagerduty.com>
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

purge_queue() {
  test -d $OUTQUEUE_DIR
  sudo find $OUTQUEUE_DIR -type f -exec rm -f {} \;
}

fix_events() {
  sudo find $OUTQUEUE_DIR -type f -name "*.txt" \
    | xargs sudo sed -i -r 's/"agent_id":"[a-f0-9-]+"/"agent_id":"SOME_ID"/g'
  sudo find $OUTQUEUE_DIR -type f -name "*.txt" \
    | xargs sudo sed -i -r 's/"queued_at":"[0-9]{4}(-[0-9]{2}){2}T[0-9]{2}(:[0-9]{2}){2}Z"/"queued_at":"SOME_TIME"/g'
}


stop_agent
purge_queue

test_inout() {
  # What pd-sensu must do:
  #
  # All it needs to do is fold the original JSON into the details property
  # of a new JSON and add:
  #
  # incident_key (derived from client.name and check.name)
  # description (derived from client.name, check.name and check.output)
  # service_key
  # event_type (trigger or resolve, derived from action)
  etype=$1
  action=$2
  client=$3
  check=$4
  output=$5
  purge_queue
  cat /vagrant/pdagenttestinteg/test_30_sensu.generic.json |\
      sed "s/{{action}}/$action/g;
              s/{{clientname}}/$client/g;
              s/{{checkname}}/$check/g;
              s/{{output}}/$output/g"\
          > ./test_30_sensu.$etype.json
  $BIN_PD_SENSU -k DUMMY_SERVICE_KEY < ./test_30_sensu.$etype.json
  fix_events
  sudo python -c "
import json,sys
input={
    'details':json.load(open('test_30_sensu.$etype.json','r')),
    'incident_key': '$client/$check',
    'description': '$client/$check : $output',
    'service_key': 'DUMMY_SERVICE_KEY',
    'event_type': '$etype',
    'client': '',
    'client_url': '',
    'agent': {
      'queued_at': 'SOME_TIME',
      'queued_by': 'pd-sensu',
      'agent_id': 'SOME_ID'
    }
}
output = json.load(open(
    '''`sudo find $OUTQUEUE_DIR -type f -name '*.txt' | tail -n1`'''.strip(),
    'r'
))
if input != output:
    extra_exp={k:input[k] for k in set(input.keys())-set(output.keys())}
    extra_out={k:output[k] for k in set(output.keys())-set(input.keys())}
    raise Exception('Output JSON object differs from expected ($etype);\\n\\n'+
        'Expected: \\n%s\\n'%str(input)+
        'Actual: \\n%s\\n'%str(output)+
        'Missing expected properties:\\n%s\\n'%str(extra_exp)+
        'Extraneous output properties:\\n%s\\n'%str(extra_out)
    )"
  rm ./test_30_sensu.$etype.json
}

test_inout 'trigger' 'create' 'DUMMY_CLIENT' 'DUMMY_CHECK' 'SERVERS ON FIRE'
test_inout 'resolve' 'resolve' 'DUMMY_CLIENT' 'DUMMY_CHECK' 'SERVERS SMOKIN'
