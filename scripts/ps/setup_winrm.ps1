<powershell>
# The <powershell> tags are necessary because this script is intended
# to be used as 'user data' for an EC2 instance. It automatically starts
# the WinRM service when the machine spins up. After this Ansible can connect.
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"

# There seems to be some problem with downloading something in a user data script.
# The same seems to apply to Linux machines too.
# Try pausing for 2 minutes to allow connectivity to become available.
Start-Sleep -s 120
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

powershell.exe -ExecutionPolicy ByPass -File $file
</powershell>
