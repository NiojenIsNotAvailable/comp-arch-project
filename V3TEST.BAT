@ECHO OFF
TASM cmp.asm
TLINK cmp
echo Testing...
echo.>test.res
echo === test1 ===>>test.res
%1 < V3TEST1.IN >>test.res
echo === test2 ===>>test.res
%1 < V3TEST2.IN >>test.res
echo === test3 ===>>test.res
%1 < V3TEST3.IN >>test.res

fc /b test.res v3test.ok
