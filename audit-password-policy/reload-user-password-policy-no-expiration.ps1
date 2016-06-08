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

$users = Get-MsolUser -All | Where-Object {$_.isLicensed -eq $true}
$i = 0
foreach ($user in $users) {
    $i++
    # Pas d'expiration 
    $res = Set-MsolUser -UserPrincipalName  $user.UserPrincipalName -PasswordNeverExpires $True
    write-output "Line #$i OK1:$($user.UserPrincipalName): MAJ mdp policy never expires : Resultat ($?)"
}