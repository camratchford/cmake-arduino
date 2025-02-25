##########################################################################
# "THE ANY BEVERAGE-WARE LICENSE" (Revision 42 - based on beer-ware
# license):
# <dev@layer128.net> wrote this file. As long as you retain this notice
# you can do whatever you want with this stuff. If we meet some day, and
# you think this stuff is worth it, you can buy me a be(ve)er(age) in
# return. (I don't like beer much.)
#
# Matthias Kleemann
##########################################################################

##########################################################################
# The toolchain requires some variables set.
#
# AVR_MCU (default: atmega8)
#     the type of AVR the application is built for
# AVR_L_FUSE (NO DEFAULT)
#     the LOW fuse value for the MCU used
# AVR_H_FUSE (NO DEFAULT)
#     the HIGH fuse value for the MCU used
# AVR_UPLOADTOOL (default: avrdude)
#     the application used to upload to the MCU
#     NOTE: The toolchain is currently quite specific about
#           the commands used, so it needs tweaking.
# AVR_UPLOADTOOL_PORT (default: usb)
#     the port used for the upload tool, e.g. usb
# AVR_PROGRAMMER (default: avrispmkII)
#     the programmer hardware used, e.g. avrispmkII
##########################################################################

##########################################################################
# options
##########################################################################
option(WITH_MCU "Add the mCU type to the target file name." ON)

##########################################################################
# executables in use
##########################################################################
find_program(AVR_CC avr-gcc REQUIRED)
find_program(AVR_CXX avr-g++ REQUIRED)
find_program(AVR_OBJCOPY avr-objcopy REQUIRED)
find_program(AVR_SIZE_TOOL avr-size REQUIRED)
find_program(AVR_OBJDUMP avr-objdump REQUIRED)

##########################################################################
# toolchain starts with defining mandatory variables
##########################################################################
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)
set(CMAKE_C_COMPILER ${AVR_CC})
set(CMAKE_CXX_COMPILER ${AVR_CXX})

##########################################################################
# Identification
##########################################################################
set(AVR 1)

##########################################################################
# some necessary tools and variables for AVR builds, which may not
# defined yet
# - AVR_UPLOADTOOL
# - AVR_UPLOADTOOL_PORT
# - AVR_PROGRAMMER
# - AVR_MCU
# - AVR_SIZE_ARGS
##########################################################################


# default upload tool port
if(NOT AVR_UPLOADTOOL_PORT)
    set(
            AVR_UPLOADTOOL_PORT usb
            CACHE STRING "Set default upload tool port: usb"
    )
endif(NOT AVR_UPLOADTOOL_PORT)

# default programmer (hardware)
if(NOT AVR_PROGRAMMER)
    set(
            AVR_PROGRAMMER avrispmkII
            CACHE STRING "Set default programmer hardware model: avrispmkII"
    )
endif(NOT AVR_PROGRAMMER)

# default MCU (chip)
if(NOT AVR_MCU)
    set(
            AVR_MCU atmega328
            CACHE STRING "Set default MCU: atmega328 (see 'avr-gcc --target-help' for valid values)"
    )
endif(NOT AVR_MCU)

#default avr-size args
if(NOT AVR_SIZE_ARGS)
    if(APPLE)
        set(AVR_SIZE_ARGS -B)
    else(APPLE)
        set(AVR_SIZE_ARGS -C;--mcu=${AVR_MCU})
    endif(APPLE)
endif(NOT AVR_SIZE_ARGS)

# If AVR_UPLOADTOOL is avrdude, set some default options

