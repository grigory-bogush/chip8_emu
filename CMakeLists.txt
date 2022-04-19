# Useful notes
# Use CMAKE_C_FLAGS to set c compiler flags
# Use LINK_FLAGS to set linker flags
# Use CMAKE_ASM_NASM_OBJECT_FORMAT to set NASM object format

cmake_minimum_required(VERSION 2.8)

set(CMAKE_VERBOSE_MAKEFILE ON)

project(chip_8_emu C)

enable_language(ASM_NASM)
if(CMAKE_ASM_NASM_COMPILER_LOADED)
  set(CAN_USE_ASSEMBLER TRUE)

  set(CMAKE_ASM_NASM_OBJECT_FORMAT "elf32")
  set(CMAKE_ASM_NASM_COMPILE_OBJECT "<CMAKE_ASM_NASM_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -f ${CMAKE_ASM_NASM_OBJECT_FORMAT} -o <OBJECT> <SOURCE>")
  file(GLOB_RECURSE ENGINE_ASM_FILES "./src/asm/*.asm")
  set(ASM_SOURCES ${ASM_SOURCES} ${ENGINE_ASM_FILES})
  
endif(CMAKE_ASM_NASM_COMPILER_LOADED)

message(STATUS "Is NASM enabled: ${CAN_USE_ASSEMBLER}")
message(STATUS "ASM Sources up for compliation: ${ASM_SOURCES}")

set(CMAKE_C_FLAGS "-m32 -g")

set(SOURCE_EXE ./src/main.c)

add_executable(main ${SOURCE_EXE} ${ASM_SOURCES})