# 交互模式与问题模板

本文档定义测试文档生成器的交互模式、检查点问题模板和歧义处理规则。

---

## 交互模式定义

### 模式类型

| 模式 | 名称 | 适用场景 | 确认方式 |
|------|------|---------|---------|
| `quick` | 快速模式 | 日常生成、熟悉流程 | 回车继续 |
| `expert` | 专家模式 | 首次使用、精细控制 | 显式确认 |

### 模式选择时机

1. **首次运行**：使用 AskUserQuestion 询问模式偏好
2. **命令切换**：用户输入"切换模式"时切换
3. **记忆恢复**：从 `.memory/user-preferences.json` 读取

### 模式切换命令

用户可随时通过以下命令切换模式：
- `切换模式` / `switch mode`
- `快速模式` / `quick mode`
- `专家模式` / `expert mode`

---

## 检查点定义

### 检查点概览

| 检查点 | 阶段 | Quick 行为 | Expert 行为 |
|--------|------|-----------|-------------|
| 模式选择 | Phase 0 | 仅首次询问 | 仅首次询问 |
| 解析确认 | Phase 2.5 | 摘要+问题时询问 | 完整列表+等待确认 |
| 歧义处理 | Phase 2.6 | 仅关键歧义 | 所有歧义 |
| 生成预览 | Phase 2.8 | 统计数据 | 统计+样例+可调整 |
| 输出选择 | Phase 2.9 | 确认默认 | 完整选择 |

---

## 问题模板

### 1. 模式选择（首次运行）

**触发条件**：`.memory/user-preferences.json` 不存在或无 `interaction_mode` 字段

**AskUserQuestion 配置**：
```yaml
questions:
  - question: "请选择测试文档生成的交互模式"
    header: "交互模式"
    multiSelect: false
    options:
      - label: "专家模式 (Expert)"
        description: "完全控制，每个阶段确认，适合首次使用或需要精细调整"
      - label: "快速模式 (Quick)"
        description: "最少确认，自动使用默认配置，适合熟悉流程的日常使用"
```

**后续处理**：
- 存储选择到 `.memory/user-preferences.json`
- 显示提示："模式已保存，可通过'切换模式'命令随时更改"

---

### 2. 检查点1：解析确认

**触发条件**：Phase 2 解析完成后

#### Expert 模式

**显示内容**：
```markdown
## 需求解析确认

### 识别的模块 ({module_count}个)

| 模块名称 | 需求数 | 缩写 | 风险等级 |
|---------|-------|------|---------|
| {name} | {count} | {abbr} | {risk} |

### 提取的需求ID ({req_count}个)

| 需求ID | 需求名称 | 验收条件数 | 设计方法 |
|--------|---------|-----------|---------|
| {id} | {name} | {ac_count} | {methods} |

(显示前10条，共{total}条)

### 识别的业务规则 ({rule_count}条)

- {rule_description}

### 识别的边界条件 ({boundary_count}个)

| 输入项 | 类型 | 边界值 |
|-------|------|-------|
| {field} | {type} | {value} |
```

**AskUserQuestion 配置**：
```yaml
questions:
  - question: "请确认解析结果是否正确"
    header: "解析确认"
    multiSelect: false
    options:
      - label: "确认，继续生成"
        description: "解析结果正确，开始生成测试用例"
      - label: "查看完整列表"
        description: "显示所有识别的需求和规则"
      - label: "需要修改"
        description: "有错误需要修正（将进入修改模式）"
      - label: "重新解析"
        description: "重新读取和解析需求文档"
```

#### Quick 模式

**显示内容**：
```markdown
## 解析完成

已识别 **{module_count}** 个模块，**{req_count}** 条需求，**{rule_count}** 条业务规则

{如果有警告}
⚠️ 发现以下潜在问题：
- {warning_message}
```

