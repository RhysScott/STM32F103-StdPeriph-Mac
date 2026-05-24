cmake_minimum_required(VERSION 3.16)

# 交叉编译 — 必须在 project() 之前
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
if(NOT CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "${CMAKE_SOURCE_DIR}/arm-none-eabi-toolchain.cmake"
        CACHE FILEPATH "" FORCE)
endif()

project(STM32F103C8T6 C CXX ASM)

# 构建类型
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Debug | Release | MinSizeRel" FORCE)
endif()

# MCU 参数
set(MCU_FLAGS -mcpu=cortex-m3 -mthumb -mfloat-abi=soft)

# 源文件
set(SYSTEM_SRCS
    src/system/startup_stm32f10x_md.s
    src/system/core_cm3.c
    src/system/system_stm32f10x.c)
file(GLOB_RECURSE DRIVER_SRCS CONFIGURE_DEPENDS driver/*.c driver/*.cpp)
file(GLOB_RECURSE USER_SRCS   CONFIGURE_DEPENDS src/user/*.c src/user/*.cpp)

add_executable(${PROJECT_NAME} ${SYSTEM_SRCS} ${DRIVER_SRCS} ${USER_SRCS})
target_include_directories(${PROJECT_NAME} PRIVATE inc/driver inc/user src/system)
target_compile_definitions(${PROJECT_NAME} PRIVATE
    STM32F10X_MD USE_STDPERIPH_DRIVER HSE_VALUE=8000000U)

# 编译选项
target_compile_options(${PROJECT_NAME} PRIVATE
    ${MCU_FLAGS}
    -Wall -Wextra
    -ffunction-sections -fdata-sections
    $<$<CONFIG:Debug>:-Og -g3>
    $<$<CONFIG:Release>:-O2>)
target_compile_options(${PROJECT_NAME} PRIVATE
    $<$<COMPILE_LANGUAGE:C>:-std=c11>
    $<$<COMPILE_LANGUAGE:CXX>:-std=c++17 -fno-exceptions -fno-rtti>)

# 汇编文件
set_source_files_properties(
    src/system/startup_stm32f10x_md.s
    PROPERTIES COMPILE_OPTIONS "${MCU_FLAGS};-xassembler-with-cpp")

# 链接
target_link_options(${PROJECT_NAME} PRIVATE
    ${MCU_FLAGS}
    -T${CMAKE_SOURCE_DIR}/ld/stm32_flash.ld
    -specs=nosys.specs -specs=nano.specs
    -Wl,--gc-sections -Wl,-Map=${PROJECT_NAME}.map
    -lc -lm -lnosys)

set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".elf")

# 构建后生成 .bin + .hex
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary "$<TARGET_FILE:${PROJECT_NAME}>" "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.bin"
    COMMAND ${CMAKE_OBJCOPY} -O ihex   "$<TARGET_FILE:${PROJECT_NAME}>" "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.hex"
    COMMAND ${CMAKE_SIZE} "$<TARGET_FILE:${PROJECT_NAME}>"
    COMMENT "生成 ${PROJECT_NAME}.elf/.bin/.hex")
