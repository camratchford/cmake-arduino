
include(${CMAKE_CURRENT_LIST_DIR}/macros.cmake)
set(Core ${CMAKE_CURRENT_LIST_DIR}/../third-party/minicore/avr)

# MiniCore Core
set(CoreFiles  ${Core}/cores/MCUdude_corefiles)
file(GLOB CoreIncludes ${CoreFiles}/*.h)
file(GLOB CoreCSources ${CoreFiles}/*.c)
file(GLOB CoreCPPSources ${CoreFiles}/*.cpp)

# Minicore Core Extra Libraries
set(CoreLibraries ${Core}/libraries)
file(GLOB CoreLibs ${CoreLibraries}/**/src )

# Variant
set(StdVariant ${Core}/variants/standard)
set(PBVariant ${Core}/variants/pb-variant)
string(REGEX MATCH "(pb)$" IS_PB ${AVR_MCU})
if(IS_PB)
    set(Variant ${PBVariant})
else()
    set(Variant ${StdVariant})
    file(GLOB RemovedItems "${CoreLibraries}/*1/src")
    if(RemovedItems)
        list(REMOVE_ITEM CoreLibs ${RemovedItems})
  endif(RemovedItems)
endif(IS_PB)

# Minicore Core Extra Libraries - Files
foreach(lib IN LISTS CoreLibs)
    file(GLOB_RECURSE headers ${lib}/*.h)
    set(libIncludes "${CoreLibIncludes};${headers}")
    file(GLOB_RECURSE csources ${lib}/*.c)
    set(libCSources "${CoreLibCSources};${csources}")
    file(GLOB_RECURSE cppsources ${lib}/*.cpp)
    set(libCPPSources "${CoreLibCPPSources};${cppsources}")
endforeach()

set(CoreIncludes ${libIncludes})
set(CoreCSources ${libCSources})
set(CoreCPPSources ${libCPPSources})

# Select a bootloader that matches the current configuration
if (NOT eeprom_image)
    set(bootloader_leaf ${AVR_MCU}/${AVR_FREQ}/optiboot_flash_${AVR_MCU}_${AVR_UART}_${AVR_BAUD_RATE}_${AVR_FREQ}_${AVR_LED_PIN}.hex)
    set(eeprom_image
            ${Core}/bootloaders/optiboot_flash/bootloaders/${bootloader_leaf}
    )
endif(NOT eeprom_image)
