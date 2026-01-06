#!/bin/bash
echo "Verifying Cassandra Backup Ansible Setup..."
echo ""

# Check PEM file
if [ -f ~/Downloads/Mongodb.pem ]; then
    echo "✓ PEM file found"
    PERMS=$(stat -c %a ~/Downloads/Mongodb.pem 2>/dev/null || stat -f %A ~/Downloads/Mongodb.pem 2>/dev/null)
    if [ "$PERMS" = "400" ]; then
        echo "✓ PEM file permissions correct (400)"
    else
        echo "✗ PEM file permissions incorrect. Run: chmod 400 ~/Downloads/Mongodb.pem"
    fi
else
    echo "✗ PEM file not found at ~/Downloads/Mongodb.pem"
fi

echo ""
echo "Checking Ansible installation..."
if command -v ansible &> /dev/null; then
    echo "✓ Ansible installed: $(ansible --version | head -1)"
else
    echo "✗ Ansible not installed. Install with: pip install ansible"
fi

echo ""
echo "Checking required commands..."
for cmd in rsync ssh; do
    if command -v $cmd &> /dev/null; then
        echo "✓ $cmd installed"
    else
        echo "✗ $cmd not installed"
    fi
done

echo ""
echo "Testing node connectivity..."
ansible cassandra_nodes -m ping 2>/dev/null && echo "✓ All nodes reachable" || echo "✗ Cannot reach some nodes"

echo ""
echo "Setup verification complete!"
