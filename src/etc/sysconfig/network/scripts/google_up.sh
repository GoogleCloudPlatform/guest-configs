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

# Called by wicked via POST_UP_SCRIPT when an interface comes online
INTERFACE=$1
# Ignore the local loopback interface so we don't spam the Metadata server
if [ "$INTERFACE" = "lo" ] || [ -z "$INTERFACE" ]; then
    exit 0
fi

# Execute in the background with severed file descriptors (>/dev/null 2>&1 &)
# to avoid blocking the wicked network bringup process on MDS queries or network
# latency. Concurrency is handled by locking in google_set_metadata_network.
/usr/bin/google_set_metadata_network "$1" >/dev/null 2>&1 &