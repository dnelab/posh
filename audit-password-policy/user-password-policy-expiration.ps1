if($msolcred -eq $null) {
	$msolcred = get-credential
}

if($msol_session -eq $null) {
    write-host "Connecting to office 365..."
    Import-Module MSOnline
    $msol_session = Connect-MsolService -Credential $msolcred
}

#MSOnline\Get-MsolPasswordPolicy -DomainName lfdj.com


#Get All Licensed Users
$i = 0
$users = Get-MsolUser -All | Where-Object {$_.isLicensed -eq $true}
# header
write-output ("item;UserPrincipalName;LastPasswordChangeTimestamp;PasswordNeverExpires;StrongPasswordRequired;ValidationStatus;BlockCredential")
foreach ($user in $users) {
    $i++
    write-output ("Line #$i;$($user.UserPrincipalName);$($user.LastPasswordChangeTimestamp);$($user.PasswordNeverExpires);$($user.StrongPasswordRequired);$($user.ValidationStatus);$($user.BlockCredential)")
}
