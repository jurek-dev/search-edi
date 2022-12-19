# This script will search strings declared in array variable $unitsList in inside of directory declared in variable $rootPath.
# And, if choose option Yes, the script will save the all recovery files to $DestinationPath with a copy.

# Parameters of script
Param (
    [Parameter(Mandatory, HelpMessage = 'Please, provide a valid path')] # Next line is a mandatory parameter
    [string]$rootPath = './app', # This is a mandatory parameter. This is need inform path to do backup
    [Parameter(Mandatory, HelpMessage = 'Please, provide valid units. Example: ABC123, DFG456, ...')]
    [string[]]$unitsList,
    [string]$DestinationPath = 'C:\Users\david\Desktop\EDI_Files\' # Default directory to save copied items
)

# Verify if directory exists
If (-Not (Test-Path $rootPath))
{
    Throw "The source directory $rootPath does not exist, please specify an existing directory"
}

# Verify if contains files with .EDI extension in specified folder
Try
{
    $ContainsApplicationFiles = "$((Get-ChildItem $rootPath).Extension | Sort-Object -Unique)" -match '\.edi'
    If ( -Not $ContainsApplicationFiles) {
        Throw "The source directory $rootPath does not contains EDI file, please specify a valid directory"
    } Else {
        Write-Host "Source files it is okay."
    }
    } Catch {
        Throw "No backup created due to: $($_.Exception.Message)"
}

$filesList = Get-ChildItem $rootPath | Select-Object FullName # Get full name of files in directory
$dateTime = Get-Date -UFormat "%m-%d-%Y_%H-%M-%S" # Format actual date
#$robocopy = "ROBOCOPY " + $rootPath + $DestinationPath + $dateTime
$robocopy = "ROBOCOPY " + $rootPath + " .\Desktop\EDI_Files\" + $dateTime # Format ROBOCOPY to $robocopy variable
$filesFound = "N" # Declare variable $filesFound with 'N' value
forEach ($unit in $unitsList) {
    $unitFound = "False"
    ForEach ($filePath in $filesList) {
        $fileContent = Get-Content $filePath.FullName
        ForEach ($segment in $fileContent) {
            If($segment.Contains($unit) -eq "True") {
                $unitFound = "True"
                $filesFound = "Y"
                $logOut = $unit + " FOUND ON: " + $filePath.FullName
                Write-Host $logOut -foregroundcolor "green"
                $robocopy += ' "' + $filePath.FullName.Replace($rootPath,"") + '"'
                break
            }
        }
    }
    If($unitFound -eq "False") {
        $notFound = "#" + $unit + " NOT FOUND"
        Write-Host $notFound -foreground "red"
    }
}
If ($filesFound -eq "Y") {
    Write-Output "Do you want copy files to $DestinationPath ?"
    $copy = Read-Host "Type Y or N"
    If ($copy -eq "Y") {
        Invoke-Expression $robocopy
        Write-Host "The files will copied to $openFolder with succefull."

        # Compress Archive #
        $hahaha = '.\Desktop\EDI_Files\' + $dateTime
        Compress-Archive -Path $hahaha -DestinationPath "C:\Users\david\Documents\Microsoft\PowerShell\Desktop\EDI_Files\$dateTime"
        Remove-Item -Path $hahaha -Recurse
        Write-Host "Created a new copy and compress folder" -ForegroundColor Green

        # Open compacted folder
        $openFolder = "explorer .\Desktop\EDI_Files\" + $datetime +'.zip'
        Invoke-Expression $openFolder
    }
}

# Processment
#$DestinationFile = "$($DestinationPath + 'backup-' + $date + '.zip')"
#$date = Get-Date -format "yyy-MM-dd" # Date formater: 2022-12-17
#If( -Not (Test-Path $DestinationFile))
#{
#    Compress-Archive -Path $rootPath -CompressionLevel 'Fastest' -DestinationPath "$DestinationPath/backup-$date" # Compress the selected path and save in destination folder with name: backup-2022-12-12.
#    Write-Host "Created backup at $($DestinationPath + 'backup-' + $date + '.zip')" # Message to inform the user the backup had been succefull.
#} Else {
#    Write-Error "Today's backup already exists"
#}