if(AVR_UPLOADTOOL MATCHES avrdude)
    # default baudrate for avrdude

    set(
        AVR_UPLOADTOOL_BAUDRATE 115200
        CACHE STRING "Set default baudrate for avrdude: 115200"
    )

    set(
        AVR_UPLOADTOOL_OPTIONS -V
        CACHE STRING "Set default options for avrdude: -V"
    )

    set(AVR_UPLOADTOOL_GET_STATUS
        ${AVR_UPLOADTOOL_BASE_OPTIONS} -P ${AVR_UPLOADTOOL_PORT} -n -v
    )

    set(AVR_UPLOADTOOL_UPLOAD
        ${AVR_UPLOADTOOL_BASE_OPTIONS} ${AVR_UPLOADTOOL_OPTIONS}
        -U flash:w:${hex_file}
        -P ${AVR_UPLOADTOOL_PORT}
    )

    set(AVR_UPLOADTOOL_UPLOAD_BOOT
            ${AVR_UPLOADTOOL_BASE_OPTIONS} ${AVR_UPLOADTOOL_OPTIONS}
            -U flash:w:${boot_file}
            -P ${AVR_UPLOADTOOL_PORT}
    )

    set(AVR_UPLOADTOOL_UPLOAD_EEPROM
        ${AVR_UPLOADTOOL_BASE_OPTIONS} ${AVR_UPLOADTOOL_OPTIONS}
        -U eeprom:w:${eeprom_image}
        -P ${AVR_UPLOADTOOL_PORT}
    )

    set(AVR_UPLOADTOOL_GET_FUSES
        -U lfuse:r:-:h
        -U hfuse:r:-:h
        -U efuse:r:-:h
        -U lock:r:-:h
        CACHE STRING "Set default options for avrdude to get fuses: -U lfuse:r:-:h -U hfuse:r:-:h -U efuse:r:-:h -U lock:r:-:h"
    )

    set(AVR_UPLOADTOOL_SET_FUSES
        ${AVR_UPLOADTOOL_BASE_OPTIONS} -P ${AVR_UPLOADTOOL_PORT}
        -U lfuse:w:${AVR_L_FUSE}:m
        -U hfuse:w:${AVR_H_FUSE}:m
    )


    set(AVR_UPLOADTOOL_GET_CALIBRATION
        ${AVR_UPLOADTOOL_BASE_OPTIONS} -P ${AVR_UPLOADTOOL_PORT}
        -U calibration:r:${AVR_MCU}_calib.tmp:r
    )


    set(AVR_UPLOADTOOL_SET_CALIBRATION
        ${AVR_UPLOADTOOL_BASE_OPTIONS} -P ${AVR_UPLOADTOOL_PORT}
        -U calibration:w:${AVR_MCU}_calib.hex
    )


endif(AVR_UPLOADTOOL MATCHES avrdude)
if(AVR_UPLOADTOOL MATCHES minipro)
    # default options for minipro
    set(AVR_UPLOADTOOL_OPTIONS
        -p "${MINIPRO_MCU}"
    )

    set(AVR_UPLOADTOOL_GET_STATUS
        ${AVR_UPLOADTOOL_OPTIONS} -z
    )

    set(AVR_UPLOADTOOL_UPLOAD
        ${AVR_UPLOADTOOL_OPTIONS} -c code -w
    )

    set(AVR_UPLOADTOOL_UPLOAD_BOOT
            ${AVR_UPLOADTOOL_OPTIONS} -c code -w
    )

    set(AVR_UPLOADTOOL_UPLOAD_EEPROM
        ${AVR_UPLOADTOOL_OPTIONS} -c data -w
    )

    set(AVR_UPLOADTOOL_GET_FUSES
        ${AVR_UPLOADTOOL_OPTIONS} -c config -r "${AVR_MCU}.fuses.tmp"
    )

    # Write fuses to file
    set(FuseFile "${CMAKE_CURRENT_LIST_DIR}/../${AVR_MCU}.fuses")
    file(WRITE ${FuseFile}
"lfuse = ${AVR_L_FUSE}
hfuse = ${AVR_H_FUSE}
efuse = ${AVR_E_FUSE}
lock = ${AVR_L_FUSE}
"
    )
    set(AVR_UPLOADTOOL_SET_FUSES
        ${AVR_UPLOADTOOL_OPTIONS} -c config -w "${FuseFile}"
    )


    set(AVR_UPLOADTOOL_GET_CALIBRATION
                  ${AVR_UPLOADTOOL_OPTIONS} -c calibration -r "${AVR_MCU}_calib.tmp"
    )


    set(AVR_UPLOADTOOL_SET_CALIBRATION
            ${AVR_UPLOADTOOL_OPTIONS} -c calibration -w "${AVR_MCU}_calib.hex"
    )
