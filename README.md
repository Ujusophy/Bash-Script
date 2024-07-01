# Detailed explanation of the script.

# START BASH
- Shebang line that tells the system to run this script using the Bash shell.
'''
#!/bin/bash
'''

# NUM. OF ARGUMENT
- Checks if exactly one argument (the filename) is provided. This is for error handling.
- If the argument is not equal to one, then print Use: create_users.sh <filename>.” to show you the correct way of running the task.
- exit 1:  This line stops running the script because something is wrong.
- If you run the script with ./create_users.sh myfile.txt, $1 is myfile.txt
'''
if [ $# -ne 1 ]; then
    echo "Use: $0 <filename>"
    exit 1
fi
FILENAME=$1
'''

# CREATE PASSWORD FILE AND PERMISSIONS
- Create a directory /var/secure
- Sets up the path for the password file PASSFILE="/var/secure/user_passwords.txt
- Then create an empty file touch $PASSFILE
- Sets permissions for the password file chmod 600 $PASSFILE ensuring that only the owner can read and write to the file.
'''
mkdir -p /var/secure
PASSFILE="/var/secure/user_passwords.txt"
touch $PASSFILE
chmod 600 $PASSFILE
'''

# CREATE LOG FILE AND PERMISSIONS
- Create a directory /var/log
- Sets up the path for the password file LOGFILE="/var/log/user_management.LOG
- Then create an empty file touch $LOGFILE
- Give read permission to user and others (Everyone needs to be able to access the log), - - while owner will be given read and write permission. chmod 644 $LOGFILE
'''
mkdir -p /var/log
LOGFILE="/var/log/user_management.log"
touch $LOGFILE
chmod 644 /var/log/user_management.log
'''

# STARTING PROCESS
- Initializes the $LOGFILE with a start message, indicating the start time of the user management process.
'''
echo "User management started at $(date)" > $LOGFILE
'''

# READ FILE
- Start a loop that reads a line from the $FILENAME, splits it into two parts based on IFS.
- Assign the first part to username and the remaining parts to groups .
- The xargs command is use to remove any leading or trailing whitespace from username or groups.
'''
while IFS=';' read -r username groups; do
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)
    '''
  
- Checks if $username is empty and skip to the next line in the file. This is part of error handling.
'''
if [ $# -ne 1 ]; then
        continue
    fi
    '''
    
# USER
- Check if the user already exist.
- If the user exists, it logs that the user already exists.
- If the user does not exist, it creates the user, with the personal group and log it.
'''
if id -u "$username"; then
        echo "User $username already exists" | tee -a $LOGFILE
    else
        useradd -m -s /bin/bash -U "$username"
        echo "User $username created with personal group $username" | tee -a $LOGFILE
    fi
    '''

# GROUPS
- Splits the groups string by , into an array called group_array.
- IFS=',' read -r -a group_array <<< "$groups"
- Check if the group in the array already exist in the database.
- If it does not, create a $group and log.
- Add $username to the group without removing them from other groups and log.
'''
for group in "${group_array[@]}"; do
        if ! getent group "$group" >/dev/null 2>&1; then
            groupadd "$group"
            echo "Group $group created" | tee -a $LOGFILE
        fi
        usermod -aG "$group" "$username"
        echo "User $username added to group $group" | tee -a $LOGFILE
    done
    '''

  # PASSWORDS
- Generate random password for
- Sets the password for $username to the value stored in $password
- Print message to show password has been set.
- Then store the user and password to the $PASSFILE.
- Ends the loop after processing all lines in the file
'''
password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd
    echo "Password set for user $username" | tee -a $LOGFILE
    echo "$username,$password" >> $PASSFILE
done < "$FILENAME"

# END PROCESS
'''
- Logs a message indicating the completion of user management, appending it to $LOGFILE
'''
echo "User management completed at $(date)" | tee -a $LOGFILE
'''
