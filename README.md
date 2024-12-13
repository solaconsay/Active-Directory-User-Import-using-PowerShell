# Active Directory Automation Script

This PowerShell script automates the creation of organizational units (OUs) and user accounts in Active Directory based on data from a CSV file. It organizes users by location and department and sets up user-specific paths and directories.

## Prerequisites

### Set Execution Policy
Ensure the script can run by setting PowerShell's execution policy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

### Permissions
Administrative privileges are required to create OUs and users in Active Directory.

## Script Details

### Configuration
- **Domain Name**: Define your domain's distinguished name.
- **Profile and Home Directories**: Customize the paths for user profile and home directories.
- **CSV Path**: Specify the location of the CSV file that contains user information.

### CSV Structure
The script expects the CSV file (`ListEmployees.csv`) to have the following columns:
- `Location`: OU for the user's location
- `Department`: OU for the user's department
- `Name`: Full name of the user
- `FirstName` and `LastName`: User’s first and last names
- `EmailAddress`: User’s email
- `Username`: Username for Active Directory

### Script Functions
1. **CreateLocationOU**: Creates Location OUs based on data in the `Location` column.
2. **CreateDepartmentOU**: Adds Department OUs within Location OUs.
3. **CreateUser**: Adds a new user to the appropriate Department OU, with assigned profile and home directories.
4. **ProcessUsers**: Reads from the CSV file and calls the above functions to create the OUs and users.

## Usage

1. **Define Variables**: Modify the script's initial variables to fit your AD structure.
2. **Run Script**: Execute the script in PowerShell:
   ```powershell
   .\your_script_name.ps1
   ```

## Example Output
- Location and Department OUs will be created if they do not exist.
- New users will be created with profile paths and home directories set.

## Error Handling
Errors during the creation of users or OUs will be displayed in red in the console.
