START /WAIT CMD /C NET USER wmiuser "password" /ADD
START /WAIT CMD /C NET LOCALGROUP "Remote Management Users" "wmiuser" /ADD
START /WAIT CMD /C NET LOCALGROUP "Remote Desktop Users" "wmiuser" /ADD
START /WAIT CMD /C NET LOCALGROUP "Distributed COM Users" "wmiuser" /ADD
START /WAIT CMD /C NET LOCALGROUP "Event Log Readers" "wmiuser" /ADD