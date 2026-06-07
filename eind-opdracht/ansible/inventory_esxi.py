#!/usr/bin/env python3

import json
import subprocess
import sys
from pathlib import Path


def terraform_output(output_name: str):
    terraform_dir = Path(__file__).resolve().parents[1] / "terraform" / "esxi"

    result = subprocess.run(
        ["terraform", f"-chdir={terraform_dir}", "output", "-json", output_name],
        check=True,
        capture_output=True,
        text=True,
    )

    return json.loads(result.stdout)


def build_inventory():
    try:
        esxi_vm_ips = terraform_output("esxi_vm_ips")
    except subprocess.CalledProcessError as error:
        print(error.stderr, file=sys.stderr)
        sys.exit(1)

    hosts = {}
    platform_esxi_hosts = []

    for hostname, ip_address in esxi_vm_ips.items():
        if not ip_address or ip_address == "null":
            continue

        platform_esxi_hosts.append(hostname)
        hosts[hostname] = {
            "ansible_host": ip_address,
        }

    return {
        "_meta": {
            "hostvars": hosts,
        },
        "all": {
            "children": [
                "platform_esxi",
                "docker_hosts",
            ],
        },
        "platform_esxi": {
            "hosts": platform_esxi_hosts,
        },
        "docker_hosts": {
            "children": [
                "platform_esxi",
            ],
        },
    }


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--list":
        print(json.dumps(build_inventory(), indent=2))
    elif len(sys.argv) == 3 and sys.argv[1] == "--host":
        print(json.dumps({}))
    else:
        print(json.dumps(build_inventory(), indent=2))