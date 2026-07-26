# Windows stdin 检测修复

## 问题描述

在 Windows 环境下（CMD、PowerShell、Git Bash）运行 `claude-dsp` 或其他启动脚本时，会出现以下警告：

```
Warning: no stdin data received in 3s, proceeding without it. If piping from a slow command, redirect stdin explicitly: < /dev/null to skip, or wait longer.
```

**根本原因**：Windows 的终端模拟器对标准输入的处理方式与 Linux/Mac 不同。在某些情况下，即使从终端直接运行命令（没有管道重定向），`process.stdin.isTTY` 也可能返回 `false`，导致程序误认为有来自管道的输入，从而触发 3 秒的等待。

## 解决方案

### 方案1：使用 `--no-stdin` 参数（推荐）

通过命令行参数跳过 stdin 等待检测：

```bash
# 直接运行
./claude-dsp --no-stdin

# 或指定 prompt
./claude-dsp -p "your command" --no-stdin
```

### 方案2：设置环境变量

设置 `CLAUDE_CODE_NO_STDIN=1` 来跳过检测：

**PowerShell**：
```powershell
$env:CLAUDE_CODE_NO_STDIN="1"
./claude-dsp
```

**CMD**：
```cmd
set CLAUDE_CODE_NO_STDIN=1
claude-dsp
```

**Git Bash**：
```bash
export CLAUDE_CODE_NO_STDIN=1
./claude-dsp
```

### 方案3：自动检测（已启用）

脚本会自动检测 Windows 环境（Git Bash/MSYS2/Cygwin）并自动添加 `--no-stdin` 参数，无需手动指定。

### 方案4：显式忽略 stdin

使用输入重定向来跳过 stdin：

```bash
./claude-dsp < /dev/null
```

或在 PowerShell 中：
```powershell
./claude-dsp < $null
```

## 技术细节

### 修改内容

1. **`src/main.tsx`**：
   - 修改 `getInputPrompt` 函数，添加 `skipStdin` 参数
   - 支持通过 `--no-stdin` 命令行选项或 `CLAUDE_CODE_NO_STDIN` 环境变量跳过检测
   - 在 Windows 平台上改进警告提示，说明可能的原因和解决方案

2. **`claude-dsp` 脚本**：
   - 添加 Windows 环境自动检测
   - 在检测到 Windows 环境时自动添加 `--no-stdin` 参数
   - 支持 Git Bash、MSYS2、Cygwin 等 Windows 环境

### 新增选项

- `--no-stdin`：跳过 stdin 等待检测。适用于 Windows 终端和需要确保不从 stdin 读取输入的场景。

### 新增环境变量

- `CLAUDE_CODE_NO_STDIN=1`：设置此环境变量可跳过 stdin 检测。

## 兼容性

- ✅ **Linux**：无需修改，正常工作
- ✅ **macOS**：无需修改，正常工作  
- ✅ **Windows (Git Bash)**：自动检测并跳过 stdin 检测
- ✅ **Windows (MSYS2)**：自动检测并跳过 stdin 检测
- ✅ **Windows (Cygwin)**：自动检测并跳过 stdin 检测
- ✅ **Windows (CMD/PowerShell)**：建议使用 `--no-stdin` 或设置环境变量

## 测试建议

1. **在 Windows 上测试**：
   ```bash
   # 测试不带参数
   ./claude-dsp

   # 测试带 --no-stdin
   ./claude-dsp --no-stdin

   # 测试带 prompt
   ./claude-dsp -p "hello" --no-stdin

   # 测试环境变量
   CLAUDE_CODE_NO_STDIN=1 ./claude-dsp
   ```

2. **在 Linux/Mac 上测试**：
   ```bash
   # 确保原有功能正常
   ./claude-dsp

   # 测试 --no-stdin 是否有影响
   ./claude-dsp --no-stdin
   ```

## 向后兼容性

- ✅ 所有现有的命令行选项继续有效
- ✅ 没有 `--no-stdin` 时，行为与修改前完全一致
- ✅ 在非 Windows 环境下，默认行为不变
- ✅ 环境变量设置是可选的

## 注意事项

1. 使用 `--no-stdin` 后，程序将不会等待任何 stdin 输入
2. 如果确实需要从管道读取输入，不要使用此选项
3. 此修复主要用于消除 Windows 环境下的误报警告，不影响实际功能
