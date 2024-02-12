function crearAlpine {
    # Variables
    $VMName = "AlpineNil"
    $Datastore = "datastoreBSD"
    $DiskGB = 16
    $MemoryGB = 1
    $NumCpu = 1
    $NetworkName = "VLAN24"
    $isoPath = "[$Datastore] /isos/alpine-standard-3.19.1-x86_64.iso"

    # Creació de la MV
    New-VM -Name $VMName -Datastore $Datastore -DiskGB $DiskGB -MemoryGB $MemoryGB -NumCpu $NumCpu -GuestId "otherLinux64Guest" -NetworkName $NetworkName >>/dev/null
    
    New-CDDrive -VM $VMName -ISOPath $isoPath -StartConnected >>/dev/null

    Start-VM -VM $VMName >>/dev/null

    installOS
}

function installOS {
    Start-Sleep -Seconds 15
    $VMName = "AlpineNil"
    $installScriptPath = "./installAlpine"
    $installCommand = "/bin/sh $installScriptPath"
    Invoke-VMScript -VM $VMName -ScriptType Bash -ScriptText $installCommand
}
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false >>/dev/null
Connect-VIServer -Server 172.24.20.111 -User root -Password Patata123* >>/dev/null
#$alpine_bo=Get-VM | Where-Object { ($_.Name -like 'alpine_script*') -and ($_.PowerState -eq 'PoweredOn') } | Format-List
#$alpine_copy=Get-VM | Where-Object { ($_.Name -like 'alpine_script*') -and ($_.PowerState -eq 'PoweredOff') } | Format-List

crearAlpine