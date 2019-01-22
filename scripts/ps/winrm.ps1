netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config @{MaxTimeoutms="1800000"}
winrm set winrm/config/winrs @{MaxMemoryPerShellMB="800"}
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}
winrm set winrm/config/client/auth @{Basic="true"}
winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"} 
netsh advfirewall firewall set rule group="remote administration" new enable=yes 
netsh firewall add portopening TCP 5985 "Port 5985" 
net stop winrm 
sc config winrm start= auto
net start winrm
