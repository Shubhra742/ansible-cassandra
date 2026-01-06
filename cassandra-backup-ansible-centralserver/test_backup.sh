#!/bin/bash
echo "Running test backup for system_auth keyspace..."
ansible-playbook cassandra_backup.yml -e keyspace_name=system_auth
