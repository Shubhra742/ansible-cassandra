# Cassandra Backup Ansible Project

## Overview
This Ansible project automates Cassandra database backups across multiple nodes and centralizes them on a backup server.

## Directory Structure
```
cassandra-backup-ansible/
├── ansible.cfg
├── cassandra_backup.yml
├── inventory/
│   └── hosts.yml
├── roles/
│   ├── cassandra_backup_prepare/
│   ├── cassandra_snapshot/
│   ├── cassandra_backup_copy/
│   └── cassandra_snapshot_cleanup/
└── logs/
```

## Prerequisites
1. Ansible 2.9 or higher
2. SSH access to all Cassandra nodes
3. PEM file at ~/Downloads/Mongodb.pem with correct permissions (chmod 400)
4. rsync installed on all nodes

## Quick Start

### 1. Test connectivity
```bash
ansible cassandra_nodes -m ping
```

### 2. Backup all keyspaces
```bash
ansible-playbook cassandra_backup.yml -e keyspace_name=all
```

### 3. Backup specific keyspace
```bash
ansible-playbook cassandra_backup.yml -e keyspace_name=system_auth
```

## Configuration

Edit `inventory/hosts.yml` to customize:
- Node IPs/hostnames
- SSH credentials
- Backup directories
- Retention policies

## Backup Structure
```
/home/ec2-user/backup_cassandra/
└── node-<IP>/
    └── YYYYMMDD/
        └── HHMMSS/
            └── keyspace/
                └── table-snapshot_YYYYMMDD_HHMMSS/
```

## Logs
Located at: `/tmp/cassandra_backup/backup_<YYYYMMDD>_<HHMMSS>.log`

## Troubleshooting

### SSH Issues
```bash
chmod 400 ~/Downloads/Mongodb.pem
ssh -i ~/Downloads/Mongodb.pem ubuntu@<node-ip>
```

### Check Cassandra Status
```bash
ansible cassandra_nodes -m shell -a "nodetool status"
```

### View Logs
```bash
tail -f /tmp/cassandra_backup/backup_*.log
```

## Scheduling

Add to crontab for daily backups:
```bash
0 2 * * * cd /path/to/cassandra-backup-ansible && ansible-playbook cassandra_backup.yml -e keyspace_name=all >> /var/log/cassandra_backup_cron.log 2>&1
```
