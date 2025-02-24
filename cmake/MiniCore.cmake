
include(${CMAKE_CURRENT_LIST_DIR}/macros.cmake)
set(Core ${CMAKE_CURRENT_LIST_DIR}/../third-party/minicore/avr)

# MiniCore Core
set(CoreFiles  ${Core}/cores/MCUdude_corefiles)
set(CoreIncludes PARENT_SCOPE)
set(CoreCSources PARENT_SCOPE)
set(CoreCPPSources PARENT_SCOPE)
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
    list(REMOVE_ITEM CoreLibs ${RemovedItems})
endif(IS_PB)

# Minicore Core Extra Libraries - Files
set(CoreLibIncludes PARENT_SCOPE)
set(CoreLibCSources PARENT_SCOPE)
set(CoreLibCPPSources PARENT_SCOPE)
foreach(lib IN LISTS CoreLibs)
    file(GLOB_RECURSE headers ${lib}/*.h)
    set(CoreLibIncludes "${CoreLibIncludes};${headers}")
    file(GLOB_RECURSE csources ${lib}/*.c)
    set(CoreLibCSources "${CoreLibCSources};${csources}")
    file(GLOB_RECURSE cppsources ${lib}/*.cpp)
    set(CoreLibCPPSources "${CoreLibCPPSources};${cppsources}")
endforeach()

# Select a bootloader that matches the current configuration
if (NOT eeprom_image)
    set(bootloader_leaf ${AVR_MCU}/${AVR_FREQ}/optiboot_flash_${AVR_MCU}_${AVR_UART}_${AVR_BAUD_RATE}_${AVR_FREQ}_${AVR_LED_PIN}.hex)
    set(eeprom_image
            ${Core}/bootloaders/optiboot_flash/bootloaders/${bootloader_leaf}
            PARENT_SCOPE
    )
endif(NOT eeprom_image)