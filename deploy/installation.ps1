Clear-Host

#By PLE


#Global Param
$regex = "(ftp\.hp\.com/pub/softpaq/.*?/.*?exe)"
$TempDIR = "C:\Temp"
$TempDIRFA = "C:\Temp\1829371298037"
$TempDIRFADATA = "C:\Temp\1829371298037\data"
$TempDIRFAEXE = "C:\Temp\1829371298037\exe"
$Tempdw01 = "C:\Temp\1829371298037\dw01.txt"
$Tempdw02 = "C:\Temp\1829371298037\dw02.txt"
$Tempdw03 = "C:\Temp\1829371298037\dw03.txt"
$Tempdw04 = "C:\Temp\1829371298037\dw04.txt"
$Tempdw05 = "C:\Temp\1829371298037\dw05.txt"
$Tempdw06 = "C:\Temp\1829371298037\dw06.txt"
$Tempdw07 = "C:\Temp\1829371298037\dw07.txt"
$Tempdw08 = "C:\Temp\1829371298037\dw08.txt"
$Default_User_ModificationFile = "C:\Users\Default"
$Admin_User_ModificationFile = "$TempDIRFADATA\w11-install-main\Users"
$Start_bin_Dir = "$TempDIRFADATA\w11install-main\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
$Appdata_Start_bin_Dir = "AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
$User_Dir = "C:\Users"
$Admin_Dir = "C:\Users\Administrator"
$Start_bin_Source = "https://github.com/cron1s/w11install/archive/refs/heads/main.zip"
$Computername = hostname
$Domainname = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select Domain
$Current_User_Name = [System.Environment]::UserName

function Show-Menu {
    param (
        [string]$Title = 'Choose Which  to Start'
    )
    Clear-Host
    Clear-Host
    Write-Host 'Skript fuer Rechnerneuinstallationen startet'  -ForegroundColor Black -BackgroundColor green
    Write-Host ............................................................
    Write-Host * Computer-Information * -ForegroundColor Black -BackgroundColor green
    Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem
    Write-Host ............................................................
    Write-Host "================ $Title ================"
    Write-Host "1: Press '1' to Step 1"
    Write-Host "2: Press '2' to Step 2"
    Write-Host "3: Press '3' to Step 3"
    #Write-Host "4: Press '4' for Step 1"
    #Write-Host "5: Press '5' for Step 2"
    #Write-Host "6: Press '6' for Step 3"
    Write-Host "Q: Press 'Q' to quit."
    Write-Host
}

