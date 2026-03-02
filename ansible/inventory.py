#!/usr/bin/env python3
import json
import subprocess
import sys


def get_inventory():
    tf = json.loads(subprocess.check_output(
        ["terraform", "output", "-json"], cwd="../terraform"
    ))

    ip = tf["vm_ip"]["value"]
    user = tf["vm_username"]["value"]
    private_key = tf["vm_private_key"]["value"]
    acr_name = tf["acr_name"]["value"]
    acr_password = tf["acr_password"]["value"]

    key_path = "../ssh/id_rsa"
    with open(key_path, "w") as f:
        f.write(private_key)

    inventory = {
        "vm": {
            "hosts": [ip],
            "vars": {
                "ansible_user": user,
                "ansible_ssh_private_key_file": key_path
            }
        },
        "acr" : {
            "hosts": ["localhost"],
            "vars": {
                "ansible_connection": "local",
                "acr_password": acr_password
            }
        },
        "all": {
            "vars": {
                "acr_name": acr_name
            }
        },
        "_meta": {
            "hostvars": {}
        }
    }

    return inventory

if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--list":
        print(json.dumps(get_inventory()))
    elif len(sys.argv) == 3 and sys.argv[1] == "--host":
        print(json.dumps({}))
    else:
        print(json.dumps(get_inventory()))