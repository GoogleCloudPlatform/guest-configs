# Copyright 2020 Google Inc. All Rights Reserved.
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

%global dracutdir %(pkg-config --variable=dracutdir dracut)

# For EL7, if building on CentOS, override dist to be el7.
%if 0%{?rhel} == 7
  %define dist .el7
%endif

Name: google-compute-engine
Epoch: 1
Version: %{_version}
Release: g1%{?dist}
Summary: Google Compute Engine guest environment.
License: ASL 2.0
Url: https://github.com/GoogleCloudPlatform/guest-configs
Source0: %{name}_%{version}.orig.tar.gz
Requires: curl
Requires: dracut
Requires: google-compute-engine-oslogin
Requires: google-guest-agent
Requires: rsyslog
Requires: nvme-cli

BuildArch: noarch

# Allow other files in the source that don't end up in the package.
%define _unpackaged_files_terminate_build 0

%description
This package contains scripts, configuration, and init files for features
specific to the Google Compute Engine cloud environment.

%prep
%autosetup

%install
cp -a src/{etc,usr} %{buildroot}
install -d %{buildroot}/%{_udevrulesdir}
cp -a src/lib/udev/rules.d/* %{buildroot}/%{_udevrulesdir}
cp -a src/lib/udev/google_nvme_id %{buildroot}/%{_udevrulesdir}/../
install -d  %{buildroot}/%{dracutdir}
cp -a src/lib/dracut/* %{buildroot}/%{dracutdir}/

%files
%attr(0755,-,-) /usr/lib/dracut/modules.d/30gcp-udev-rules/module-setup.sh
%defattr(0644,root,root,0755)
%attr(0755,-,-) %{_bindir}/*
%attr(0755,-,-) /etc/dhcp/dhclient.d/google_hostname.sh
%{_udevrulesdir}/*
%attr(0755,-,-) %{_udevrulesdir}/../google_nvme_id
%config /etc/dracut.conf.d/*
%config /etc/modprobe.d/*
%config /etc/rsyslog.d/*
%config /etc/sysctl.d/*

%pre
if [ $1 -gt 1 ] ; then
  # This is an upgrade. Stop and disable services previously owned by this
  # package, if any.
  for svc in google-ip-forwarding-daemon google-network-setup \
    google-network-daemon google-accounts-daemon google-clock-skew-daemon \
    google-instance-setup; do
      if systemctl is-enabled ${svc}.service >/dev/null 2>&1; then
        systemctl --no-reload disable ${svc}.service >/dev/null 2>&1 || :
        if [ -d /run/systemd/system ]; then
          systemctl stop ${svc}.service >/dev/null 2>&1 || :
        fi
      fi
  done
  systemctl daemon-reload >/dev/null 2>&1 || :
fi

%post
dracut --force
