#!/usr/bin/env python3.9

# Copyright 2021 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

import sys
import os
import json

if len(sys.argv) != 3:
    print(f'{sys.argv[0]} <fuchsia-source-directory> <sdk-destination>')
    sys.exit(1)

_, fuchsia_dir, dest = sys.argv

if os.path.exists(dest):
    print(f'ERROR: {dest} already exists.')
    sys.exit(1)

if not os.path.exists(fuchsia_dir):
    print(f'ERROR: {fuchsia_dir} does not exist.')
    sys.exit(1)


def not_fuchsia():
    print(
        f'ERROR: {fuchsia_dir} must be a Fuchsia source build with: build_sdk_archives = true'
    )
    sys.exit(1)


try:
    dotfile = f'{fuchsia_dir}/.fx-build-dir'
    build_dir = open(dotfile).read().strip()
except:
    print(f'Failed to read: {dotfile}')
    not_fuchsia()

sdk_parts = ('core', 'zircon_sysroot')
manifests = (f'{build_dir}/sdk/manifest/{part}' for part in sdk_parts)

files = []

for manifest_path in manifests:
    if not os.path.exists(manifest_path):
        print(f'SDK manifest not found: {manifest_path}')
        not_fuchsia()
    manifest = json.load(open(manifest_path, 'rt'))
    for atom in manifest['atoms']:
        files.extend(atom['files'])

for file in files:
    destination = os.path.normpath(os.path.join(dest, file['destination']))
    source = os.path.normpath(os.path.join(build_dir, file['source']))
    if os.path.exists(destination):
        if os.readlink(destination) != source:
            print(f'Conflicting sources for: {destination}')
            sys.exit(1)
        else:
            continue
    os.makedirs(os.path.dirname(destination), exist_ok=True)
    os.symlink(src=source, dst=destination)