endif(AVR_UPLOADTOOL MATCHES minipro)



##########################################################################
# check build types:
# - Debug
# - Release
# - RelWithDebInfo
#
# Release is chosen, because of some optimized functions in the
# AVR toolchain, e.g. _delay_ms().
##########################################################################
if(NOT ((CMAKE_BUILD_TYPE MATCHES Release) OR
(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo) OR
(CMAKE_BUILD_TYPE MATCHES Debug) OR
(CMAKE_BUILD_TYPE MATCHES MinSizeRel)))
    set(
            CMAKE_BUILD_TYPE Release
            CACHE STRING "Choose cmake build type: Debug Release RelWithDebInfo MinSizeRel"
            FORCE
    )
endif(NOT ((CMAKE_BUILD_TYPE MATCHES Release) OR
(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo) OR
(CMAKE_BUILD_TYPE MATCHES Debug) OR
(CMAKE_BUILD_TYPE MATCHES MinSizeRel)))



##########################################################################

##########################################################################
# target file name add-on
##########################################################################
if(WITH_MCU)
    set(MCU_TYPE_FOR_FILENAME "-${AVR_MCU}")
else(WITH_MCU)
    set(MCU_TYPE_FOR_FILENAME "")
endif(WITH_MCU)

##########################################################################
# add_avr_executable
# - IN_VAR: EXECUTABLE_NAME
#
# Creates targets and dependencies for AVR toolchain, building an
# executable. Calls add_executable with ELF file as target name, so
# any link dependencies need to be using that target, e.g. for
# target_link_libraries(<EXECUTABLE_NAME>-${AVR_MCU}.elf ...).
##########################################################################
function(add_avr_executable EXECUTABLE_NAME)

   if(NOT ARGN)
      message(FATAL_ERROR "No source files given for ${EXECUTABLE_NAME}.")
   endif(NOT ARGN)

   # set file names
   set(elf_file ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}.elf)
   set(hex_file ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}.hex)
   set(lst_file ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}.lst)
   set(map_file ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}.map)

   set(eeprom_image ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}-eeprom.hex)

   set (${EXECUTABLE_NAME}_ELF_TARGET ${elf_file} PARENT_SCOPE)
   set (${EXECUTABLE_NAME}_HEX_TARGET ${hex_file} PARENT_SCOPE)
   set (${EXECUTABLE_NAME}_LST_TARGET ${lst_file} PARENT_SCOPE)
   set (${EXECUTABLE_NAME}_MAP_TARGET ${map_file} PARENT_SCOPE)
   set (${EXECUTABLE_NAME}_EEPROM_TARGET ${eeprom_image} PARENT_SCOPE)
   # elf file
   add_executable(${elf_file} EXCLUDE_FROM_ALL ${ARGN})

   set_target_properties(
      ${elf_file}
      PROPERTIES
         COMPILE_FLAGS "-mmcu=${AVR_MCU}"
         LINK_FLAGS "-mmcu=${AVR_MCU} -Wl,--gc-sections -mrelax -Wl,-Map,${map_file}"
   )

   add_custom_command(
      OUTPUT ${hex_file}
      COMMAND
         ${AVR_OBJCOPY} -j .text -j .data -O ihex ${elf_file} ${hex_file}
      COMMAND
         ${AVR_SIZE_TOOL} ${AVR_SIZE_ARGS} ${elf_file}
      DEPENDS ${elf_file}
   )

   add_custom_command(
      OUTPUT ${lst_file}
      COMMAND
         ${AVR_OBJDUMP} -d ${elf_file} > ${lst_file}
      DEPENDS ${elf_file}
   )

   # eeprom
   add_custom_command(
      OUTPUT ${eeprom_image}
      COMMAND
         ${AVR_OBJCOPY} -j .eeprom --set-section-flags=.eeprom=alloc,load
            --change-section-lma .eeprom=0 --no-change-warnings
            -O ihex ${elf_file} ${eeprom_image}
      DEPENDS ${elf_file}
   )

   add_custom_target(
      ${EXECUTABLE_NAME}
      ALL
      DEPENDS ${hex_file} ${lst_file} ${eeprom_image}
   )

   set_target_properties(
      ${EXECUTABLE_NAME}
      PROPERTIES
         OUTPUT_NAME "${elf_file}"
   )

   # clean
   get_directory_property(clean_files ADDITIONAL_MAKE_CLEAN_FILES)
   set_directory_properties(
      PROPERTIES
         ADDITIONAL_MAKE_CLEAN_FILES "${map_file}"
   )

   # upload - with avrdude
   add_custom_target(
           upload_${EXECUTABLE_NAME}
           ${AVR_UPLOADTOOL} ${AVR_UPLOADTOOL_UPLOAD} "${hex_file}"
           DEPENDS ${hex_file}
           COMMENT "Uploading ${hex_file} to ${AVR_MCU} using ${AVR_PROGRAMMER}: ${AVR_UPLOADTOOL_UPLOAD} ${hex_file}"
   )

   # Upload bootloader
   add_custom_target(
           upload_${EXECUTABLE_NAME}_boot
           ${AVR_UPLOADTOOL} ${AVR_UPLOADTOOL_UPLOAD_BOOT} "${boot_file}"
           DEPENDS ${hex_file}
           COMMENT "Uploading ${hex_file} to ${AVR_MCU} using ${AVR_PROGRAMMER}: ${AVR_UPLOADTOOL_UPLOAD} ${boot_file}"
   )

   # upload eeprom only - with avrdude
   # see also bug http://savannah.nongnu.org/bugs/?40142
   add_custom_target(
           upload_${EXECUTABLE_NAME}_eeprom
           ${AVR_UPLOADTOOL} ${AVR_UPLOADTOOL_UPLOAD_EEPROM} "${eeprom_image}"
           DEPENDS ${eeprom_image}
           COMMENT "Uploading ${eeprom_image} to ${AVR_MCU} using ${AVR_PROGRAMMER}: ${AVR_UPLOADTOOL_UPLOAD_EEPROM}"
   )

   # disassemble
   add_custom_target(
      disassemble_${EXECUTABLE_NAME}
      ${AVR_OBJDUMP} -h -S ${elf_file} > ${EXECUTABLE_NAME}.lst
      DEPENDS ${elf_file}
   )
