# ==============================================================================
# ARM Cortex-M 交叉编译工具链配置
# 适配 arm-none-eabi-gcc (GNU Arm Embedded Toolchain)
# ==============================================================================

# 目标系统：裸机（无操作系统）
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# 工具链前缀（需在 PATH 中可找到）
set(TOOLCHAIN_PREFIX arm-none-eabi)

# 编译器
find_program(CMAKE_C_COMPILER   NAMES ${TOOLCHAIN_PREFIX}-gcc   REQUIRED)
find_program(CMAKE_CXX_COMPILER NAMES ${TOOLCHAIN_PREFIX}-g++   REQUIRED)
find_program(CMAKE_ASM_COMPILER NAMES ${TOOLCHAIN_PREFIX}-gcc   REQUIRED)

# 工具
find_program(CMAKE_OBJCOPY NAMES ${TOOLCHAIN_PREFIX}-objcopy REQUIRED)
find_program(CMAKE_OBJDUMP NAMES ${TOOLCHAIN_PREFIX}-objdump REQUIRED)
find_program(CMAKE_SIZE    NAMES ${TOOLCHAIN_PREFIX}-size    REQUIRED)

# 仅在交叉编译目标路径查找库和头文件（不碰主机系统的）
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
