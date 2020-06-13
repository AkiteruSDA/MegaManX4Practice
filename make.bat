@echo off
mkdir build 2>nul
mkdir bin 2>nul
chdir build
if not exist "SLUS_005_VANILLA.61" (
	..\tools\psximager\psxrip "..\Mega Man X4 (USA).cue" "..\build" >nul
	copy /Y /B SLUS_005.61 /B SLUS_005_VANILLA.61 /B >nul
)
..\tools\armips\armips "..\src\hack.asm" -root "..\build"
if exist "..\bin\MegaManX4_Practice.cue" (
	..\tools\psximager\psxinject "..\bin\MegaManX4_Practice.cue" SLUS_005.61 SLUS_005.61 >nul
) else (
	..\tools\psximager\psxbuild -c ..cat MegaManX4_Practice.bin >nul
	move /y MegaManX4_Practice.cue ..\bin\MegaManX4_Practice.cue >nul
	move /y MegaManX4_Practice.bin ..\bin\MegaManX4_Practice.bin >nul
)
chdir ..
