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

$nb = 10
$top5 = (Get-MsolUser -All | Where-Object {$_.isLicensed -eq $true} | Sort-Object LastPasswordChangeTimeStamp | Select-Object -First $nb DisplayName,LastPasswordChangeTimeStamp,PasswordNeverExpires)


$now = (get-date)
foreach($item in $top5) {
    $age = $now - ($item.LastPassWordChangeTimeStamp)
    #$item['age'] = $age
    $item | Add-Member PasswordAge $age.TotalDays
}

Write-Host "TOP $nb oldest password" -ForegroundColor DarkYellow
$top5