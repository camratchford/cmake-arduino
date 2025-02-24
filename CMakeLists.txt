cmake_minimum_required(VERSION 3.22)
set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)

set(CMAKE_PROJECT_NAME, cmake_arduino)
project(${CMAKE_PROJECT_NAME})

# Set MCU (Reference
set(AVR_MCU atmega328p) # see README for list of compatible MCUs
set(AVR_FREQ 8000000L)  # typically 8000000L, 16000000L. If you're using a different frequency, you'll need to change the fuses.
set(AVR_BAUD_RATE 19200) # typically 19200, 57600, 115200



## Select one of the two upload tools 'minipro' or 'avrdude'
set(AVR_UPLOADTOOL avrdude)
set(AVR_PROGRAMMER arduino)             # Not used with minipro, see README for list of compatible avrdude programmers
set(AVR_UPLOADTOOL_PORT /dev/ttyUSB0)   # Not used with minipro

## Use this thing to figure out your fuses: https://eleccelerator.com/fusecalc/fusecalc.php?chip=atmega328p
# https://eleccelerator.com/fusecalc/fusecalc.php?chip=atmega328p&LOW=C2&HIGH=D9&EXTENDED=FF&LOCKBIT=FF
set(AVR_L_FUSE 0xC2)
set(AVR_H_FUSE 0xd9)
set(AVR_E_FUSE 0xff)
set(AVR_L_FUSE 0xff)


add_definitions(-DAVR_MCU="${AVR_MCU}")
add_definitions(-DUART_BAUD_RATE=${AVR_BAUD_RATE})  # Used in the bootloader code
add_definitions(-DAVR_FREQ=${AVR_FREQ})             # Used in the bootloader code
set(F_CPU ${AVR_FREQ})                              # Used in bootloader selection
add_definitions(-DF_CPU=${F_CPU})


set(AVR_UART UART0)                                 # Used in bootloader selection
set(AVR_LED_PIN B5)                                 # Used in bootloader selection

## Edit this file to suit your compiler settings needs
include(${CMAKE_CURRENT_LIST_DIR}/cmake/definitions.cmake)
## Don't touch this one, unless you're adding a new upload tool
include(${CMAKE_CURRENT_LIST_DIR}/cmake/generic-gcc-avr.cmake)
## Don't touch this one
include(${CMAKE_CURRENT_LIST_DIR}/cmake/MiniCore.cmake)



### Local files

## These files are your 'project' files
file(GLOB Includes ${CMAKE_CURRENT_LIST_DIR}/include/*.h)
file(GLOB CPPSources ${CMAKE_CURRENT_LIST_DIR}/src/*.cpp)
file(GLOB CSources ${CMAKE_CURRENT_LIST_DIR}/src/*.c)
## Any libraries under the lib directory will be compiled as static libraries and linked to
## your project
set(LocalLib ${CMAKE_CURRENT_LIST_DIR}/lib)


### System lib
# avr-libc
file(GLOB_RECURSE AVRIncludes /usr/lib/avr/include/*.h)

### third-party
## Some Examples of how to include third-party libraries.
## These are also compiled as static libraries and linked to your project
## Ensure that all source files are included in the list

set(AdafruitBusIOLibrary ${CMAKE_CURRENT_LIST_DIR}/third-party/Adafruit_BusIO)
file(GLOB_RECURSE AdafruitBusIOIncludes ${AdafruitBusIOLibrary}/*.h)
file(GLOB_RECURSE AdafruitBusIOCSources ${AdafruitBusIOLibrary}/*.c)
file(GLOB_RECURSE AdafruitBusIOCPPSources ${AdafruitBusIOLibrary}/*.cpp)

set(RotaryEncoderLibrary ${CMAKE_CURRENT_LIST_DIR}/third-party/RotaryEncoder/src)
file(GLOB_RECURSE RotaryEncoderIncludes ${RotaryEncoderLibrary}/*.h)
file(GLOB_RECURSE RotaryEncoderCSources ${RotaryEncoderLibrary}/*.c)
file(GLOB_RECURSE RotaryEncoderCPPSources ${RotaryEncoderLibrary}/*.cpp)

### For debugging purposes...
## This is how to list the contents of the list 'RotaryEncoderIncludes',
##   for an imaginary case that the compiler is complaining about it not being included

# message("RotaryEncoderIncludes: ${RotaryEncoderIncludes}")

## Now we exit before more errors are thrown

# return()

### These directories will be used by cpp to find which header you pass with #include
## Subdirectories of these directories must also be passed with #include.
## For Example:
## - `#include <Adafruit_BusIO.h>` will be found in third-party/Adafruit_BusIO/Adafruit_BusIO.h
##    because third-party/Adafruit_BusIO was included in this list
## - `#include <Flash/src/Flash.h>` will be found in third-party/minicore/avr/libraries/Flash/src/Flash.h
##    because third-party/minicore/avr/libraries was included in this list
include_directories(
        ${CMAKE_CURRENT_LIST_DIR}/include # root/include
        /usr/lib/avr/include
        ${LocalLib}                       # root/lib
        ${CoreFiles}                      # third-party/minicore/avr/cores/MCUdude_corefiles
        ${Variant}                        # third-party/minicore/avr/variants/standard
        ${CoreLibs}                       # third-party/minicore/avr/libraries
        ${AdafruitBusIOLibrary}           # third-party/Adafruit_BusIO
        ${RotaryEncoderLibrary}           # third-party/RotaryEncoder/src
)

## Note the call to 'add_avr_library' instead of 'add_library'
add_avr_library(
        Core
        ${CoreIncludes}
        ${CoreCSources}
        ${CoreCPPSources}
)

## Compile each subdirectory of LocalLib as a static library
SUBDIRLIST(LocalLibSubdirs ${LocalLib})
foreach(subdir ${LocalLibSubdirs})
    file(GLOB_RECURSE LibIncludes ${LocalLib}/${subdir}/*.h)
    file(GLOB_RECURSE LibCSources ${LocalLib}/${subdir}/*.c)
    file(GLOB_RECURSE LibCPPSources ${LocalLib}/${subdir}/*.cpp)
    add_avr_library(
            ${subdir}
            ${LibIncludes}
            ${LibCSources}
            ${LibCPPSources}
    )
endforeach()

### A separate call to 'add_avr_library' is required for each third-party library
add_avr_library(
        AdafruitBusIO
        ${AdafruitBusIOCSources}
        ${AdafruitBusIOCPPSources}
)
add_avr_library(
        RotaryEncoder
        ${RotaryEncoderIncludes}
        ${RotaryEncoderCSources}
        ${RotaryEncoderCPPSources}
)

## Note the call to 'add_avr_executable' instead of 'add_executable'
add_avr_executable(${CMAKE_PROJECT_NAME}
        ${Includes}
        ${CPPSources}
        ${CSources}
        ${AVRIncludes}
        ${Variant}/pins_arduino.h
        ${CoreIncludes}
        ${AdafruitBusIOIncludes} # Include the headers for each third party library, the source files are already included via avr_target_link_libraries
        ${RotaryEncoderIncludes} # Include the headers for each third party library, the source files are already included via
        ${CoreLibIncludes}
        ${CoreLibCSources}
        ${CoreLibCPPSources}
)

## Note the call to 'avr_target_link_libraries' instead of 'target_link_libraries'
avr_target_link_libraries(${CMAKE_PROJECT_NAME}
        Core
)
avr_target_link_libraries(${CMAKE_PROJECT_NAME}
        AdafruitBusIO
)
avr_target_link_libraries(${CMAKE_PROJECT_NAME}
        RotaryEncoder
)

avr_generate_fixed_targets()
