:TOP
@CLS
@ECHO OFF
TITLE ArcGM Settings Cleaner
MODE 75,30
set WD=%CD:~-9,9%
set HBDIR=\ArcGM

:BEGIN
CLS
COLOR 0A
ECHO.
ECHO         _/_/                          _/_/_/  _/      _/   
ECHO      _/    _/  _/  _/_/    _/_/_/  _/        _/_/  _/_/    
ECHO     _/_/_/_/  _/_/      _/        _/  _/_/  _/  _/  _/     
ECHO    _/    _/  _/        _/        _/    _/  _/      _/      
ECHO   _/    _/  _/          _/_/_/    _/_/_/  _/      _/       
ECHO.
ECHO        http://subversion.assembla.com/svn/arcaddon
ECHO.
ECHO.
ECHO    ษอออออออออออออออออออออออออออออออออออออออออออออป
ECHO    บ 1 - Clean ArcGM files in your WTF directory บ
ECHO    ศอออออออออออออออออออออออออออออออออออออออออออออผ 
ECHO.
ECHO    ษอออออออออออออออออออออออออออออออออออออออออออออป
ECHO    บ 2 - Exit The Script                         บ
ECHO    ศอออออออออออออออออออออออออออออออออออออออออออออผ 
ECHO.
SET /P OPTION= ^-^> Enter Number: 
IF %OPTION%==* GOTO ERROR3
IF %OPTION%==1 GOTO RUN
IF %OPTION%==2 GOTO EXIT
SET OPTION=
GOTO ERROR3

:RUN
CLS
COLOR 0A
ECHO.
ECHO         _/_/                          _/_/_/  _/      _/   
ECHO      _/    _/  _/  _/_/    _/_/_/  _/        _/_/  _/_/    
ECHO     _/_/_/_/  _/_/      _/        _/  _/_/  _/  _/  _/     
ECHO    _/    _/  _/        _/        _/    _/  _/      _/      
ECHO   _/    _/  _/          _/_/_/    _/_/_/  _/      _/    
ECHO.
ECHO        http://subversion.assembla.com/svn/arcaddon
ECHO.
DEL    /s ..\..\..\WTF\Account\ArcGM.*
ECHO.
ECHO.
ECHO   All Files Deleted!
ECHO.
PAUSE
GOTO EXIT

:ERROR
CLS
COLOR 0C
ECHO.
ECHO         _/_/                          _/_/_/  _/      _/   
ECHO      _/    _/  _/  _/_/    _/_/_/  _/        _/_/  _/_/    
ECHO     _/_/_/_/  _/_/      _/        _/  _/_/  _/  _/  _/     
ECHO    _/    _/  _/        _/        _/    _/  _/      _/      
ECHO   _/    _/  _/          _/_/_/    _/_/_/  _/      _/    
ECHO.
ECHO        http://subversion.assembla.com/svn/arcaddon
ECHO.
ECHO   ERROR - Running in the wrong Directory
ECHO   ERROR - Run this in the addons own directory .\Interface\AddOns%HBDIR%
ECHO.
PAUSE
GOTO EXIT

:ERROR2
CLS
COLOR 0C
ECHO.
ECHO         _/_/                          _/_/_/  _/      _/   
ECHO      _/    _/  _/  _/_/    _/_/_/  _/        _/_/  _/_/    
ECHO     _/_/_/_/  _/_/      _/        _/  _/_/  _/  _/  _/     
ECHO    _/    _/  _/        _/        _/    _/  _/      _/      
ECHO   _/    _/  _/          _/_/_/    _/_/_/  _/      _/    
ECHO.
ECHO        http://subversion.assembla.com/svn/arcaddon
ECHO.
ECHO   ERROR - No ArcGM Files Exist
ECHO.
PAUSE
GOTO EXIT

:ERROR3
CLS
COLOR 0C
ECHO.
ECHO         _/_/                          _/_/_/  _/      _/   
ECHO      _/    _/  _/  _/_/    _/_/_/  _/        _/_/  _/_/    
ECHO     _/_/_/_/  _/_/      _/        _/  _/_/  _/  _/  _/     
ECHO    _/    _/  _/        _/        _/    _/  _/      _/      
ECHO   _/    _/  _/          _/_/_/    _/_/_/  _/      _/    
ECHO.
ECHO        http://subversion.assembla.com/svn/arcaddon
ECHO.
ECHO   ERROR - Invalid Number Selection
ECHO.
PAUSE
GOTO BEGIN

:EXIT
CLS
COLOR 0D
ECHO.
ECHO         _/_/                          _/_/_/  _/      _/   
ECHO      _/    _/  _/  _/_/    _/_/_/  _/        _/_/  _/_/    
ECHO     _/_/_/_/  _/_/      _/        _/  _/_/  _/  _/  _/     
ECHO    _/    _/  _/        _/        _/    _/  _/      _/      
ECHO   _/    _/  _/          _/_/_/    _/_/_/  _/      _/    
ECHO.
ECHO        http://subversion.assembla.com/svn/arcaddon
ECHO.
ECHO   Thank you For Using ArcGM!
ECHO.
PAUSE
EXIT