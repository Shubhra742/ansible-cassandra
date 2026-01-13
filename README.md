# Cassandra Ansible Automation

Complete automation suite for Apache Cassandra 4.1.x deployment and management.

---

## Repository Structure

```
cassandra-ansible/
├── cassandra-local-installation/          # Single-node installation
├── cassandra-cluster/                     # Simple multi-node cluster
├── multi-dc-cassandra-ansible/            # Multi-datacenter cluster
├── jmx_authentication/                    # JMX authentication
├── Internode_ssl_setup/                   # Node-to-node SSL/TLS
├── client_to_node_ssl/                    # Client-to-node SSL/TLS
├── backup/                                # Snapshot backups
├── restore/                               # Restore from snapshots
├── cassandra-backup-ansible-centralserver/  # Centralized backup
└── cassandra_restore/                     # Centralized restore
```

---

## Quick Start Guide

### 1. Single-Node Installation

**Directory:** `cassandra-local-installation/`

```bash
cd cassandra-local-installation/
ansible-playbook -i hosts.ini install_cassandra.yml
```

**Inventory (`hosts.ini`):**
```ini
[local]
localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python3
```

**Verify:**
```bash
nodetool status
```

---

### 2. Simple Cluster Setup

**Directory:** `cassandra-cluster/`

```bash
cd cassandra-cluster/
ansible-playbook -i inventory.ini cassandra-cluster-setup.yml
```

**Inventory (`inventory.ini`):**
```ini
[cassandra_nodes]
node1 ansible_host=10.0.1.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/key.pem
node2 ansible_host=10.0.1.11 ansible_user=ubuntu ansible_ssh_private_key_file=~/key.pem

[cassandra_seeds]
node1

[cassandra_nodes:vars]
ansible_python_interpreter=/usr/bin/python3
```


### 3. Multi-DC Cluster

**Directory:** `multi-dc-cassandra-ansible/`

```bash
cd multi-dc-cassandra-ansible/
ansible-playbook -i inventories/production/hosts.yml playbooks/deploy_multi_dc.yml
```

**Inventory (`inventories/production/hosts.yml`):**
```yaml
all:
  children:
    cassandra_cluster:
      children:
        dc1:
          hosts:
            cassandra-dc1-node1:
              ansible_host: 10.0.1.10
              cassandra_seeds: "10.0.1.10,10.0.2.10"
              datacenter: DC1
              rack: RAC1
        dc2:
          hosts:
            cassandra-dc2-node1:
              ansible_host: 10.0.2.10
              cassandra_seeds: "10.0.1.10,10.0.2.10"
              datacenter: DC2
              rack: RAC1
```


---

### 4. JMX Authentication

**Directory:** `jmx_authentication/`

```bash
cd jmx_authentication/
ansible-playbook -i inventory.ini playbook.yml
```

**After setup:**
```bash
nodetool -u cassandra -pw cassandra_password status
```

**Default credentials:**
- Username: `cassandra`
- Password: `cassandra_password`

⚠️ **Change passwords for production!**

---

### 5. Internode SSL/TLS

**Directory:** `Internode_ssl_setup/`

```bash
cd Internode_ssl_setup/
ansible-playbook -i inventory_ssl.ini cassandra_ssl_setup.yml
```

**Inventory (`inventory_ssl.ini`):**
```ini
[seed_node]
node1 ansible_host=10.0.1.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/key.pem

[cassandra_nodes]
node1 ansible_host=10.0.1.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/key.pem
node2 ansible_host=10.0.1.11 ansible_user=ubuntu ansible_ssh_private_key_file=~/key.pem

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

⚠️ **Requires full cluster restart (5-15 min downtime)**

**Verify:**
```bash
sudo tail -100 /var/log/cassandra/system.log | grep "encryption = encrypted"
```

---

### 6. Client-to-Node SSL/TLS

**Directory:** `client_to_node_ssl/`

```bash
cd client_to_node_ssl/
ansible-playbook -i inventory_ssl.ini site.yml
```

**After setup:**
```bash
# Connect with SSL
cqlsh localhost 9142 --ssl

# Non-SSL still works (optional)
cqlsh localhost 9042
```

**Ports:**
- `9042` - Non-SSL (optional)
- `9142` - SSL (encrypted)

---

### 7. Backup (Snapshots)

**Directory:** `backup/`

```bash
cd backup/

# All keyspaces
ansible-playbook -i inventory.ini snapshot.yml

# Specific keyspace
ansible-playbook -i inventory.ini snapshot.yml -e "keyspace=my_keyspace"

# Custom snapshot name
ansible-playbook -i inventory.ini snapshot.yml -e "snapshot_name=before_upgrade"
```

**List snapshots:**
```bash
nodetool listsnapshots
```

**Delete snapshot:**
```bash
nodetool clearsnapshot -t snapshot_name
```

---


### 8. Centralized Backup

**Directory:** `cassandra-backup-ansible-centralserver/`

```bash
cd cassandra-backup-ansible-centralserver/
ansible-playbook -i inventory.ini backup-playbook.yml
```

Backs up all nodes to a central backup server.

---
