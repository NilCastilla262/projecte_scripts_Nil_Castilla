function crearVM {
    param ()

    #Crear vm alpine
    #Info de la màquina
    $vmName = "AlpineApacheVM"
    $datastore = "datastoreBSD"
    $isoPath = "isos/alpine-standard-3.19.1-x86_64.iso"

    # Crear la vm
    New-VM -Name $vmName -ResourcePool (Get-Cluster).ResourcePool -Datastore $datastore -CD -DiskGB 20 -MemoryGB 2 -NumCpu 1 -GuestId "Debian GNU/Linux 10 (64-bit)" -Version "vmx-13"

    # Conectar la ISO a la vm
    Set-CDDrive -VMHost $vmName -IsoPath $isoPath -StartConnected $true

    # Engegar la vm
    Start-VM -VM $vmName
}



Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false >>/dev/null
Connect-VIServer -Server 172.24.20.111 -User root -Password Patata123* >>/dev/null
$alpine_bo=Get-VM | Where-Object { ($_.Name -like 'alpine_script*') -and ($_.PowerState -eq 'PoweredOn') } | Format-List
$alpine_copy=Get-VM | Where-Object { ($_.Name -like 'alpine_script*') -and ($_.PowerState -eq 'PoweredOff') } | Format-List


crearVM