**AskUserQuestion 配置**（仅有警告时）：
```yaml
questions:
  - question: "发现潜在问题，如何处理？"
    header: "解析警告"
    multiSelect: false
    options:
      - label: "忽略，继续生成"
        description: "问题不影响生成质量"
      - label: "查看详情"
        description: "显示完整解析结果"
      - label: "切换到专家模式"
        description: "进入专家模式进行详细确认"
```

**无警告时**：显示摘要后自动继续

---

### 3. 歧义处理

**触发条件**：检测到不明确的需求描述

**歧义类型**：

| 类型代码 | 类型名称 | 检测模式 | 询问重点 |
|---------|---------|---------|---------|
| `BOUNDARY_UNCLEAR` | 边界不明确 | "适当"、"合理"、"一定" | 询问具体数值 |
| `RULE_CONFLICT` | 规则冲突 | 互斥条件 | 询问优先级 |
| `MISSING_ERROR` | 缺少错误处理 | 无失败子句 | 询问预期行为 |
| `VAGUE_CRITERIA` | 模糊验收标准 | "正常"、"正确" | 询问具体结果 |
| `INCOMPLETE_FLOW` | 流程不完整 | 缺少步骤 | 询问完整流程 |

**AskUserQuestion 配置**：
```yaml
questions:
  - question: "需求存在歧义，请帮助澄清"
    header: "歧义 {current}/{total}"
    multiSelect: false
    options:
      - label: "接受我的理解"
        description: "{interpretation}"
      - label: "提供不同解释"
        description: "我将输入正确的理解"
      - label: "跳过此需求"
        description: "不为此需求生成用例"
      - label: "标记为待确认"
        description: "生成用例但添加待确认标记"
```

**显示上下文**：
```markdown
## 需求歧义确认 ({current}/{total})

**需求原文**：
> {original_text}

**歧义类型**：{ambiguity_type_name}

**我的理解**：
{claude_interpretation}

**影响范围**：
- 可能影响 {affected_cases} 条用例
- 涉及模块：{affected_modules}
```

#### Quick 模式歧义过滤

Quick 模式仅询问以下情况：
- 影响 P0/P1 用例的歧义
- 涉及核心业务流程的歧义
- 可能导致生成错误的关键歧义

其他歧义自动采用 Claude 的理解，并在生成结果中标注。

---

### 4. 检查点2：生成预览

**触发条件**：歧义处理完成，准备生成用例

#### Expert 模式

**显示内容**：
```markdown
## 生成预览

### 优先级分布

| 优先级 | 数量 | 占比 | 状态 |
|--------|------|------|------|
| P0 冒烟 | {p0_count} | {p0_percent}% | {status} |
| P1 核心 | {p1_count} | {p1_percent}% | {status} |
| P2 全量 | {p2_count} | {p2_percent}% | {status} |
| P3 边缘 | {p3_count} | {p3_percent}% | {status} |

预计生成 **{total_cases}** 条用例，覆盖 **{coverage_rate}%** 需求

### 设计方法分布

| 方法 | 数量 | 说明 |
|------|------|------|
| EP (等价类) | {ep_count} | 有效/无效输入 |
| BVA (边界值) | {bva_count} | 边界条件 |
| ST (场景法) | {st_count} | 业务流程 |
| EG (错误推测) | {eg_count} | 经验补充 |

### 样例用例预览

**P0 样例**：
> {p0_sample_title}
> 设计方法: {method} | 关联需求: {req_id}

**P1 样例**：
> {p1_sample_title}
> 设计方法: {method} | 关联需求: {req_id}

**P2 样例**：
> {p2_sample_title}
> 设计方法: {method} | 关联需求: {req_id}
```

**AskUserQuestion 配置**：
```yaml
questions:
  - question: "请确认用例生成方案"
    header: "生成确认"
    multiSelect: false
    options:
      - label: "确认，开始生成"
        description: "按当前方案生成测试用例"
      - label: "调整优先级分布"
        description: "修改 P0-P3 的比例"
      - label: "增加特定类型用例"
        description: "补充更多边界值/错误推测用例"
      - label: "预览特定模块"
        description: "查看某个模块的详细用例"
```