Function First_Step {

    Write-Host "Before the script can start, it needs some informations:"
    Write-Host ...............................................................................
    Write-Host "Domainname (Currently set: $Domainname"
    $NewDomainName = Read-Host "Enter the new Domainname:"
    Write-Host ...............................................................................
    Write-Host "Computername (Currently set: $Computername)"
    $NewComputerName = Read-Host "Enter the new Computername:"
    Write-Host ...............................................................................
    Write-Host "The local Administrator-Password"
    $Admin_Pass_PA = Read-Host -AsSecureString "Computername - $NewComputerName `nEnter Password for Administrator"
    Write-Host ...............................................................................
    Clear-Host
    Write-Host ...........................................................................................................
    Write-Host "The Script will begin the Setup now."
    Write-Host ...........................................................................................................
    Start-Sleep 3
    


    if (Test-Path -Path $TempDIR){
        Write-Host "C:\Temp exists" -ForegroundColor Green
    }
    else {
        New-Item $TempDIR -ItemType Directory
        Write-Host "C:\Temp Directory created" -ForegroundColor Green
    }
    if (Test-Path -Path $TempDIRFA){
    }
    else {
        New-Item $TempDIRFA -ItemType Directory 
    }
    if (Test-Path -Path $TempDIRFADATA){
    }
    else {
        New-Item $TempDIRFADATA -ItemType Directory 
    }
    if (Test-Path -Path $TempDIRFAEXE){
    }
    else {
        New-Item $TempDIRFAEXE -ItemType Directory 
    }
    
    #Start.bin Configuration on Local Logged-On User and Default User
    try {
        Write-Host "Getting Modification File for the Start Layout" -ForegroundColor white -BackgroundColor Green
        $client = new-object System.Net.Webclient
        $client.DownloadFile("$Start_bin_Source", "$TempDIRFADATA\Pack.zip")
        Expand-Archive -Path "$TempDIRFADATA\pack.zip" -DestinationPath $TempDIRFADATA -Force
        
        Start-Sleep 10
        Write-Host "Modification File Download success" -ForegroundColor white -BackgroundColor Green
        Write-Host "Beginning to applying start.bin" -ForegroundColor white -BackgroundColor Green
        $Current_User_ModificationFile = "C:\Users\$Current_User_Name"
        try {
            Write-Host "Beginning to applying start.bin to DefaultUser" -ForegroundColor Green
            robocopy "$Start_bin_Dir" "$Default_User_ModificationFile\$Appdata_Start_bin_Dir" /MIR /LOG:$TempDIRFADATA\log_default.txt
        }
        catch {
            Write-Host "Error applying start_bin to DefaultUser" -ForegroundColor white -BackgroundColor Red
        }
        try {
            Write-Host "Beginning to applying start.bin to CurrentUser" -ForegroundColor Green
            robocopy "$Start_bin_Dir" "$Current_User_ModificationFile\$Appdata_Start_bin_Dir" /MIR /LOG:$TempDIRFADATA\log_current.txt
        }
        catch {
            Write-Host "Error applying start_bin to CurrentUser" -ForegroundColor white -BackgroundColor Red
        }
        try {
            if (Test-Path -Path "$User_Dir\Administrator"){
            }
            else {
                New-Item $Admin_Dir -ItemType Directory 
            }
            Write-Host "Beginning to applying start.bin to AdministratorUser" -ForegroundColor Green
            robocopy "$Admin_User_ModificationFile" "$User_Dir" /MIR /LOG:$TempDIRFADATA\log_admin.txt
        }
        catch {
            Write-Host "Error applying start_bin to AdministratorUser" -ForegroundColor white -BackgroundColor Red
        }
        

    }
    catch {
        Write-Host "Modification File is not available. Exiting Modification" -ForegroundColor white -BackgroundColor red
    }

    #Activiating the Administrator Account and Set Password
    try {
        Enable-LocalUser -Name "Administrator"
        Set-LocalUser -Name "Administrator" -Password $Admin_Pass_PA -PasswordNeverExpires 1 -AccountNeverExpires
        Write-Host "Administrator activated" -ForegroundColor white -BackgroundColor Green
        Start-Sleep 3
    }
    catch {
        Write-Host "Error activating administrator" -ForegroundColor white -BackgroundColor red
    }

    #Change Hostname
    try {
        Rename-Computer -NewName $NewComputerName
        Write-Host "Computername $NewComputerName has been set. Restart after progress"
    }
    catch {
        Write-Host "Error renaming computer." -ForegroundColor white -BackgroundColor red
    }

    #Joining Domain
    try {
        Add-Computer -DomainName $NewDomainName
        Write-Host "Domain $NewDomainName has been joined. Restart after progress"
    }
    catch {
        Write-Host "Error joining $NewDomainName" -ForegroundColor white -BackgroundColor red
    }

    
    Write-Host ...........................................................................................................
    Write-Host "This part is finished. `nCleanup-Process will beginn now."
    Write-Host ...........................................................................................................
    Start-Sleep 7

    try {
        Write-Host "Cleanup is in progress" -ForegroundColor white
        Start-Sleep 3
        Remove-Item -LiteralPath "$TempDIRFA" -Force -Recurse
        Write-Host "Cleanup success" -ForegroundColor white -BackgroundColor Green
    }
    catch {
        Write-Host "Problem with cleanup" -ForegroundColor white -BackgroundColor Green
    }

    try {
        Write-Host "Please login to the Administrator-Profile and proceed with Step 2" -ForegroundColor Red
        $confirmation = Read-Host "Do you want to log off? `nPress 'y' for yes or anything else for no"
        if ($confirmation -eq 'y') {
            Write-Host "Logging off..."
            Start-Sleep 10
            quser | Select-Object -Skip 1 | ForEach-Object {
                $id = ($_ -split ' +')[-5]
                logoff $id 
            }
        }
        else {
            break
        }

    }
    catch {
        if ($confirmation -eq 'y') {
            Write-Host "Logging off..."
            Start-Sleep 10
            quser | Select-Object -Skip 1 | ForEach-Object {
                $id = ($_ -split ' +')[-6]
                logoff $id 
            }
        }
        else {
            break
        }
    }
}

