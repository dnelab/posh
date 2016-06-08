try {
    Get-MsolDomain -ErrorAction Stop > $null
} catch {
    if($msolcred -eq $null) {
	    $msolcred = get-credential
    }

    if($msol_session -eq $null) {
        write-host "Connecting to office 365..."
        Import-Module MSOnline
        $msol_session = Connect-MsolService -Credential $msolcred
    }
}

#### domain policy ####
$domain = $msolcred.UserName.Split("@")[1]
$policy = Get-MsolPasswordPolicy -DomainName $domain
$warn = if($policy.NotificationDays -eq $null) {14} else {$policy.NotificationDays}
$old = if($policy.ValidityPeriod -eq $null) {90} else {$policy.ValidityPeriod}

write-host "Tenant password policy is :"
if($old -eq 2147483647) {
    write-host " - no change password"
} else {
    write-host " - change password untill is $old days old"
    write-host " - warn user $warn days before password expiration"
}
write-host ""

## if ValidityPeriod isn't rational , we tamper it
$old = [Math]::Min($old, 3650)

#### logging ####
# The Output will be written to this file in the current working directory
$LogFile = "$domain-password-policy-"+$(Get-Date -UFormat "%Y%m%d@%H%M")+".csv"
$coll_pass = @()
$pass = @{}
$pass.Add("UserPrincipalName", "n/a")
$pass.Add("LastPasswordChangeTimestamp", "n/a")
$pass.Add("PasswordNeverExpires", "n/a")
$pass.Add("StrongPasswordRequired", "n/a")
$pass.Add("ValidationStatus", "n/a")
$pass.Add("BlockCredential", "n/a")
$pass.Add("PasswordAge", "n/a")

#### user policy ####

#Get All Licensed Users
$i = 0
$users = Get-MsolUser -All | Where-Object {$_.isLicensed -eq $true}
# header
#write-output ("item;UserPrincipalName;LastPasswordChangeTimestamp;PasswordNeverExpires;StrongPasswordRequired;ValidationStatus;BlockCredential;PasswordAge")
foreach ($user in $users) {
    $i++
    $age =  ((Get-Date) - ($user.LastPasswordChangeTimestamp)).TotalDays
    #write-output ("Line #$i;$($user.UserPrincipalName);$($user.LastPasswordChangeTimestamp);$($user.PasswordNeverExpires);$($user.StrongPasswordRequired);$($user.ValidationStatus);$($user.BlockCredential);$age")

    # detect blocked account
    if($user.BlockCredential) {
        Write-Host -ForegroundColor Red $user.UserPrincipalName "account is locked"
    }

    # detect no password expires on user
    if($user.PasswordNeverExpires -ne $false) {
        Write-Host -ForegroundColor Red $user.UserPrincipalName "account has no expiration date"
    }

    # very old password > 90j
    if(($user.LastPasswordChangeTimestamp) -lt (get-date).AddDays(-$old)) {
        Write-Host -ForegroundColor Red $user.UserPrincipalName "password is older than allowed policy ($age/$old j)"
    } elseif (($user.LastPasswordChangeTimestamp) -lt (get-date).AddDays(-$old+$warn)) {
        Write-Host -ForegroundColor DarkYellow $user.UserPrincipalName "password will expires soon ($age/$old j)"
    }

    $aPass = $pass.Clone()
    $aPass.UserPrincipalName = $user.UserPrincipalName
    $aPass.LastPasswordChangeTimestamp = $user.LastPasswordChangeTimestamp
    $aPass.PasswordNeverExpires= $user.PasswordNeverExpires
    $aPass.StrongPasswordRequired = $user.StrongPasswordRequired
    $aPass.ValidationStatus = $user.ValidationStatus
    $aPass.BlockCredential = $user.BlockCredential
    $aPass.PasswordAge = $age
    $coll_pass += New-Object PSObject -Property $aPass      
}

write-host ("Exporting data to csv... ")
$coll_pass | Export-Csv -Path $LogFile -Encoding UTF8

write-host " "
write-host ("Script Completed.  Results available in " + $LogFile)

$users| Select-Object UserPrincipalName,LastPasswordChangeTimestamp,PasswordNeverExpires,StrongPasswordRequired,ValidationStatus,BlockCredential | Out-GridView