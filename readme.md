# STM32F103C8T6 项目模板

基于 STM32 标准外设库 V3.6.0 + CMake + arm-none-eabi-gcc，
开箱即用的 STM32F103C8T6 裸机开发模板。

## 快速开始

```bash
# 安装工具链 (macOS)
brew install arm-none-eabi-gcc cmake stlink

# 编译 & 烧录
./f1flow build flash

# 一键完整流程
./f1flow full
```

## f1flow 命令

| 命令     | 说明                             |
| -------- | -------------------------------- |
| `check`  | 检查工具链和环境                 |
| `build`  | 编译项目 (默认 Debug)            |
| `clean`  | 清理构建产物                     |
| `flash`  | 烧录固件到 STM32                 |
| `verify` | 验证烧录内容                     |
| `reset`  | 重置开发板                       |
| `size`   | 查看固件段大小                   |
| `full`   | 一键: check → clean → build → flash |

支持链式执行：`./f1flow clean build flash verify`

Release 编译：`BUILD_TYPE=Release ./f1flow build`

## 项目结构

```
├── CMakeLists.txt                 # CMake 构建配置
├── arm-none-eabi-toolchain.cmake  # 交叉编译工具链
├── f1flow                         # 项目管理脚本
├── ld/stm32_flash.ld              # 链接器脚本 (64KB Flash / 20KB RAM)
├── driver/                        # 标准外设库驱动 (.c)
├── inc/
│   ├── driver/                    # 驱动头文件
│   └── user/                      # 用户头文件
├── src/
│   ├── system/                    # 启动文件 / 系统时钟
│   └── user/
│       ├── main.c                 # 入口
│       └── stm32f10x_it.c         # 中断服务
└── .vscode/                       # VS Code 配置 (可选)
```

## 添加外设

1. 打开 `inc/user/stm32f10x_conf.h`，确认对应外设头文件已包含
2. 在 `src/user/` 下写功能代码
3. CMakeLists.txt 会自动扫描 `src/user/*.c`，无需手动添加

```c
// 示例：初始化 PA5 为推挽输出
RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
GPIO_InitTypeDef gpio = {
    .GPIO_Pin   = GPIO_Pin_5,
    .GPIO_Mode  = GPIO_Mode_Out_PP,
    .GPIO_Speed = GPIO_Speed_50MHz,
};
GPIO_Init(GPIOA, &gpio);
```

## 芯片适配

默认配置为 STM32F103C8T6 (中等密度, `STM32F10X_MD`)。
更换其他 F1 系列芯片时修改：

- `CMakeLists.txt` — `STM32F10X_MD` → `STM32F10X_HD` 等
- `ld/stm32_flash.ld` — Flash/RAM 容量

## 硬件

| 参数   | 详情            |
| ------ | --------------- |
| MCU    | STM32F103C8T6   |
| 内核   | Cortex-M3       |
| 主频   | 72MHz           |
| Flash  | 64KB            |
| SRAM   | 20KB            |
