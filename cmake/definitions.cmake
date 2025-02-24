
# Find some info on what to put here
# https://github.com/MCUdude/MiniCore/blob/de8b4e20cdae6b0d8f3102b2d3ecc59307373684/avr/boards.txt




set(CMAKE_FIND_ROOT_PATH "/usr/lib/avr")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_SYSTEM_INCLUDE_PATH "${CMAKE_FIND_ROOT_PATH}/include")
set(CMAKE_SYSTEM_LIBRARY_PATH "${CMAKE_FIND_ROOT_PATH}/lib")

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif(NOT CMAKE_BUILD_TYPE)

if(CMAKE_BUILD_TYPE MATCHES Release)
    set(CMAKE_C_FLAGS_RELEASE "-O1")
    set(CMAKE_CXX_FLAGS_RELEASE "-O1")
endif(CMAKE_BUILD_TYPE MATCHES Release)

if(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O1 -save-temps -g -gdwarf-3 ")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O1 -save-temps -g -gdwarf-3 ")
endif(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)

if(CMAKE_BUILD_TYPE MATCHES Debug)
    set(CMAKE_C_FLAGS_DEBUG "-O1 -save-temps -g -gdwarf-3 ")
    set(CMAKE_CXX_FLAGS_DEBUG "-O1 -save-temps -g -gdwarf-3 ")
endif(CMAKE_BUILD_TYPE MATCHES Debug)


add_definitions("-fpack-struct")
add_definitions("-fshort-enums")
add_definitions("-Wall")
add_definitions("-Werror")
# Enable these once you've debugged the more pressing concerns, also replace the previous def with -Wwarning
#add_definitions("-pedantic")
#add_definitions("-pedantic-errors")
add_definitions("-funsigned-char")
add_definitions("-funsigned-bitfields")
add_definitions("-ffunction-sections")
add_definitions("-c")
