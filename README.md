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
