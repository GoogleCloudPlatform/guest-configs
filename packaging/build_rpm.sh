#!/bin/bash
# Copyright 2019 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

rpm_working_dir=/tmp/rpmpackage/

. packaging/common.sh

# Install dependencies.
yum -y install rpmdevtools

rm -rf /tmp/rpmpackage
mkdir -p ${rpm_working_dir}/{SOURCES,SPECS}

# EL6 has a separate .spec file.
if [[ -e /etc/redhat-release ]] && grep -q release\ 6 /etc/redhat-release; then
  cp packaging/${PKGNAME}-el6.spec ${rpm_working_dir}/SPECS/${NAME}.spec
else
  cp packaging/${PKGNAME}.spec ${rpm_working_dir}/SPECS/
fi

tar czvf ${rpm_working_dir}/SOURCES/${PKGNAME}_${VERSION}.orig.tar.gz \
  --exclude .git --exclude packaging --transform "s/^\./${PKGNAME}-${VERSION}/" .

rpmbuild --define "_topdir ${rpm_working_dir}/" --define "_version ${VERSION}" \
  -ba ${rpm_working_dir}/SPECS/${PKGNAME}.spec
