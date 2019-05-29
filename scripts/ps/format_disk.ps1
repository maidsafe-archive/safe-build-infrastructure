Initialize-Disk -PartitionStyle MBR -PassThru -Number 1
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter -IsActive
Format-Volume -FileSystem NTFS -NewFileSystemLabel "slave-workspace" -Confirm:$false -DriveLetter D
