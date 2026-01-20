# test-doc-generator

自主学习型测试文档生成器 - 从需求文档生成测试计划、测试用例、测试报告。

## 功能

- **需求驱动**：从 PRD、用户故事、功能说明书等需求文档自动提取测试场景
- **多格式支持**：支持 PDF、Word、Markdown 格式的需求文档
- **自定义模板**：学习并使用用户自己的文档模板
- **持久化记忆**：记住项目结构、领域术语、命名规范，持续改进生成质量

## 安装

### 依赖

```bash
pip install openpyxl PyMuPDF python-docx
```

### 插件安装

将此插件添加到 Claude Code 插件目录。

## 使用

### 项目结构

建议的项目结构：

```
your-project/
├── templates/              # 测试文档模板
│   ├── 测试计划模板.md
│   ├── 测试用例模板.xlsx
│   └── 测试报告模板.md
├── requirements/           # 需求文档
│   ├── PRD-v1.0.pdf
│   └── 用户故事.docx
└── .memory/                # Skill 自动创建
```

### 基本用法

```
用户：根据 requirements/登录模块.md 生成测试用例

Skill：
1. 读取需求文档
2. 提取功能点和验收条件
3. 生成测试场景
4. 按模板格式输出 Excel
```

### 记忆管理

```
"更新术语表"    → 重新扫描并更新术语库
"重新学习模板"  → 重新解析模板结构
"清除记忆"      → 删除 .memory 文件夹
```

## 输出格式

| 类型 | 格式 | 说明 |
|------|------|------|
| 测试计划 | Markdown | 固定8章节结构 |
| 测试用例 | Excel (.xlsx) | 支持自定义列 |
| 测试报告 | Markdown | 固定5章节结构 |

## 技术架构

```
skills/generate-test-docs/
├── SKILL.md                    # Skill 定义
├── scripts/
│   ├── extract_document.py     # 文档提取
│   ├── generate_excel.py       # Excel 生成
│   └── memory_manager.py       # 记忆管理
└── references/
    ├── PARSING-RULES.md        # 需求解析规则
    ├── MEMORY-SCHEMA.md        # 记忆数据结构
    └── LEARNING-RULES.md       # 学习规则
```

## 许可证

MIT License
