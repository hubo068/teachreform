# DNN 用于语音识别：双端使用说明

## 文件说明

| 文件 | 用途 |
|---|---|
| `ASR_DNN_student.ipynb` | 学生端，只答题、运行实验、导出 `ASR_DNN_checkpoint_records.json` |
| `ASR_DNN_teacher_rubric.ipynb` | 老师端，读取学生答题记录，按 rubric 生成反馈报告 |
| `ASR_DNN_teacher_feedback_report.md` | 老师端运行后生成的学生学习反馈报告 |

## 当前采用模式

本示例采用 `asr-teaching-assistant` 的**安全分发模式**：

- 学生端只答题和导出记录；
- 老师端读取记录并生成反馈；
- 标准答案、rubric、补讲建议不放进学生端 notebook。

另外两种模式：

- **AI 在线助教模式**：AI 在课堂对话中即时判断、补讲、追问，适合小班或现场陪练。
- **自学自动判分模式**：notebook 可自动判分和提示，但只适合低风险练习，不适合正式考核。

## 学生端原则

学生端不包含标准答案、补讲内容、关键词判分表或 rubric。它只记录：

- 学生姓名和学号；
- 每个 checkpoint 的问题；
- 学生开放式回答；
- 学生自评；
- 实验测试集准确率。

## 老师端 rubric

| 档位 | 判定依据 |
|---|---|
| 已掌握 | 能说明核心原因，术语基本准确，并能联系刚才的代码或结果 |
| 部分掌握 | 方向正确，但缺少关键机制，或表达不够完整 |
| 需补讲 | 回答暴露明显误解，需要课堂即时补充讲解 |
| 需教师介入 | 多次无法解释，或暴露出前置知识断点 |

## 使用流程

1. 学生打开并运行 `ASR_DNN_student.ipynb`。
2. 学生完成所有 checkpoint 后，生成 `ASR_DNN_checkpoint_records.json`。
3. 老师将该 JSON 与 `ASR_DNN_teacher_rubric.ipynb` 放在同一目录。
4. 老师运行 `ASR_DNN_teacher_rubric.ipynb`。
5. 如需人工修正，在 `manual_overrides` 中调整具体 checkpoint 的诊断档位。
6. 运行最后一个 cell，生成 `ASR_DNN_teacher_feedback_report.md`。
