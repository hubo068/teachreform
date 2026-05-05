# 学生学习反馈报告：DNN 用于语音识别

## 1. 任务摘要

| 项 | 内容 |
|---|---|
| 课程章节 | DNN 声学模型用于语音识别 |
| 技术栈 | PyTorch、NumPy、scikit-learn 辅助划分与评价 |
| Notebook | `ASR_DNN_PyTorch_interactive.ipynb` |
| 实验目标 | 理解声学特征输入、DNN 输出层、logits、训练循环、评估模式与解码意识 |

## 2. Checkpoint 设计

| 步骤 | 知识点 | 诊断问题 |
|---|---|---|
| Step 1 | DNN 声学模型输入 | 为什么通常输入分帧后的声学特征，而不是整段原始 wav？ |
| Step 2 | 特征维度与类别数 | 输入层维度对应特征维度还是类别数？ |
| Step 3 | 泛化评价 | 为什么要留出测试集，而不是只看训练集准确率？ |
| Step 4 | 输出层设计 | 输出层 4 个单元对应什么？ |
| Step 5 | logits 与 CrossEntropyLoss | CrossEntropyLoss 接收 logits 还是 softmax 概率？ |
| Step 5 | 梯度清零 | 为什么每个 batch 要执行 `optimizer.zero_grad()`？ |
| Step 6 | 评估模式 | 为什么评估时使用 `model.eval()` 和 `torch.no_grad()`？ |
| Step 7 | ASR 序列评价 | 从数字分类扩展到完整句子识别时，只看 accuracy 够不够？ |

## 3. 课堂使用说明

学生运行 notebook 时，每个 checkpoint 的回答会记录在 `checkpoint_records` 中。最后一个 cell 会根据学生实际回答生成学习反馈报告。

本静态报告是教师端预置版本；真正的学生个体诊断应以 notebook 运行后生成的报告为准。

## 4. 预期掌握点

- 能说明 DNN 声学模型通常输入声学特征，而不是直接输入整段原始波形。
- 能区分输入层维度、输出层维度和类别数。
- 能说明训练集、测试集划分与泛化评价的关系。
- 能理解 PyTorch 中 `CrossEntropyLoss` 直接接收 logits。
- 能解释 `zero_grad()`、`backward()`、`step()` 的训练顺序。
- 能说明 `model.eval()` 和 `torch.no_grad()` 的评估作用。
- 能意识到完整 ASR 更适合使用 CER/WER 等序列评价指标。

## 5. 教师建议

如果学生在声学特征问题上答错，建议补讲“短时平稳”和 MFCC/FBank 的直观含义。  
如果学生在 logits 问题上答错，建议用一组 logits、softmax 概率和类别标签演示交叉熵计算关系。  
如果学生在评价指标问题上答错，建议用一句包含插入、删除、替换错误的识别结果演示 CER/WER。