endfunction(add_avr_executable)


##########################################################################
# add_avr_library
# - IN_VAR: LIBRARY_NAME
#
# Calls add_library with an optionally concatenated name
# <LIBRARY_NAME>${MCU_TYPE_FOR_FILENAME}.
# This needs to be used for linking against the library, e.g. calling
# target_link_libraries(...).
##########################################################################
function(add_avr_library LIBRARY_NAME)
    if(NOT ARGN)
        message(FATAL_ERROR "No source files given for ${LIBRARY_NAME}.")
    endif(NOT ARGN)

    set(lib_file ${LIBRARY_NAME}${MCU_TYPE_FOR_FILENAME})
    set (${LIBRARY_NAME}_LIB_TARGET ${elf_file} PARENT_SCOPE)

    add_library(${lib_file} STATIC ${ARGN})

    set_target_properties(
            ${lib_file}
            PROPERTIES
            COMPILE_FLAGS "-mmcu=${AVR_MCU}"
            OUTPUT_NAME "${lib_file}"
    )

    if(NOT TARGET ${LIBRARY_NAME})
        add_custom_target(
                ${LIBRARY_NAME}
                ALL
                DEPENDS ${lib_file}
        )

        set_target_properties(
                ${LIBRARY_NAME}
                PROPERTIES
                OUTPUT_NAME "${lib_file}"
        )
    endif(NOT TARGET ${LIBRARY_NAME})

