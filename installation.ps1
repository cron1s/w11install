Clear-Host

#By PLE

#Global Param
$regex = "(ftp\.hp\.com/pub/softpaq/.*?/.*?exe)"
$TempDIR = "C:\Temp"
$TempDIRFA = "C:\Temp\1829371298037"
$TempDIRFAEXE = "C:\Temp\1829371298037\exe"
$Tempdw01 = "C:\Temp\1829371298037\dw01.txt"
$Tempdw02 = "C:\Temp\1829371298037\dw02.txt"
$Tempdw03 = "C:\Temp\1829371298037\dw03.txt"
$Tempdw04 = "C:\Temp\1829371298037\dw04.txt"
$Tempdw05 = "C:\Temp\1829371298037\dw05.txt"
$Tempdw06 = "C:\Temp\1829371298037\dw06.txt"
$Tempdw07 = "C:\Temp\1829371298037\dw07.txt"
$Tempdw08 = "C:\Temp\1829371298037\dw08.txt"

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
    Write-Host "1: Press '1' to Add Hostname"
    Write-Host "2: Press '2' to Join Domain RubnerGroup.Local"
    Write-Host "3: Press '3' to Join Workgroup"
    Write-Host "4: Press '4' to Start Installation (HP)"
    Write-Host "5: Press '5' to Start Installation (Lenovo)"
    Write-Host "6: Press '6' to Start Installation (Microsoft Cooperation)"
    Write-Host "Q: Press 'Q' to quit."
    Write-Host
}

Function Add_Hostname {
    $NewComputerName = Read-Host [Enter new hostname]
    Rename-Computer -NewName $NewComputerName
}
Function Join_Domain {
    $NewDomain = Read-Host [Enter new domain to join]
    Add-Computer -DomainName $NewDomain
}
Function Join_Workgroup {
    Write-Host pass
}
Function Start_Installation_HP {
    write-Host HP Notebook gets HP features -ForegroundColor white -BackgroundColor green
    write-Host ..........................................................................
    write-Host "Starting transfering the HP Support Assistant..."

    if (Test-Path -Path $TempDIR){
        Write-Host Script-INFO: C:\Temp exists -ForegroundColor Green
    }
    else {
        New-Item $TempDIR -ItemType Directory
        Write-Host Script-INFO: C:\Temp Directory created -ForegroundColor Green
    }
    if (Test-Path -Path $TempDIRFA){
    }
    else {
        New-Item $TempDIRFA -ItemType Directory 
    }
    if (Test-Path -Path $TempDIRFAEXE){
    }
    else {
        New-Item $TempDIRFAEXE -ItemType Directory 
    }
    
    Write-Host Script-INFO: Getting Information about the HP Support Assistant -ForegroundColor Green

    $hp = Invoke-WebRequest "https://hpsa-redirectors.hpcloud.hp.com/common/hpsaredirector.js?_=1663262489609" -UseBasicParsing -OutFile $Tempdw01
    
    Select-String -Path $Tempdw01 -Pattern 'ftp.hp.com/pub/softpaq' > $Tempdw02
    Select-String -Path $Tempdw02 -Pattern '//9','\.19' > $Tempdw03
    (gc $Tempdw03) | ? {$_.trim() -ne "" } | set-content $Tempdw03
    Get-Content $Tempdw03 -tail 1 > $Tempdw04
    Get-Content $Tempdw04 | 
        Select-String -Pattern $regex -AllMatches | 
        ForEach-Object {$_.matches.groups[1].value} | 
        Out-File $Tempdw05
    Get-Content $Tempdw05 | foreach {'https://' + $_} | Out-File $Tempdw06

    Write-Host Script-INFO: "Could fetch data from HP Servers" -ForegroundColor Green
    Write-Host ..........................................................................
    Write-Host Script-INFO: Download is starting soon -ForegroundColor Green
    start-sleep 3
    try {
        $hp_sa = Get-Content -Path $Tempdw06
        Start-BitsTransfer -Source $hp_sa -Destination $TempDIRFAEXE
        Get-ChildItem -Path $TempDIRFAEXE | Where { ! $_.PSIsContainer } | Select FullName | Out-File $Tempdw07
        (gc $Tempdw07) | ? {$_.trim() -ne "" } | set-content $Tempdw07
        Get-Content $Tempdw07 -tail 1 > $Tempdw08

        
        Write-Host Script-INFO: Download successfull. Filelocation: C:\Temp -ForegroundColor Green
        Write-Host ..........................................................................
        Write-Host Script-INFO: Installation of HP Support Assistant will start now -ForegroundColor Green
        $EXE = Get-Content -Path $Tempdw08
        Start-Process -FilePath $EXE -Verb runAs -ArgumentList '/s','/v"/qn"' -passthru
        Remove-Item "$TempDIRFA\*.*" -Force | Where { ! $_.PSIsContainer } 
    }
    catch {
        Write-Host "Script-INFO: Error downloading Information Support Assistant" -ForegroundColor white -BackgroundColor red
        exit
    }
        
    

    try {
        Export-StartLayout -Path "$TempDIRFA\LayoutModification.json" 
    }
    catch {
        Write-Host 1
    }

}

Function Start_Installation_Lenovo {
    pass
}
Function Start_Installation_MS {
    pass
}

function Uninstall_Software {
    Write-Host  Test
}

do {
    Show-Menu
    $input = Read-Host "Please make a selection"
    Clear-Host
    switch ($input) {
        '1' {Add_Hostname;break}
        '2' {Join_Domain;break}
        '3' {Join_Workgroup;break}
        '4' {Start_Installation_HP;break}
        '5' {Start_Installation_Lenovo;break}
        '6' {Start_Installation_MS;break}
        'q' {break}
        default{
            Write-Host "You entered '$input'" -ForegroundColor Red
            Write-Host "Please select one of the choices from the menu." -ForegroundColor Red}
        
    
    }
    Pause
} until ($input -eq 'q')
