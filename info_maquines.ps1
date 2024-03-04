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

$connexio_nil = connectar

python ./connexioBD.py

desconnectar -connexio $connexio_nil