
set TOP_BOARD=..\board
set TOP_PROGRAM=..\program

rem replace board\*\*.sh with scripts\board\common\*.bat
for /f %%f in ('dir /A:D /B %TOP_BOARD%') do (
    if not %%f == program (
        del  %TOP_BOARD%\%%f\*.sh
        copy .\board\common\*.bat %TOP_BOARD%\%%f
    )
)

REM rem replace program\*\*.sh with scripts\program\common\*.bat
REM for /f %%f in ('dir /A:D /B %TOP_PROGRAM%') do (
REM     if not %%f == program (
REM         del  %TOP_PROGRAM%\%%f\*.sh
REM         copy .\program\common\*.bat %TOP_PROGRAM%\%%f
REM     )
REM )
