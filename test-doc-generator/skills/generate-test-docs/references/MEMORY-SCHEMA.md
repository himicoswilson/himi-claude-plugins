# 记忆数据结构

定义 `.memory` 目录中各文件的数据结构。

## .memory 目录结构

```
.memory/
├── project-context.json      # 项目上下文信息
├── template-schemas.json     # 学习到的模板结构
├── terminology.json          # 领域术语库
├── naming-conventions.json   # 命名规范
├── generation-history.json   # 生成历史记录
└── user-preferences.json     # 用户交互偏好
```

## 各文件 Schema

### project-context.json

项目基本信息，首次初始化时创建。

```json
{
  "project_name": "string",
  "initialized_at": "ISO datetime",
  "template_dir": "相对路径",
  "requirements_dir": "相对路径",
  "output_dir": "相对路径"
}
```

**字段说明**：
- `project_name`: 项目名称（自动从目录名获取）
- `initialized_at`: 初始化时间
- `template_dir`: 模板文件夹相对路径
- `requirements_dir`: 需求文档相对路径
- `output_dir`: 生成文档输出路径

### template-schemas.json

存储从模板学习到的结构信息。

```json
{
  "test_plan": {
    "source": "模板文件路径",
    "sections": ["章节列表"],
    "placeholders": ["识别到的占位符"],
    "learned_at": "timestamp"
  },
  "test_case": {
    "source": "模板文件路径",
    "columns": ["列名列表"],
    "widths": [列宽列表],
    "id_format": "ID 格式模式",
    "learned_at": "timestamp"
  },
  "test_report": {
    "source": "模板文件路径",
    "sections": ["章节列表"],
    "learned_at": "timestamp"
  }
}
```

**字段说明**：
- `source`: 学习来源的模板文件
- `columns`: Excel 列名列表
- `widths`: 对应列宽
- `id_format`: 用例编号格式（如 `TC_{MODULE}_{SEQ:03d}`）
- `sections`: Markdown 文档章节列表
- `learned_at`: 学习时间戳

### terminology.json

领域术语和缩写映射。

```json
{
  "domain_terms": {
    "术语": "解释"
  },
  "module_abbreviations": {
    "模块名": "缩写"
  }
}
```

**字段说明**：
- `domain_terms`: 领域专业术语及其解释
- `module_abbreviations`: 模块名称到缩写的映射（用于生成用例编号）

### naming-conventions.json

项目命名规范。

```json
{
  "test_case_id": "TC_{MODULE}_{SEQ:03d}",
  "file_naming": "{模块名}_测试用例_{版本}.xlsx",
  "step_format": "numbered | bulleted",
  "language": "zh-CN | en-US"
}
```

**字段说明**：
- `test_case_id`: 用例编号格式模板
- `file_naming`: 输出文件命名规则
- `step_format`: 测试步骤格式（编号或符号）
- `language`: 输出语言

### generation-history.json

生成历史，用于追踪和复用。

```json
{
  "generations": [
    {
      "date": "ISO datetime",
      "type": "test_plan | test_case | test_report",
      "source": "需求文档路径",
      "output": "输出文件路径",
      "case_count": 25,
      "modules": ["涉及的模块"]
    }
  ]
}
```

**字段说明**：
- `date`: 生成时间
- `type`: 文档类型
- `source`: 来源需求文档
- `output`: 输出文件路径
- `case_count`: 生成的用例数量
- `modules`: 涉及的功能模块

### user-preferences.json

用户交互偏好设置，用于记忆用户的操作习惯。

```json
{
  "interaction_mode": "quick | expert",
  "last_output_formats": ["excel", "traceability", "test_plan"],
  "default_output_dir": "./test-docs",
  "show_samples_in_preview": true,
  "auto_confirm_parsing": false,
  "ambiguity_handling": "ask | skip | mark",
  "priority_distribution": {
    "p0_min": 10,
    "p0_max": 15,
    "warn_on_imbalance": true
  },
  "updated_at": "ISO datetime"
}
```

**字段说明**：
- `interaction_mode`: 交互模式（`quick` 快速模式 / `expert` 专家模式）
- `last_output_formats`: 上次选择的输出格式列表
  - `excel`: Excel 测试用例
  - `markdown`: Markdown 测试用例
  - `json`: JSON 格式
  - `traceability`: 需求追溯矩阵
  - `test_plan`: 测试计划文档
  - `test_report`: 测试报告模板
- `default_output_dir`: 默认输出目录
- `show_samples_in_preview`: 预览时是否显示样例用例（Expert 模式）
- `auto_confirm_parsing`: 是否自动确认解析结果（仅 Quick 模式生效）
- `ambiguity_handling`: 歧义处理方式
  - `ask`: 每次询问用户
  - `skip`: 跳过有歧义的需求
  - `mark`: 使用 Claude 理解并标记
- `priority_distribution`: 优先级分布偏好
  - `p0_min`: P0 最小占比
  - `p0_max`: P0 最大占比
  - `warn_on_imbalance`: 分布异常时是否警告
- `updated_at`: 最后更新时间

## 记忆更新规则

1. **创建时机**：首次在项目中使用 Skill
2. **更新时机**：
   - 发现新模板 → 更新 template-schemas
   - 发现新术语 → 更新 terminology
   - 完成生成 → 添加 generation-history
   - 用户反馈 → 调整对应记忆
3. **清除时机**：用户明确要求

## 使用示例

```bash
# 初始化记忆
python3 memory_manager.py --action init --project /path/to/project

# 读取模板结构
python3 memory_manager.py --action read --project . --type template_schemas

# 更新术语
python3 memory_manager.py --action update --project . --type terminology \
  --data '{"domain_terms": {"SKU": "库存单位"}}'

# 添加生成记录
python3 memory_manager.py --action add-record --project . \
  --data '{"type": "test_case", "source": "PRD.pdf", "output": "用例.xlsx", "case_count": 20}'

# 清除记忆
python3 memory_manager.py --action clear --project .
```
