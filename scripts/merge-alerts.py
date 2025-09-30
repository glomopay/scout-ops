#!/usr/bin/env python3
"""
Merge existing alert rules from Grafana with new alert rules.
Ensures existing alerts are preserved while updating/adding new ones.

Usage: python3 scripts/merge-alerts.py
"""

import json
import os
from pathlib import Path


def load_json_file(filepath):
    """Load JSON file."""
    with open(filepath, 'r') as f:
        return json.load(f)


def merge_alert_rules(existing_rules, new_rules):
    new_rules_by_title = {rule['title']: rule for rule in new_rules}

    merged = []

    # Keep existing rules that aren't being updated
    for rule in existing_rules:
        if rule['title'] not in new_rules_by_title:
            merged.append(rule)

    # Add all new rules (includes updates and new ones)
    merged.extend(new_rules)

    return merged


def main():
    existing_dir = "existing-alerts"
    resources_file = "resources.json"
    # Load new resources
    if not os.path.exists(resources_file):
        print(f"❌ Error: {resources_file} not found")
        return 1

    resources = load_json_file(resources_file)

    if not isinstance(resources, list):
        print(f"❌ Error: Expected list in {resources_file}")
        return 1

    # Process each alert rule group
    for resource in resources:
        if resource.get('kind') != 'AlertRuleGroup':
            continue

        group_name = resource['spec']['title']
        folder_uid = resource['spec']['folderUid']
        new_rules = resource['spec']['rules']

        # Find existing alert group file
        existing_file = f"{existing_dir}/alert-rules/alertRuleGroup-{folder_uid}.{group_name}.json"

        if os.path.exists(existing_file):
            existing = load_json_file(existing_file)
            existing_rules = existing.get('spec', {}).get('rules', [])

            # Merge rules
            merged_rules = merge_alert_rules(existing_rules, new_rules)
            resource['spec']['rules'] = merged_rules

            print(f"   ✅ Merged: {len(merged_rules)} rules for the rule group **{group_name}**")
        else:
            print(f"   ℹ️  No existing rules - using new rules only for the rule group **{group_name}**")

    # Save merged resources
    with open(resources_file, 'w') as f:
        json.dump(resources, f, indent=2)

    return 0


if __name__ == '__main__':
    exit(main())