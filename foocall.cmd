@echo off
REM CMDLINE ONELINE
REM set "p=C:\temp" & set "r=CoreePower" & call md "%p%" & call git -C "%p%" clone https://github.com/carsten-riedel/%r%.git & call git -C "%p%\%r%" pull
REM set "p=C:\temp" & set "r=CoreePower" & call md "%p%" & call git -C "%p%" clone --depth 1 --single-branch https://github.com/carsten-riedel/%r%.git & call git -C "%p%\%r%" pull
REM set "p=C:\temp" & set "r=CoreePower" & call md "%p%" & call git -C "%p%" clone --depth 1 --single-branch https://github.com/carsten-riedel/%r%.git & call git -C "%p%\%r%" pull & call %COMSPEC% ""/C" "%p%\%r%\foo.cmd" "%cd%" "%p%\%r%""
REM set "p=C:\temp" & set "r=CoreePower" & call md "%p%" 2> nul & call git -C "%p%" clone --depth 1 --single-branch https://github.com/carsten-riedel/%r%.git 2> nul & call git -C "%p%\%r%" pull 1> nul & call %COMSPEC% ""/C" "%p%\%r%\foo.cmd" "%cd%" "%p%\%r%""
REM set "p=C:\temp" & set "r=CoreePower" & call md "%p%" & call git -C "%p%" clone --depth 1 --single-branch --config user.name="Carsten Riedel" --config user.email="carsten.riedel.one@outlook.com" https://ghp_:@github.com/carsten-riedel/%r%.git & call git -C "%p%\%r%" pull
REM set "p=C:\temp" & set "r=CoreePower" & call md "%p%" 2> nul & call git -C "%p%" clone --depth 1 --single-branch --config user.name="Carsten Riedel" --config user.email="carsten.riedel.one@outlook.com" https://ghp_:@github.com/carsten-riedel/%r%.git > nul 2>&1 & call git -C "%p%\%r%" pull 1> nul

REM task scheduler
REM %comspec% /v /c "set "p=C:\temp" & set "r=CoreePower" & mkdir !p! & git -C "!p!" clone https://github.com/carsten-riedel/!r!.git || git -C "!p!\!r!" pull"

REM BATCH ONELINE
REM set "p=C:\temp" & set "r=CoreePower" & call md "%%p%%" & call git -C "%%p%%" clone https://github.com/carsten-riedel/%%r%%.git & call git -C "%%p%%\%%r%%" pull
REM set "p=C:\temp" & set "r=CoreePower" & call md "%%p%%" 2> nul & call git -C "%%p%%" clone https://github.com/carsten-riedel/%%r%%.git 2> nul & call git -C "%%p%%\%%r%%" pull 1> nul
REM set "p=C:\temp" & set "r=CoreePower" & call md "%%p%%" 2> nul & call git -C "%%p%%" clone --depth 1 --single-branch --config user.name="Carsten Riedel" --config  user.email="carsten.riedel.one@outlook.com" https://ghp_:@github.com/carsten-riedel/%%r%%.git 2> nul & call git -C "%%p%%\%%r%%" pull 1> nul

set "p=C:\temp"
set "r=CoreePower"
md "%p%" 2> nul
git -C "%p%" clone --depth 1 --single-branch https://github.com/carsten-riedel/%r%.git 2> nul
git -C "%p%\%r%" pull 1> nul
%COMSPEC% ""/C" "%p%\%r%\foo.cmd" "%cd%" "%p%\%r%""
pause
