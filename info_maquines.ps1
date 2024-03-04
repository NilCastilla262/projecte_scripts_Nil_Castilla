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


function obtenirDadesVM {
    $vms = Get-VM

    #Crear array associatiu per les vm
    $dadesVM = @()

    #Recòrrer les VMs i afegir les dades a l'array associatiu
    foreach ($vm in $vms) {
        $dataId = Get-Date -Format "yyyyMMddHHmmss"
        $vmId = $vm.Id
        $ram = $vm.MemoryGB
        $cpu = $vm.NumCpu

        # Crear un objecte PowerShell amb les dades de la VM
        $dades = [PSCustomObject]@{
            DataId = $dataId
            VmId = $vmId
            Ram = $ram
            Cpu = $cpu
            Estat = $true
        }

        # Afegir l'objecte a l'array
        $dadesVM += $dades
    }
    return $dadesVM | ConvertTo-Json
}

$connexio_nil = connectar

$dades=obtenirDadesVM
Write-Host $dades
python /home/nil/projecte/connexioBD.py

desconnectar -connexio $connexio_nil