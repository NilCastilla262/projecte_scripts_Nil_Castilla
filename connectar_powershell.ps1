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

function installOS {
    Start-Sleep -Seconds 15
    $VMName = "AlpineNil"
    $installScriptPath = "./installAlpine"
    $installCommand = "/bin/sh $installScriptPath"
    Invoke-VMScript -VM $VMName -ScriptType Bash -ScriptText $installCommand
}

function agafarPlantilla {
    param (
    )
    try {
        $template = Get-Template -Name 'alpine_script_nil_plantilla' -ErrorAction Stop
    } catch {
        $template = $null
    }
    if ($template -eq $null){
        Write-Log -Message "No es troba la plantilla" -Path $LOGDIR -Level Warning
    }
    return $template
}

function agafarVMOff {
    param (
        $plantilla
    )
    $mv=Get-VM | Where-Object { ($_.Name -eq 'alpine_script_nil_off') }
    if ($mv -eq $null){
        clonarVM -plantilla $plantilla
        Write-Log -Message "S'ha creat una nova maquina alpine off ja que o no exeistia o s'ha engegat la anterior." -Path $LOGDIR -Level Info
    }
    return $mv
}

function agafarVMOn {
    param (
        $alpineOff,
        $plantilla
    )
    $mv=Get-VM | Where-Object { ($_.Name -eq 'alpine_script_nil_on') }
    if ($mv -eq $null){
        #Canviar nom i engegar VM Off
        try {
            Set-VM -VM $alpineOff -Name 'alpine_script_nil_on' -Confirm:$false 
            Write-Log -Message "S'ha canviat el nom de la VM off a VM on" -Path $LOGDIR -Level Info
            Start-VM -VM $alpineOff
            Write-Log -Message "S'ha engegat la VM on" -Path $LOGDIR -Level Info
        }catch {
            Write-Log -Message "error al canviar el nom o engegar la VM alpine off" -Path $LOGDIR -Level error
        }
        $vm = $alpineOff
        Write-Log -Message "No s'ha trobat la maquina alpine on per lo que s'ha canviat el nom de l'alpine off, s'ha engegat i s'ha creat un nou alpine off" -Path $LOGDIR -Level Info

        #Tornar a crear la VM Off
        $alpineOff  = agafarVMOff -plantilla $alpine_plantilla
    }
    return $vm, $alpineOff
}

function comprovarConnexio {
    param (
        $ip
    )
    try {
        $apacheUrl = "http://$($ip):80"
        $response = Invoke-WebRequest -Uri $apacheUrl -TimeoutSec 5
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
        $plantilla
    )

    # Obtenir la instància de la màquina virtual plantilla
    $clonName = "alpine_script_nil_off"
    $clonDatastore = "datastoreBSD"
    $esxiHost = "172.24.20.111"

    # Clonar la màquina virtual
    New-VM -Template $plantilla -Name $clonName -Datastore $clonDatastore -VMHost $esxiHost
}

function eliminarVM {
    param ()
    
    $vmName = "alpine_script_nil_on"

    try {
        #Intenta parar la VM
        $vm = Get-VM | Where-Object { ($_.Name -eq $vmName) }
        try {
            Stop-VM -VM $vm -Confirm:$false -ErrorAction Stop
        } catch {
            Write-Log -Message "S'ha intentat parar la vm per eliminar-la pero ha donat error, pot ser que sigui perque ja esta parada" -Path $LOGDIR -Level Warning
        }
        #Eliminem la VM
        Remove-VM -VM $vm -Confirm:$false -ErrorAction Stop

        Write-Log -Message "Eliminada la VM alpine on ja que no funcionava el servei web" -Path $LOGDIR -Level Info
    } catch {
        Write-Log -Message "Error al parar o eliminar la VM alpine On, el servei web no esta funcionant" -Path $LOGDIR -Level Error
    }
}

function aconseguirIP {
    param (
        $vm
    )
    try {
        return $vm.Guest.IPAddress[0]
    }
    catch {
        Write-Log -Message "No s'ha pogut obtenir la IP de la VM alpineOn" -Path $LOGDIR -Level Warning
    }

}

#Ffuncions

$connexio = connectar
#Comprovar que existeixen les maquines i la plantilla, en cas de que no existeixin les maquines les crea
$alpine_plantilla = agafarPlantilla
$alpine_off = agafarVMOff -plantilla $alpine_plantilla
$alpine_on, $alpine_off = agafarVMOn -alpineOff $alpine_off -plantilla $alpine_plantilla

#Comprovar si funciona el servei web, en cas de que no funcioni elimina la maquina i aixeca la que esta parada
Start-Sleep -Seconds 20
$ip = aconseguirIP -vm $alpine_on
Write-Host $ip
$ip = "172.24.20.113"
$funciona=comprovarConnexio -ip $ip
if ($funciona) {
    Write-Log -Message "La connexió funciona correctament amb la VM alpine" -Path $LOGDIR -Level Info
}
else {
    eliminarVM
    $alpine_on, $alpine_off = agafarVMOn -alpineOff $alpine_off -plantilla $alpine_plantilla
}
desconnectar -connexio $connexio
