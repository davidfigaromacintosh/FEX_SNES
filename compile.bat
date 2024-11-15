@echo off
goto continue

# Notes: to compile EXAMPLE.ASM ---> EXAMPLE.SMC from the command prompt type:  wla EXAMPLE

:continue
echo [objects] > main.temp.prj
echo main.obj >> main.temp.prj

echo on
wla-65816 -o main.obj main.asm
wlalink -v -r main.temp.prj fex_msu1.sfc
@echo off

del main.obj
del main.temp.prj