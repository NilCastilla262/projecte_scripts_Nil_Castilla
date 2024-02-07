Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer -Server 172.24.20.111 -User root -Password Patata123*
$alpine_bo=Get-VM | Where-Object { ($_.Name -like 'alpine_script*') -and ($_.PowerState -eq 'PoweredOn') } | Format-List
$alpine_copy=Get-VM | Where-Object { ($_.Name -like 'alpine_script*') -and ($_.PowerState -eq 'PoweredOff') } | Format-List


