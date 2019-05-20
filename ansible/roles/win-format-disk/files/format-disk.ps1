Initialize-Disk -PartitionStyle MBR -PassThrough -DiskNumber 1
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter -IsActive
Format-Volume -FileSystem NTFS -NewFileSystemLabel "slave-workspace" -Confirm:$false -DriveLetter D
