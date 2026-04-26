$thumbprint = $args[0]

$cert = Get-ChildItem -Path 'Cert:\LocalMachine\' -Recurse |
        Where-Object { $_.Thumbprint -eq $thumbprint }

if ($cert) {
    $daysLeft = ($cert.NotAfter - (Get-Date)).Days
    Write-Output $daysLeft
    # Если нужно только число (для использования в других скриптах):
    # $daysLeft
} else {
    Write-Output "0"
}