#### Quick 模式

**显示内容**：
```markdown
## 生成预览

将生成 **{total_cases}** 条用例：
P0:{p0} | P1:{p1} | P2:{p2} | P3:{p3}

覆盖率: {coverage_rate}%
```

**AskUserQuestion 配置**（仅分布异常时）：
```yaml
questions:
  - question: "P0比例({p0_percent}%)超出建议范围(10-15%)，是否调整？"
    header: "分布警告"
    multiSelect: false
    options:
      - label: "自动调整到建议范围"
        description: "将部分 P0 用例降级为 P1"
      - label: "保持当前分布"
        description: "不做调整，继续生成"
      - label: "切换到专家模式"
        description: "手动调整优先级分布"
```

---

### 5. 检查点3：输出选择

**触发条件**：生成预览确认后

#### Expert 模式

**AskUserQuestion 配置**：
```yaml
questions:
  - question: "请选择需要生成的文档格式"
    header: "输出格式"
    multiSelect: true
    options:
      - label: "Excel 测试用例 (推荐)"
        description: "包含用例详情、追溯矩阵、覆盖统计"
      - label: "Markdown 测试用例"
        description: "纯文本格式，适合版本控制"
      - label: "测试计划文档"
        description: "8章节结构的测试计划"
      - label: "测试报告模板"
        description: "5章节结构的测试报告模板"
  - question: "是否生成需求追溯矩阵？"
    header: "追溯矩阵"
    multiSelect: false
    options:
      - label: "是，包含在Excel中"
        description: "在Excel中添加独立的追溯矩阵Sheet"
      - label: "是，单独生成文件"
        description: "生成独立的追溯矩阵Excel文件"
      - label: "否，不需要"
        description: "不生成追溯矩阵"
```

#### Quick 模式

**显示内容**：
```markdown
## 输出确认

将生成以下文档：
- ✅ 测试用例 Excel（含追溯矩阵）
- ✅ 覆盖率统计

输出目录: {output_dir}
```

**AskUserQuestion 配置**：
```yaml
questions:
  - question: "确认输出配置？"
    header: "输出确认"
    multiSelect: false
    options:
      - label: "确认，开始生成"
        description: "使用上述配置生成文档"
      - label: "更多选项"
        description: "选择其他输出格式或调整配置"
```

---

## 响应处理规则

### 用户响应映射

| 用户输入 | 处理动作 |
|---------|---------|
| `确认` / `ok` / `yes` / `y` | 继续下一步 |
| `取消` / `cancel` / `no` / `n` | 中止流程 |
| `详情` / `detail` / `more` | 显示详细信息 |
| `修改` / `edit` / `change` | 进入修改模式 |
| `重试` / `retry` / `redo` | 重新执行当前步骤 |
| `帮助` / `help` / `?` | 显示当前步骤帮助 |

### 超时处理

| 模式 | 超时时间 | 超时行为 |
|------|---------|---------|
| Quick | 无超时 | 自动继续 |
| Expert | 无超时 | 等待用户输入 |

### 错误恢复

当用户输入无法识别时：
1. 显示可用选项列表
2. 提示正确的输入格式
3. 等待用户重新输入

---

## 进度指示

### 流程进度显示

```
[■■■■■□□□□□] 50% - 正在解析需求...

阶段: 2/5 需求解析
已处理: 10/20 个需求
当前: 分析登录模块边界条件
```

### 检查点进度

```
检查点 1/3: 解析确认
└── ✓ 模块识别完成
└── ✓ 需求提取完成
└── → 等待用户确认
```

---

## 记忆集成

### 偏好自动应用

从 `.memory/user-preferences.json` 读取：
- `interaction_mode`: 自动设置交互模式
- `last_output_formats`: 作为输出选择的默认值
- `default_output_dir`: 作为输出目录的默认值

### 学习用户习惯

记录以下信息供后续优化：
- 用户常用的输出格式组合
- 用户对歧义的处理偏好
- 用户常调整的优先级比例
