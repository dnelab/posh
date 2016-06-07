if($msolcred -eq $null) {
	$msolcred = get-credential
}

if($msol_session -eq $null) {
    write-host "Connecting to office 365..."
    Import-Module MSOnline
    $msol_session = Connect-MsolService -Credential $msolcred
}

#### domain policy ####
$domain = $msolcred.UserName.Split("@")[1]
$policy = Get-MsolPasswordPolicy -DomainName $domain
$warn = if($policy.NotificationDays -eq $null) {14} else {$policy.NotificationDays}
$old = if($policy.ValidityPeriod -eq $null) {90} else {$policy.ValidityPeriod}

write-host "Tenant password policy is :"
write-host " - change password untill is $old days old"
write-host " - warn user $warn days before password expiration"
write-host ""

#### user policy ####

#Get All Licensed Users
$i = 0
$users = Get-MsolUser -All | Where-Object {$_.isLicensed -eq $true}
# header
write-output ("item;UserPrincipalName;LastPasswordChangeTimestamp;PasswordNeverExpires;StrongPasswordRequired;ValidationStatus;BlockCredential")
foreach ($user in $users) {
    $i++
    write-output ("Line #$i;$($user.UserPrincipalName);$($user.LastPasswordChangeTimestamp);$($user.PasswordNeverExpires);$($user.StrongPasswordRequired);$($user.ValidationStatus);$($user.BlockCredential)")

    # detect blocked account

    # detect no password expires on user
    
    # very old password > 90j

}
$users| Select-Object UserPrincipalName,LastPasswordChangeTimestamp,PasswordNeverExpires,StrongPasswordRequired,ValidationStatus,BlockCredential | Out-GridView