#!/usr/bin/python
#
# Python script to enqueue an event from Nagios to send to PagerDuty.
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


class NagiosEvent:
    HOST_NAME = "HOSTNAME"
    HOST_STATE = "HOSTSTATE"
    SERVICE_DESCRIPTION = "SERVICEDESC"
    SERVICE_STATE = "SERVICESTATE"

    REQUIRED_FIELDS = {
        "host": set([HOST_NAME, HOST_STATE]),
        "service": set([HOST_NAME, SERVICE_DESCRIPTION, SERVICE_STATE])
    }

    def __init__(self, service_key, event_type, notification_type, details, incident_key=None):
        self._service_key = service_key
        self._event_type = event_type
        self._notification_type = notification_type
        self._details = dict(list(details.items()) +
                             [("pd_nagios_object", self._notification_type)])
        self._given_incident_key = incident_key

    def enqueue(self):
        from pdagent.config import load_agent_config
        from pdagent.pdagentutil import queue_event
        agent_config = load_agent_config()
        self._check_required_fields()
        return queue_event(
            agent_config.get_enqueuer(),
            self._pagerduty_event_type(),
            self._service_key,
            self._incident_key(),
            self._event_description(),
            "",
            "",
            self._details,
            agent_config.get_agent_id(),
            "pd-nagios"
        )

    def _event_description(self):
        if self._notification_type == "service":
            fields = [NagiosEvent.SERVICE_DESCRIPTION,
                      NagiosEvent.SERVICE_STATE,
                      NagiosEvent.HOST_NAME
                      ]
        elif self._notification_type == "host":
            fields = [NagiosEvent.HOST_NAME, NagiosEvent.HOST_STATE]
        else:
            return None

        pairs = ["{0}={1}".format(field, self._details[field])
                 for field in fields]
        return "; ".join(pairs)

    def _incident_key(self):
        if self._given_incident_key is None:
            if self._notification_type == "service":
                return "event_source=service;host_name={0};service_desc={1}".format(
                    self._details[NagiosEvent.HOST_NAME],
                    self._details[NagiosEvent.SERVICE_DESCRIPTION]
                )
            elif self._notification_type == "host":
                return "event_source=host;host_name={0}".format(self._details[NagiosEvent.HOST_NAME])
            else:
                raise ValueError(
                    "notification_type must be one of 'service' or 'host'")
        else:
            return self._given_incident_key

    def _check_required_fields(self):
        if not NagiosEvent.REQUIRED_FIELDS[self._notification_type].issubset(list(self._details.keys())):
            msg = "Missing fields for type '{0}'.  {1} required".format(
                self._notification_type,
                ", ".join(NagiosEvent.REQUIRED_FIELDS[self._notification_type])
            )
            raise ValueError(msg)

    def _pagerduty_event_type(self):
        return {
            "PROBLEM": "trigger",
            "ACKNOWLEDGEMENT": "acknowledge",
            "RECOVERY": "resolve"
        }[self._event_type]


def main():
    description = "Enqueue an event from Nagios to PagerDuty."
    parser = build_queue_arg_parser(description)
    args = parser.parse_args()
    details = parse_fields(args.fields)

    event = NagiosEvent(
        args.service_key,
        args.event_type,
        args.notification_type,
        details,
        args.incident_key
    )

    try:
        incident_key = event.enqueue()
        print("Event processed. Incident Key:", incident_key)
    except ValueError as e:
        parser.error(e.message)


def build_queue_arg_parser(description):
    from pdagent.thirdparty.argparse import ArgumentParser
    parser = ArgumentParser(description=description)
    parser.add_argument(
        "-k",
        "--service-key",
        dest="service_key",
        required=True,
        help="Service API Key"
    )
    parser.add_argument(
        "-t",
        "--event-type",
        dest="event_type",
        required=True,
        help="Event type",
        choices=["PROBLEM", "ACKNOWLEDGEMENT", "RECOVERY"]
    )
    parser.add_argument(
        "-i",
        "--incident-key",
        dest="incident_key",
        help="Incident Key"
    )
    parser.add_argument(
        "-f",
        "--field",
        action="append",
        dest="fields",
        help="Add given KEY=VALUE pair to the event details"
    )
    parser.add_argument(
        "-n",
        "--notification-type",
        dest="notification_type",
        required=True,
        help="Nagios notification type (host or service)",
        choices=["service", "host"]
    )
    return parser


def parse_fields(fields):
    if fields is None:
        return {}
    return dict(f.split("=", 1) for f in fields)


if __name__ == "__main__":
    try:
        import pdagent.config
    except ImportError:
        # Fix up for dev layout
        import sys
        from os.path import realpath, dirname
        sys.path.append(dirname(dirname(realpath(__file__))))
        import pdagent.config
    main()