Function Second_Step {
    Clear-Host
        Write-Host "-----------------------------------------------------"
        Write-Host "Creating local temp files and folders" -ForegroundColor White 
        Write-Host "-----------------------------------------------------"
        
    if (Test-Path -Path $TempDIR){
        Write-Host 
        Write-Host "Existing Dir: $TempDIR" -ForegroundColor White 
    }
    else {
        New-Item $TempDIR -ItemType Directory
        Write-Host 
        Write-Host "Created Dir: $TempDIR" -ForegroundColor White 
    }
    if (Test-Path -Path $TempDIRFA){
        Write-Host "Existing Dir: $TempDIRFA" -ForegroundColor White 
    }
    else {
        New-Item $TempDIRFA -ItemType Directory 
        Write-Host "Created Dir: $TempDIRFA" -ForegroundColor White
    }
    if (Test-Path -Path $TempDIRFADATA){
        Write-Host "Existing Dir: $TempDIRFADATA" -ForegroundColor White 
    }
    else {
        New-Item $TempDIRFADATA -ItemType Directory
        Write-Host "Created Dir: $TempDIRFADATA" -ForegroundColor White
    }

    if (Test-Path -Path $TempDIRFAEXE){
        Write-Host "Existing Dir: $TEMPDIRFAEXE" -ForegroundColor White 
    }
    else {
        New-Item $TempDIRFAEXE -ItemType Directory 
        Write-Host "Created Dir: $TEMPDIRFAEXE" -ForegroundColor White
    }

    Write-Host "-----------------------------------------------------"
    Write-Host "Finished creating necessery Directorys" -ForegroundColor White 
    Write-Host "-----------------------------------------------------"
    
    #Remove Local Account
    try {

        Write-Host "Listing Information about local Accounts" -ForegroundColor Green
        Write-Host "-----------------------------------------------------"
        $LocalUser = Get-WmiObject -ComputerName $Computername -Class Win32_UserAccount -Filter "LocalAccount=True" | 
        Select Name, Status, Disabled | Out-Host
        Write-Host "-----------------------------------------------------"
        Write-Host "Remove local Accounts if necessary" -ForegroundColor Green
        Write-Host "-----------------------------------------------------"
        $RM_Local_User = Read-Host "Enter User to Remove"
        $Check_Local_User = Get-LocalUser | Where-Object {$_.Name -eq $RM_Local_User}
        if ( -not $Check_Local_User)
            {
            Clear-Host
            Write-Host "-----------------------------------------------------"
            Write-Host "Account $RM_Local_User not removed. Not found" -ForegroundColor White -BackGroundColor Red
            Write-Host "-----------------------------------------------------"
            break
            }
        else {
            Remove-LocalUser -Name $RM_Local_User 
        }
        Start-Sleep 2
        Clear-Host
        Write-Host "-----------------------------------------------------"
        Write-Host "Account $RM_Local_User removed" -ForegroundColor White -BackGroundColor Green
        Write-Host "-----------------------------------------------------"

    }
    catch {
        Clear-Host
        Write-Host "-----------------------------------------------------"
        Write-Host "Account $RM_Local_User not removed. Error" -ForegroundColor White -BackGroundColor Red
        Write-Host "-----------------------------------------------------"
    }
    

    #Installation of HP Support Assistant
    Clear-Host
    Write-Host "-----------------------------------------------------"
    Write-Host "HP Notebook gets HP Support Assistant installed" -ForegroundColor Green
    Write-Host "-----------------------------------------------------"
    Write-Host "Starting transfering the HP Support Assistant..." -ForegroundColor white
    Write-Host "Getting Information about the HP Support Assistant" -ForegroundColor Green
    Start-Sleep 1
    Write-Host "-----------------------------------------------------"
    Write-Host "Writing to Files" -ForegroundColor Green

    $hp = Invoke-WebRequest "https://hpsa-redirectors.hpcloud.hp.com/common/hpsaredirector.js?_=1663262489609" -UseBasicParsing -OutFile $Tempdw01
    (Get-Content -path $Tempdw01 -Raw) -replace '//return','' | set-content $Tempdw01 #Strings too long, we need to get rid of text
    (Get-Content -path $Tempdw01 -Raw) -replace 'getProtocol()','' | set-content $Tempdw01   
    Select-String -Path $Tempdw01 -Pattern 'ftp.hp.com/pub/softpaq' > $Tempdw02
    (Get-Content -path $Tempdw01 -Raw) -replace '1829371298037','' | set-content $Tempdw01  
    Select-String -Path $Tempdw02 -Pattern '//9','\.19' > $Tempdw03
    (gc $Tempdw03) | ? {$_.trim() -ne "" } | set-content $Tempdw03
    Get-Content $Tempdw03 -tail 1 > $Tempdw04
    Get-Content $Tempdw04 | 
        Select-String -Pattern $regex -AllMatches | 
        ForEach-Object {$_.matches.groups[1].value} |   
        Out-File $Tempdw05
    Get-Content $Tempdw05 | foreach {'https://' + $_} | Out-File $Tempdw06

    Write-Host "Could fetch data from HP Servers" -ForegroundColor Green
    Write-Host ..........................................................................
    Write-Host "Download is starting soon" -ForegroundColor Green
    start-sleep 3
    try {
        $hp_sa = Get-Content -Path $Tempdw06
        Start-BitsTransfer -Source $hp_sa -Destination $TempDIRFAEXE
        Get-ChildItem -Path $TempDIRFAEXE | Where { ! $_.PSIsContainer } | Select FullName | Out-File $Tempdw07
        (gc $Tempdw07) | ? {$_.trim() -ne "" } | set-content $Tempdw07
        Get-Content $Tempdw07 -tail 1 > $Tempdw08

        Write-Host "Download successfull. Filelocation: C:\Temp" -ForegroundColor Green
        Write-Host ..........................................................................
        Write-Host "Installation of HP Support Assistant will start now" -ForegroundColor Green
        Write-Host "Please have patience" -ForegroundColor Green
        Start-Sleep 3
        $EXE = Get-Content -Path $Tempdw08
        Start-Process -FilePath $EXE -Verb runAs -Wait 
    }
    catch {
        Write-Host "Error downloading Information Support Assistant" -ForegroundColor white -BackgroundColor red
        Write-Host "Script will proceed without HP Support Assistant" -ForegroundColor white -BackgroundColor Yellow
        Start-Sleep 5
    }



    try {
        Write-Host "Cleanup is in progress" -ForegroundColor white
        Start-Sleep 3
        Remove-Item -LiteralPath "$TempDIRFA" -Force -Recurse
        Write-Host "Cleanup success" -ForegroundColor white -BackgroundColor Green
    }
    catch {
        Write-Host "Problem with cleanup" -ForegroundColor white -BackgroundColor Green
    }
}
Function Third_Step {
    
}

do {
    Show-Menu
    $input = Read-Host "Please make a selection"
    Clear-Host
    switch ($input) {
        '1' {First_Step;break}
        '2' {Second_Step;break}
        '3' {Third_Step;break}
        #'4' {First_Step;break}
        #'5' {Second_Step;break}
        #'6' {Third_Step;break}
        'q' {break}
        default{
            Write-Host "You entered '$input'" -ForegroundColor Red
            Write-Host "Please select one of the choices from the menu." -ForegroundColor Red}
        
    
    }
    Pause
} until ($input -eq 'q')
