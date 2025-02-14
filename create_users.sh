#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Use: $0 <filename>"
    exit 1
fi
FILENAME=$1
mkdir -p /var/secure
PASSFILE="/var/secure/user_passwords.txt"
touch $PASSFILE
chmod 600 $PASSFILE
mkdir -p /var/log
LOGFILE="/var/log/user_management.log"
touch $LOGFILE
chmod 644 /var/log/user_management.log
echo "User management started at $(date)" > $LOGFILE


while IFS=';' read -r username groups; do
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)
    if [ -z "$username" ]; then
        continue
    fi
    if id -u "$username"; then
        echo "User $username already exists" | tee -a $LOGFILE
    else
        useradd -m -s /bin/bash -U "$username"
        echo "User $username created with personal group $username" | tee -a $LOGFILE
    fi
    IFS=',' read -r -a group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        if ! getent group "$group" >/dev/null 2>&1; then
            groupadd "$group"
            echo "Group $group created" | tee -a $LOGFILE
        fi
        usermod -aG "$group" "$username"
        echo "User $username added to group $group" | tee -a $LOGFILE
    done


    password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd
    echo "Password set for user $username" | tee -a $LOGFILE
    echo "$username,$password" >> $PASSFILE
done < "$FILENAME"
echo "User management completed at $(date)" | tee -a $LOGFILE
