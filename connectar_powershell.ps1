function connectar {
    param (
        
    )
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false >>/dev/null
    $connexio_nil = Connect-VIServer -Server 172.24.20.111 -User root -Password Patata123* >>/dev/null

    return $connexio_nil
}

function desconnectar {
    param (
        $connexio
    )

    Disconnect-VIServer -Server $connexio -Confirm:$false
}


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

function agafarDades {
    param (
    )
    $alpine_on=Get-VM | Where-Object { ($_.Name -like 'alpine_script_nil_on') -and ($_.PowerState -eq 'PoweredOn') } | Format-List
    $alpine_off=Get-VM | Where-Object { ($_.Name -like 'alpine_script_nil_off') -and ($_.PowerState -eq 'PoweredOff') } | Format-List
    $alpine_plantilla=Get-VM | Where-Object { ($_.Name -like 'alpine_script_nil_plantilla') -and ($_.PowerState -eq 'PoweredOff') } | Format-List
}

$connexio = connectar
#crearAlpine
agafarDades
desconnectar -connexio $connexio