endfunction(add_avr_library)

##########################################################################
# avr_target_link_libraries
# - IN_VAR: EXECUTABLE_TARGET
# - ARGN  : targets and files to link to
#
# Calls target_link_libraries with AVR target names (concatenation,
# extensions and so on.
##########################################################################
function(avr_target_link_libraries EXECUTABLE_TARGET)
   if(NOT ARGN)
      message(FATAL_ERROR "Nothing to link to ${EXECUTABLE_TARGET}.")
   endif(NOT ARGN)

   get_target_property(TARGET_LIST ${EXECUTABLE_TARGET} OUTPUT_NAME)

   foreach(TGT ${ARGN})
      if(TARGET ${TGT})
         get_target_property(ARG_NAME ${TGT} OUTPUT_NAME)
         list(APPEND NON_TARGET_LIST ${ARG_NAME})
      else(TARGET ${TGT})
         list(APPEND NON_TARGET_LIST ${TGT})
      endif(TARGET ${TGT})
   endforeach(TGT ${ARGN})

   target_link_libraries(${TARGET_LIST} ${NON_TARGET_LIST})
endfunction(avr_target_link_libraries EXECUTABLE_TARGET)

##########################################################################
# avr_target_include_directories
#
# Calls target_include_directories with AVR target names
##########################################################################

function(avr_target_include_directories EXECUTABLE_TARGET)
    if(NOT ARGN)
        message(FATAL_ERROR "No include directories to add to ${EXECUTABLE_TARGET}.")
    endif()

    get_target_property(TARGET_LIST ${EXECUTABLE_TARGET} OUTPUT_NAME)
    set(extra_args ${ARGN})

    target_include_directories(${TARGET_LIST} ${extra_args})
endfunction()

##########################################################################
# avr_target_compile_definitions
#
# Calls target_compile_definitions with AVR target names
##########################################################################

function(avr_target_compile_definitions EXECUTABLE_TARGET)
    if(NOT ARGN)
        message(FATAL_ERROR "No compile definitions to add to ${EXECUTABLE_TARGET}.")
    endif()

    get_target_property(TARGET_LIST ${EXECUTABLE_TARGET} OUTPUT_NAME)
    set(extra_args ${ARGN})

   target_compile_definitions(${TARGET_LIST} ${extra_args})
endfunction()

function(avr_generate_fixed_targets)
   # get status
   add_custom_target(
       get_status
           ${AVR_UPLOADTOOL} ${AVR_UPLOADTOOL_GET_STATUS}
           COMMENT "Get status from ${AVR_MCU}"
   )
   # get fuses
   add_custom_target(
      get_fuses
          ${AVR_UPLOADTOOL} ${AVR_UPLOADTOOL_GET_FUSES}
          COMMENT "Get fuses from ${AVR_MCU}"
   )

   # set fuses
   add_custom_target(
      set_fuses
      ${AVR_UPLOADTOOL} ${AVR_UPLOADTOOL_SET_FUSES}
          COMMENT "Set fuses for ${AVR_MCU}: ${AVR_UPLOADTOOL_SET_FUSES}"
   )

   # get oscillator calibration
   add_custom_target(
      get_calibration
         ${AVR_UPLOADTOOL} ${AVR_UPLOADTOOL_GET_CALIBRATION}
         COMMENT "Get calibration from ${AVR_MCU}"
   )

   # set oscillator calibration
   add_custom_target(
      set_calibration
          ${AVR_UPLOADTOOL} ${AVR_UPLOADTOOL_SET_CALIBRATION}
          COMMENT "Set calibration for ${AVR_MCU}"
   )
endfunction()

##########################################################################
# Bypass the link step in CMake's "compiler sanity test" check
#
# CMake throws in a try_compile() target test in some generators, but does
# not know that this is a cross compiler so the executable can't link.
# Change the target type:
#
# https://stackoverflow.com/q/53633705
##########################################################################

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
