# Required if running this code in a workstation
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# Define the domain name, paths, drive letter and source csv
$domain = "DC=sherwin-domain,DC=local"
$profilePath = "\\sherwin-dc1\Profiles\"
$homeDirectory = "\\sherwin-dc1\Users\"
$homeDriveLetter = "P:"
$csvPath = ".\ListEmployees.csv"

# Function to create Location OU
function CreateLocationOU($locationOU) {
    # try to create Location OU from based on the list of Locations    
    try {
        New-ADOrganizationalUnit -Name $locationOU -Path $domain -ErrorAction Stop
        Write-Host "Created Location OU: $locationOU" -ForegroundColor Green
    } 
    
    catch {
        # ignore these errors for readability since this will also appear in the creation of users
    }      
}

# Function to create Department OU under Location
function CreateDepartmentOU ($departmentOU, $ouLocationPath) {
    # try to create Department OU from based on the list of Departments    
    try {
        New-ADOrganizationalUnit -Name $departmentOU -Path $ouLocationPath -ErrorAction Stop
        Write-Host "Created Department OU: $departmentOU under $ouLocationPath" -ForegroundColor Green
    
    } catch {
        # ignore these errors for readability since this will also appear in the creation of users
    }
}

# Function to create the user
function CreateUser($user,$ouDepartmentPath) {
    # try to create the users and its profile paths and home directory
    try {
        New-ADUser -Name $user.Name `
            -GivenName $user.FirstName `
            -Surname $user.LastName `
            -UserPrincipalName "$($user.Username)@sherwin-domain.local" `
            -SamAccountName $user.Username `
            -EmailAddress $user.EmailAddress `
            -Path $ouDepartmentPath `
            -Enabled $true `
            -AccountPassword (ConvertTo-SecureString "S3curePass" -AsPlainText -Force) `
            -PasswordNeverExpires $true `
            -ProfilePath "$profilePath\$($user.Username)" `
            -HomeDrive $homeDriveLetter `
            -HomeDirectory "$homeDirectory\$($user.Username)" `
            -PassThru | Out-Null

        mkdir "$homeDirectory\$($user.Username)" | Out-Null

        Write-Host "Created user: $($user.Name) in OU: $ouDepartmentPath" -ForegroundColor Green
    } 
    # throw and error to the terminal if encountered any
    catch {
        Write-Host "Failed to create user $($user.Name). Error: $($_.Exception.Message)" -ForegroundColor Red 
    }
}

# Main function to process users
function ProcessUsers($csvPath) {

    # import the CSV file put the contents to users variable
    $users = Import-Csv -Path $csvPath 

    # loop thru each entries in the users to create the user profile
    foreach ($user in $users) {
        $locationOU = $user.Location    # get the location OU name from location column of csv
        $departmentOU = $user.Department # get the department OU name from location column of csv
        $ouLocationPath = "OU=$locationOU,$domain" # construct the location OU path
        $ouDepartmentPath = "OU=$departmentOU,$ouLocationPath" # construct the department OU path

        CreateLocationOU -locationOU $locationOU # create the locations in AD
        CreateDepartmentOU -departmentOU $departmentOU -ouLocationPath $ouLocationPath # create the departments per location in AD
        CreateUser -user $user -ouDepartmentPath $ouDepartmentPath # create the users per deparments in AD
    }

}

# Run the main function with the path to your CSV file
ProcessUsers($csvPath)
