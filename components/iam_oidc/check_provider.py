#!/usr/bin/env python3
"""
Checks if GitHub's OIDC Identity Provider (token.actions.githubusercontent.com)
already exists in the target AWS account.
Outputs JSON for Terraform data.external: {"exists": "true"|"false", "arn": "<arn>"}
"""
import json
import subprocess
import sys

try:
    raw = sys.stdin.read()
    query = json.loads(raw) if raw.strip() else {}
except Exception:
    query = {}

account_id = query.get("account_id", "")
target_url = "token.actions.githubusercontent.com"
default_arn = f"arn:aws:iam::{account_id}:oidc-provider/{target_url}" if account_id else ""

arn_found = ""

# 1. Attempt lookup using boto3 if available
try:
    import boto3
    client = boto3.client("iam")
    providers = client.list_open_id_connect_providers().get("OpenIDConnectProviderList", [])
    for p in providers:
        arn = p.get("Arn", "")
        if arn.endswith(target_url):
            arn_found = arn
            break
except Exception:
    pass

# 2. Attempt fallback via AWS CLI
if not arn_found:
    try:
        cmd = [
            "aws",
            "iam",
            "list-open-id-connect-providers",
            "--query",
            f"OpenIDConnectProviderList[?ends_with(Arn, '{target_url}')].Arn | [0]",
            "--output",
            "text",
        ]
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        out = res.stdout.strip()
        if out and out != "None":
            arn_found = out
    except Exception:
        pass

if arn_found:
    print(json.dumps({"exists": "true", "arn": arn_found}))
else:
    print(json.dumps({"exists": "false", "arn": default_arn}))
