# Timex Blocks
Tetris on the Timex Ironman Watch
Video link
https://www.youtube.com/watch?v=VxgxxhFt_IQ

My first and only attempt at programming the Timex Ironman M851 watch a while back. 

When I got the watch I was a bit ambitious about programming dates, shopping list reminders etc, but the first  thing I tried was to implement a  well known Russian Blocks game ;)
It was an interesting project working within the limitations of the M851 assembly and balancing the resources across different states. But after this I didn't feel like doing anything else with it.
It worked well enough I never got round to speeding it up as it went along and there was a strange bug I could never track down where it would not drop the blocks after a day or so as if it had a timer overrunning, might be some sort of 16 bit timeout?

The processor on the Timex Ironman M851 is the EPSON 88349

The manual 
http://assets.timex.com/developer/developer_downloads/WA_Design_Guide.pdf

"The microcontroller of the M851 is the EPSON 88349. It is an 8-bit microcontroller having 48Kbytes of
ROM and 2Kbytes of RAM. It has built in hardware components to attached external devices like I/O
ports, serial port, LCD, timers, etc. The operating system and a number of internal applications are masked
in ROM."


Useful link for docs:
https://assets.timex.com/developer/datalink/index.html

Link for developer group [needs yahoo email]
https://groups.yahoo.com/neo/groups/timexdatalinkusb/info

https://assets.timex.com/developer/accept/index_download.html  

In order to build files you need the Timex 'WristApp SDK Installer' installed. Download the Timex_WA_SDK_Installer_1_18.msi file from the link aboveand run that to get the c:\M851 and c:\C88 folders set up.

The linked page also contains further links to most of the documentation you will need, including the 'Getting Started' guide.

https://user-images.githubusercontent.com/50597519/58133346-8e9b1480-7c1b-11e9-87da-12524543db64.png
