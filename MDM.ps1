# author: eva mead
# date: 06 march 2023
# purpose: remove mobile devices from terminated users parsed from MDM report
# 
# REMOVE THE -WHATIF WHEN YOU'RE READY TO DELETE
# 
# gather MDM report with:
# 
#   Get-Mailbox -ResultSize Unlimited | 
#       ForEach {Get-MobileDeviceStatistics -Mailbox:$_.Identity} | 
#       Select-Object @{label=”User” ; expression={$_.Identity}},DeviceModel,DeviceOS, lastsuccesssync | 
#       Export-csv ./MDM_export.csv

# this function makes pretty colors in the shell - thanks for the inspiration, matt@stackoverflow :)
function RAND_COLORS{
    param([string]$Text)
    $Text.ToCharArray() | ForEach-Object{
        switch -Regex ($_){
            # ignore `n
            "`r"{
                break
                }
            # Start a new line
            "`n"{
                Write-Host " ";break
                }
            # random colors for non-space
            "[^ ]"{
                # put colors as output
                $writeHostOptions = @{
                    ForegroundColor = ([system.enum]::GetValues([system.consolecolor])) | get-random
                    # BackgroundColor = ([system.enum]::GetValues([system.consolecolor])) | get-random
                    NoNewLine = $true
                }
                Write-Host $_ @writeHostOptions
                break
            }
            " "{Write-Host " " -NoNewline}
        } 
    }
}

# introduction to the program - contains instructions
function GREETINGS_MORTAL{
    RAND_COLORS "=====================================================`n┌┬┐┌┬┐┌┬┐  ┌┬┐┌─┐┬  ┬┬┌─┐┌─┐  ┬─┐┌─┐┌┬┐┌─┐┬  ┬┌─┐┬─┐`n│││ │││││   ││├┤ └┐┌┘││  ├┤   ├┬┘├┤ ││││ │└┐┌┘├┤ ├┬┘`n┴ ┴─┴┘┴ ┴  ─┴┘└─┘ └┘ ┴└─┘└─┘  ┴└─└─┘┴ ┴└─┘ └┘ └─┘┴└─ `n=====================================================
    `n                by eva gamma mead`n"
    RAND_COLORS "`n=====================================================`n"
    Write-Host "`n`nWelcome! This program will remove all mobile devices for a user."
    Write-Host "`nInstructions:"
    Write-Host "1. Sign-in using the client's 365 Tenant Admin."
    Write-Host "2. Enter the user you wish to delete devices for. It will check to make sure the user exists."
    Write-Host "   Note: When entering in the username, you * must * use the AD account name that the devices are linked to in 365."
    Write-Host "3. Use this program responsibly. Always practice safe scripting!`n"
    Write-Warning "If you remove the wrong user, you can't get the devices back without re-adding them!`n"
    RAND_COLORS "=====================================================`n"
}

# this function connects to the exchange online instance using an interactive browser window
function CONNECTING_IS_IMPORTANT {
    $connect = Read-Host -Prompt "`nDo you need to connect to Exchange Online?`n(Y/N)"
    if ($connect -eq "y"){
        Write-Host "Connecting to Exchange Online...
        `nPlease login to the client's 365 Tenant Admin you need to edit by using the browser window that has just opened."
        Connect-ExchangeOnline
    }
    else {
        Write-Host "Already connected. Proceeding to mobile device removal."
    }
}

# this is the heart of the program that removes devices
function REMOVE_MDM{
    do {
        do { # error checking for the username - if it doesn't exist, it will tell you and let you try again
            $failed = $false
            try {
                $termuser = Read-Host -Prompt "Enter the username of the person you wish to remove devices for"
                $userdevices = Get-MobileDevice -Mailbox $termuser -ErrorAction Stop
                } catch { # error catching if it doesn't exist
                    Write-Warning "The user '$termuser' does not exist. Please check your spelling and try again."
                    $failed = $true
            }
            } while ($failed)

            #confirmation of the device deletion
            Write-Host "Are you sure you want to remove devices for $($termuser)?"
            Write-Warning "THIS ACTION CANNOT BE UNDONE." # gentle reminder that this can't be undone :)
            $termconf = Read-Host "(Y/N)"
            
            # start do loop over if you hit "n"
            while ($termconf -ne "Y") { 
                if ($termconf -eq 'n') {REMOVE_MDM} 
                Write-Warning "Please check your input and try again."
                Write-Host "Are you sure you want to remove devices for $($termuser)?"
                Write-Warning "THIS ACTION CANNOT BE UNDONE."
                $termconf = Read-Host -Prompt "(Y/N)"
            }
            # goes through each $item in the devices from the user - operates in COM space so acting like an array if you're used to those things
            ForEach ($item in $userdevices) {
                Remove-MobileDevice -Identity $item -whatif # remove -whatif when you are ready to
                try {[System.Runtime.Interopservices.Marshal]::ReleaseComObject($item)} catch {} # suppresses arch warning errors on mac as it's not supported in aarch64, but necessary otherwise the script will hand on the server due to not releasing objects in COM space
            }
        $response = Read-Host -Prompt "Would you like to remove device for another user? (Y/N) " # delete more devices if you'd like, loops back to beginning
    } while ($response -eq "Y")
}

# simply the end, a polite program always says thank you. :)
function FIN{
    RAND_COLORS "=====================================================`n"
    RAND_COLORS "`n    ~* Thank you for using this program. *~`n"
    RAND_COLORS "=====================================================`n"
    Exit
}

GREETINGS_MORTAL
CONNECTING_IS_IMPORTANT
REMOVE_MDM
FIN