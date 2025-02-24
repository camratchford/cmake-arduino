cmake_minimum_required(VERSION 3.22)
set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)

project(cmake_arduino)

# Set MCU (Reference
set(AVR_MCU atmega328p)
set(AVR_FREQ 8000000L)
set(AVR_BAUD_RATE 19200)
add_definitions(-DAVR_MCU="${AVR_MCU}")
add_definitions(-DUART_BAUD_RATE=${AVR_BAUD_RATE})

## Select one of the two upload tools (or make your own)
# set(AVR_UPLOADTOOL minipro)
set(AVR_UPLOADTOOL avrdude)
set(AVR_PROGRAMMER arduino)
set(AVR_UPLOADTOOL_PORT /dev/ttyUSB0)


## Use this thing to figure out your fuses: https://eleccelerator.com/fusecalc/fusecalc.php?chip=atmega328p
# https://eleccelerator.com/fusecalc/fusecalc.php?chip=atmega328p&LOW=C2&HIGH=D9&EXTENDED=FF&LOCKBIT=FF
set(AVR_L_FUSE 0xC2)
set(AVR_H_FUSE 0xd9)
set(AVR_E_FUSE 0xff)
set(AVR_L_FUSE 0xff)

# Ensure it matches what was set with fuses
add_definitions(-DAVR_FREQ=${AVR_FREQ})
set(F_CPU ${AVR_FREQ})
add_definitions(-DF_CPU=${F_CPU})


# Ensure there is a matching bootloader to the following values
set(AVR_UART UART0)
set(AVR_LED_PIN B5)

## Edit this file to suit your needs
include(${CMAKE_CURRENT_LIST_DIR}/cmake/definitions.cmake)
## Don't touch this one
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
add_avr_executable(macropad_firmware
        ${Includes}
        ${CPPSources}
        ${CSources}
        ${AVRIncludes}
        ${Variant}/pins_arduino.h
        ${CoreIncludes}
        ${AdafruitBusIOIncludes}
        ${RotaryEncoderIncludes}
        ${CoreLibIncludes}
        ${CoreLibCSources}
        ${CoreLibCPPSources}
)

## Note the call to 'avr_target_link_libraries' instead of 'target_link_libraries'
avr_target_link_libraries(macropad_firmware
        Core
)
avr_target_link_libraries(macropad_firmware
        AdafruitBusIO
)
avr_target_link_libraries(macropad_firmware
        RotaryEncoder
)

avr_generate_fixed_targets()
