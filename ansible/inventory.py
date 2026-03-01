#!/usr/bin/env python3
import json
import subprocess

tf = json.loads(subprocess.check_output(
    ["terraform", "output", "-json"], cwd="../terraform"
))

ip = tf["vm_ip"]["value"]
user = tf["vm_username"]["value"]
private_key = tf["vm_private_key"]["value"]
acr_name = tf["acr_name"]["value"]

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
        "hosts": ["localhost"]
    },
    "all": {
        "vars": {
            "acr_name": acr_name
        }
    },
    "localhost": {
        "hosts": ["127.0.0.1"],
        "vars": {
            "ansible_connection": "local"
        }
    }
}

print(json.dumps(inventory))