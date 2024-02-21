function connectar {
    param (
        
    )
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false >>/dev/null
    $connexio_nil = Connect-VIServer -Server 172.24.20.111 -User root -Password Patata123*

    return $connexio_nil
}

function desconnectar {
    param (
        $connexio
    )

    Disconnect-VIServer -Server $connexio.Name -Confirm:$false
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

function agafarDadesOff {
    param (
    )
    $mv=Get-VM | Where-Object { ($_.Name -like 'alpine_script_nil_on') -and ($_.PowerState -eq 'PoweredOn') } | Format-List
    $funciona = comprovarExisteix -mv $mv
    if (!$funciona){
        
    }
    return $mv
}

function agafarDadesOn {
    param (
    )
    $mv=Get-VM | Where-Object { ($_.Name -like 'alpine_script_nil_off') -and ($_.PowerState -eq 'PoweredOff') } | Format-List
    $funciona = comprovarExisteix -mv $mv
    return $mv
}

function agafarDadesPlantilla {
    param (
    )
    $mv=Get-VM | Where-Object { ($_.Name -like 'alpine_script_nil_plantilla') -and ($_.PowerState -eq 'PoweredOff') } | Format-List
    $funciona = comprovarExisteix -mv $mv
    return $mv
}

function comprovarExisteix {
    param (
        $mv
    )
    if ($alpine_on -ne $null){
        return $true
    }
    else {
        return $false
    }
}

function comprovarConnexio {
    param (
        $ip
    )
    try {
        $apacheUrl = "http://$($ip):80"
        $response = Invoke-WebRequest -Uri $apacheUrl
        if ($response.StatusCode -eq 200) {
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}

$connexio = connectar
#crearAlpine
$alpine_plantilla = agafarDadesPlantilla
$alpine_off = agafarDadesOff
$alpine_on = agafarDadesOn
$funiona=comprovarConnexio -ip "172.24.20.113"
if ($funiona) {
#    "[$(Get-Date)] La connexió funciona correctament amb la VM alpine" >> /var/log/projecte.log
}
else {
    Write-Host "no funciona"
}
desconnectar -connexio $connexio
