if($msolcred -eq $null) {
	$msolcred = get-credential
}

if($msol_session -eq $null) {
    write-host "Connecting to office 365..."
    Import-Module MSOnline
    $msol_session = Connect-MsolService -Credential $msolcred
}

Get-MsolPasswordPolicy -DomainName lfdj.com

#Get All Licensed Users
$users = Get-MsolUser -All | Where-Object {$_.isLicensed -eq $true}
foreach ($user in $users) {
	PasswordNeverExpires
	StrongPasswordRequired
	StrongPasswordRequired
}

#write-output "Line #$i OK1:$($UPN): MAJ mdp policy + env : Resultat ($?)"
#write-output ("Line #$i OK2:password maj $($UPN) = $x : Resultat ($?)")