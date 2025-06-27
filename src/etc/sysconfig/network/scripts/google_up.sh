#!/bin/bash
# Copyright 2024 Google LLC
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

instance=$(curl -H 'Metadata-Flavor: Google' http://169.254.169.254/computeMetadata/v1/instance/?recursive=true)

# Ensure that the hostname and IP address are set only for the primary NIC.
new_ip_address=$(jq -r .networkInterfaces[0].ip <<< $instance)
new_host_name=$(jq -r .hostname <<< $instance)
new_ip_address=$new_ip_address new_host_name=$new_host_name google_set_hostname
