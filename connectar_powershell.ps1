Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer -Server 172.24.20.111 -User root -Password Patata123*
$vms=Get-VM | Format-List
