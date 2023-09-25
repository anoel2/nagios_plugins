#!/bin/bash
#Install and configure NRPE on remote host
# Set Variables
nagios_ip=""
check_name=""
check_path=""
check_command=""

# Check if the `nagios` user exists and create it if necessary
if id "nagios" >/dev/null 2>&1; then
    echo "User 'nagios' already exists, skipping creation."
else
    echo "Creating 'nagios' user..."
    useradd nagios
fi

# Check the permissions on the sudoers file before adding a new entry
sudoers_file='/etc/sudoers'
if grep -q "nagios ALL=(ALL) NOPASSWD:$check_path" $sudoers_file; then
    echo "Sudoers entry for 'nagios' user already exists, skipping update."
else
    echo "Updating sudoers file..."
    chmod 0640 $sudoers_file      # Change permissions to make sudoers readonly for non-root users
    echo "nagios ALL=(ALL) NOPASSWD:$check_path" >> $sudoers_file
fi

# Install NRPE and configure
echo "Installing NRPE and Nagios plugins..."
sudo yum install nrpe nagios-plugins-nrpe -y
echo "allowed_hosts=$nagios_ip" >> /etc/nagios/nrpe.cfg
echo "command[$check_name]=$check_path $check_command" >> /etc/nagios/nrpe.cfg

# Restart the NRPE service
echo "Restarting NRPE service..."
systemctl restart nrpe
systemctl enable nrpe

echo "NRPE configured successfully!"
