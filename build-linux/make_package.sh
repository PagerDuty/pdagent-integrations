#
# See howto.txt for instructions.
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

set -e  # fail on errors

# params
pkg_type=""

print_usage_and_exit() {
    echo "Usage: $0 {deb|rpm}"
    exit 2
}

if [ $# -ne 1 ]; then
    print_usage_and_exit
fi

case "$1" in
    deb|rpm)
        pkg_type=$1
        ;;
    *)
        print_usage_and_exit
esac

echo = BUILD TYPE: $pkg_type

# ensure we're in the build directory
cd $(dirname "$0")

echo = cleaning build directories
rm -fr data target
mkdir data target

echo = /usr/share/pdagent-integrations/bin
mkdir -p data/usr/share/pdagent-integrations/bin
cp ../bin/* data/usr/share/pdagent-integrations/bin

echo = FPM!
_FPM_DEPENDS="--depends pdagent"

_SIGN_OPTS=""
if [ "$pkg_type" = "rpm" ]; then
    _SIGN_OPTS="--rpm-sign"
fi

cd target

_DESC="The PagerDuty Agent Integrations package
The PagerDuty Agent Integrations package contains integrations for various
monitoring tools with the PagerDuty Agent."
if [ "$pkg_type" = "deb" ]; then
    _PKG_MAINTAINER="Package Maintainer"
else
    _PKG_MAINTAINER="RPM Package Maintainer"
fi
_PKG_MAINTAINER="$_PKG_MAINTAINER (PagerDuty, Inc.) <packages@pagerduty.com>"
fpm -s dir \
    -t $pkg_type \
    --name "pdagent-integrations" \
    --description "$_DESC" \
    --version "1.0" \
    --architecture all \
    --url "http://www.pagerduty.com" \
    --license 'Open Source' \
    --vendor 'PagerDuty, Inc.' \
    --maintainer "$_PKG_MAINTAINER" \
    $_FPM_DEPENDS \
    $_SIGN_OPTS \
    --${pkg_type}-user root \
    --${pkg_type}-group root \
    -C ../data \
    usr

exit 0
