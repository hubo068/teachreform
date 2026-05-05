# Notebook Outline（完整可重跑 Jupyter Notebook 模板）

> **三件套之一**。Step 10 强制交付物。文件名格式：`<task-name>.ipynb`。

## 总要求

1. **完全可重跑**：从首个 cell 到末尾顺序运行，必须不报错。不依赖任何"我刚才在 REPL 跑过的中间状态"。
2. **按 Step 0-9 组织**：流程顺序与 SKILL.md §执行流程完全对应。
3. **既是示范品，也是教学记录**：把当次 Checkpoint 的师生问答嵌进对应 Step 末尾，让学生回看 notebook 时能看到"AI 当时为什么停下问我那个问题"。
4. **遵循流程纪律**：split-before-fit、Pipeline 内做预处理、baseline 先行、test 只跑一次。Notebook 是示范品，规范不能打折。

## Cell 组织规范

### 顶部三 cell（固定）

**Cell 0 — Markdown：标题与元信息**
```markdown
# <数据集名> + <任务模式> ML 课堂示范

- **学生**：<姓名 / 学号>
- **数据集**：<文件名 + 行列规模 + 来源>
- **任务模式**：分类 / 回归 / 聚类 / LDA / 时间序列 / 部署
- **课程默认技术栈**：sklearn / gensim / fastai / streamlit
- **完成日期**：YYYY-MM-DD
- **配套交付**：
  - 反馈报告：`final-learning-report.md`
  - 个性化教程：`<student>-personalized-tutorial.md`
```

**Cell 1 — Code：环境 + 复现要素**
```python
import sys, platform, random
import numpy as np, pandas as pd
import sklearn, fastai, gensim  # 按实际任务 import

SEED = 42
random.seed(SEED); np.random.seed(SEED)

print("python :", sys.version.split()[0])
print("sklearn:", sklearn.__version__)
print("fastai :", fastai.__version__)  # 如适用
print("gensim :", gensim.__version__)  # 如适用

DATA_PATH = "data/<file>.csv"
SNAPSHOT_DATE = "YYYY-MM-DD"  # 数据快照
```

**Cell 2 — Markdown：本次任务上下文卡（Context Card 摘要）**
> 摘自 `context-card.md` 关键字段；让单独打开 notebook 的读者无需翻其他文件就懂背景。

---

### Step 0-9 的标准三 cell 模式

每个 Step 至少 3 个 cell：

#### Cell A — Markdown：Step 章节标题 + 本步目的
```markdown
## Step N — <步骤名>

**本步目的**：（1-2 句）

**AI 在做什么**：（一句话总结将跑哪些代码、产出什么结果）
```

#### Cell B — Code：示范代码（最小可跑片段）
- 严格遵循对应 cookbook（sklearn-cookbook / fastai-cookbook / gensim-lda-cookbook / streamlit-cookbook）；
- 一个 Step 内允许多个 code cell，但每个 cell 围绕同一子任务，不要把 5 个无关操作堆一个 cell；
- 注释说明"为什么这样写"，不只是"这是什么"。

#### Cell C — Markdown：本步 Checkpoint 嵌入

**这是 notebook 区别于普通示范代码的关键。每个 Step 末尾必须有：**

```markdown
### 📌 Checkpoint N — <知识点名>

**AI 提问**：> （摘自 checkpoint-log.md 的原话提问，问号结尾）

**学生回答**：> （摘自 checkpoint-log.md 的学生原话）

**判定**：✅ 已掌握 / ⚠️ 部分掌握（补讲后通过）/ ❌ 未掌握 / 🆘 需教师介入

**AI 反馈**：（一句话点评 / 补讲要点）

**关联代码行**：本 Step Cell B 第 N 行 `<code snippet>`
```

> 学生回看 notebook 时，能看到自己当时被问了什么、自己答了什么、AI 怎么判定 + 反馈了什么。这是个性化教程的素材源。

---

### 末尾三 cell（固定）

**Cell N-2 — Markdown：最终模型小结**
> 列最强模型 vs baseline 指标对比、模型适用边界。

**Cell N-1 — Code：模型导出（对接 streamlit）**

按任务类型选一种：

```python
# sklearn
import joblib
joblib.dump(pipe, "model.joblib")

# fastai
learn.export("model.pkl")

# gensim LDA
lda.save("lda.model"); dictionary.save("lda.dict")
```

**Cell N — Markdown：交付物清单**
```markdown
## 本次任务交付清单

- 本 notebook：`<task>.ipynb`
- 模型文件：`model.joblib` / `model.pkl` / `lda.model`
- 反馈报告：`final-learning-report.md`
- 个性化教程：`<student>-personalized-tutorial.md`
- streamlit demo（如有）：`app.py`

**重跑命令**：
```bash
jupyter notebook <task>.ipynb
```
```

---

## 命名约定

- Notebook 文件名：`<task-name>.ipynb`，例如 `student-default-prediction.ipynb`
- 输出目录：`~/Downloads/ml-teaching-<task>-<date>/`，与三件套其他文件同目录
- 模型文件：`model.joblib` / `model.pkl` / `lda.model` 等（与 streamlit cookbook 默认名一致）

## 生成纪律

- ❌ **不要 cell 长度爆炸**：单个 code cell 不超过 ~40 行，长就拆；
- ❌ **不要 print 整个 DataFrame**：`df.head()` / `df.shape` / `df.dtypes` 即可；
- ❌ **不要把 AI 内部 reasoning 写进 markdown cell**（"我决定用 X 因为……"）——markdown 是给学生看的教学说明，不是 AI 的思考过程；
- ✅ **每个图必须有标题 + 轴标签**（`plt.title` / `plt.xlabel` / `plt.ylabel`）；
- ✅ **若 fastai 训练慢**（VPS 无 GPU），在该 cell 上方加一句 markdown："本 cell 在 CPU 上约 5-10 分钟，如需加速请在 GPU 环境重跑"；
- ✅ **错例展示要脱敏**：高置信错例如包含个人识别信息，必须先脱敏。

## 与个性化教程的衔接

Notebook 中每个 Checkpoint 的"判定"字段决定个性化教程的章节构成：
- `✅ 已掌握` → 个性化教程不写（除非用户全员通过，则统一写"进阶挑战"）；
- `⚠️ 部分掌握 / ❌ 未掌握 / 🆘 需教师介入` → 个性化教程必有对应章节。

每个个性化教程章节必须**反向引用** notebook 的具体 Step 与 Cell 位置（"还记得你在 `<task>.ipynb` Step 5 的 Cell B 里看到的 `Pipeline([...])` 吗？"）。
