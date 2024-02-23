Import-Module VMware.VimAutomation.Core

#Constants
$LOGDIR="/var/log/projecte.log"
#Fconstants

#Funcions

function connectar {
    param (
        
    )
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false >>/dev/null
    $connexio_nil = Connect-VIServer -Server 172.24.20.3 -User administrator@vsphere.local -Password Patata1234*

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

function agafarVMPlantilla {
    param (
    )
    $template = Get-Template -Name 'alpine_script_nil_plantilla'
    if ($template -eq $null){
        Write-Log -Message "No es troba la plantilla" -Path $LOGDIR -Level Warning
    }
    return $mv
}

function agafarVMOff {
    param (
        $vmPlantilla
    )
    $mv=Get-VM | Where-Object { ($_.Name -eq 'alpine_script_nil_off') -and ($_.PowerState -eq 'PoweredOff') }
    if ($mv -eq $null){
        clonarVM -vmPlantilla $vmPlantilla
    }
    return $mv
}

function agafarVMOn {
    param (
    )
    $mv=Get-VM | Where-Object { ($_.Name -eq 'alpine_script_nil_on') -and ($_.PowerState -eq 'PoweredOn') }
    if ($mv -eq $null){

    }
    return $mv
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

function Write-Log {
    param(
        [string]$Message,
        [string]$Path,
        [string]$Level = "Info"
    )

    $LogEntry = "$(Get-Date) [$Level] - $Message"
    Add-Content -Path $Path -Value $LogEntry
}

function clonarVM {
    param (
        $vmPlantilla
    )

    # Obtenir la instància de la màquina virtual plantilla
    $plantilla = Get-VM -Name $vmPlantilla
    $clonName = "alpine_script_nil_off"
    $clonDatastore = "datastoreBSD"

    # Clonar la màquina virtual
    New-VM -VM $plantilla -Name $clonName -Datastore $clonDatastore
}

#Ffuncions

$connexio = connectar
#crearAlpine
$alpine_plantilla = agafarVMPlantilla
$alpine_off = agafarVMOff -vmPlantilla $alpine_plantilla
$alpine_on = agafarVMOn
$funiona=comprovarConnexio -ip "172.24.20.113"
if ($funiona) {
Write-Log -Message "La connexió funciona correctament amb la VM alpine" -Path $LOGDIR -Level Info
}
else {
    Write-Host "no funciona"
}
desconnectar -connexio $connexio
