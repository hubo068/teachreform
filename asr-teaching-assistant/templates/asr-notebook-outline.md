# ASR Notebook Outline

生成 `<topic>.ipynb` 时按此结构组织。可以根据章节删减，但必须保留 checkpoint。

## 顶部

1. Markdown：标题、章节、学生对象、教学目标。
2. Code：环境、随机种子、PyTorch device、版本信息。
3. Code：按模式选择交互函数。默认安全分发模式使用 `ask_checkpoint()` 开放式记录函数。

## 标准章节结构

每个步骤至少包含：

1. Markdown：本步目的。
2. Code：最小可运行示范。
3. Code 或 Markdown：checkpoint 问题、学生开放回答记录、可选自评。

推荐步骤：

```markdown
## Step 1 音频/特征任务背景
## Step 2 构造或读取数据
## Step 3 划分数据与 DataLoader
## Step 4 定义 PyTorch ASR 模型
## Step 5 训练循环
## Step 6 评估与解码
## Step 7 错误分析与课堂迁移
```

## PyTorch 规范

训练必须体现：

```python
model.train()
optimizer.zero_grad()
loss.backward()
optimizer.step()
```

评估必须体现：

```python
model.eval()
with torch.no_grad():
    ...
```

分类章节使用 `CrossEntropyLoss` 时，模型最后一层输出 logits，不要手动 softmax 后再传给 loss。

## 交互函数建议：安全分发模式学生端

```python
checkpoint_records = []

def ask_checkpoint(title, question, thinking_hint=None):
    print("\n【Checkpoint】" + title)
    if thinking_hint:
        print("思考提示：" + thinking_hint)
    answer = input(question + "\n请用自己的话回答：").strip()
    confidence = input("你对这个回答的把握：高 / 中 / 低：").strip()
    checkpoint_records.append({
        "title": title,
        "question": question,
        "answer": answer,
        "confidence": confidence
    })
    print("已记录。课堂上请准备用 1-2 句话口头解释你的理由。")
    return answer
```

不要在学生端 notebook 中写入 `answer_set`、标准答案或关键词判分表。教师端可另用 rubric 或 AI 对 `checkpoint_records` 做课后诊断。

## 教师端 notebook 建议

安全分发模式下，另生成教师端 notebook：

1. 读取学生端导出的 JSON；
2. 使用 rubric 或关键词辅助规则给出初步诊断；
3. 允许教师手动修正；
4. 输出学习反馈报告和补讲建议。

## AI 在线助教模式

若用户明确要求 AI 在线陪练，则无需拆成学生端/教师端文件。AI 在对话中逐步示范、提问、判断、补讲，并将问答记录写入 checkpoint log。

## 自学自动判分模式

如果用户明确要求自学训练版，可以使用自动提示/自动判分函数，但必须标注“不适合高权重考核”。此模式可以使用 `answer_set` 或关键词匹配，但不能默认启用。

## 末尾

末尾包含：

- 本节关键知识点回顾；
- 3-5 个迁移问题；
- 可选：保存模型；
- 学生答题记录表；
- 可选：导出 `checkpoint_records` 为 JSON，供教师端生成反馈报告。
