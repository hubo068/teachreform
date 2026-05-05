# Final Learning Report（学生学习反馈报告 — 模板）

> **关键文件**：本文件是 ml-teaching-assistant **三件套**交付物之一。Step 10 必须严格按此结构产出。
>
> **数据源**：
> - **学习诊断**（§2-§5、§7 的"已掌握/未掌握"判定）→ `templates/checkpoint-log.md` 的原始问答，**禁止凭印象总结**，每个判定必须能在 log 里找到对应原问答。
> - **任务摘要 + 代码产出**（§1）→ `templates/model-card.md` 和实际产物文件（notebook、model.joblib、app.py 等）。
> - **复习建议**（§4、§6）→ **优先指向同任务产出的个性化教程对应章节**（链接到 `<student>-personalized-tutorial.md` 的 §1.x / §2.x 等）；通用兜底再补 sklearn / fastai / gensim 官方文档章节。
>
> **配套交付**（三件套另两件，路径必须在 §8 附件清单列出）：
> - `<task>.ipynb`：完整可重跑示范 notebook（按 `templates/notebook-outline.md` 组织）
> - `<student>-personalized-tutorial.md`：针对本学生未掌握知识点的个性化教程（按 `templates/personalized-tutorial.md` 组织）
>
> **长度上限**：≤ 2 页（约 1500 字）。学生看不进更长的。

---

# 学习反馈报告

**学生**：（姓名 / 学号）
**任务**：（数据集 + 任务模式简述）
**完成时间**：（开始 → 结束）
**助教**：ml-teaching-assistant（AI 示范）

---

## 1. 任务摘要

| 项 | 内容 |
|---|---|
| 数据集 | （文件名 + 行列规模） |
| 任务模式 | 分类 / 回归 / 聚类 / LDA / 时间序列 / 部署 |
| 框架 | sklearn / gensim / fastai / streamlit |
| Baseline 指标 | 例：DummyClassifier accuracy=0.92, LogReg F1=0.71 |
| 最终模型指标 | 例：RandomForest F1=0.83, PR-AUC=0.79 |
| 部署产出 | 例：app.py + model.joblib，本地可跑 |
| 代码产出清单 | 列文件名 + 一句话说明 |

---

## 2. Checkpoint 通过情况总览

| 档位 | 数量 | 占比 |
|---|---|---|
| 已掌握 | X | XX% |
| 部分掌握 | X | XX% |
| 未掌握 | X | XX% |
| 需教师介入 | X | XX% |
| **合计** | N | 100% |

**整体评估**（中性表述，不贴"差/好"标签）：
- 例："基础流程纪律已掌握（split-before-fit、stratified、baseline 先行）。"
- 例："深度学习相关知识点（lr_find、fine_tune）出现明显断层。"

---

## 3. 已掌握知识点（带原问答证据）

按步骤排列。每条必须引用至少一个 Checkpoint。

### Step 2 数据审计
- ✅ **Group 泄漏识别**（CP-02）：能正确解释"同一学号出现多行直接 split 会导致 train/test 重叠"。
  > 学生原话引用：「……」

### Step 5 切分 + 评估
- ✅ **split-before-fit**（CP-05）：
  > 学生原话引用：「因为如果先 fit 全量，测试集均值方差就被知道了……」

…（以此类推）

---

## 4. 未掌握知识点（带原问答证据 + 复习建议）

### 知识点 X：fastai `lr_find` 取点策略
- **来源**：CP-08（Step 6）
- **学生回答**：「不知道 / 选了最低 loss 那个 / ……」
- **正确理解**：lr_find 应选 loss 下降最陡的区段，而不是 loss 最低点（最低点已经接近发散，不稳定）。
- **个性化教程对应章节**：见 `<student>-personalized-tutorial.md` §3（进阶卡点）——已为你回顾当时卡点 + 重新讲解 + 配套练习。
- **官方资料兜底**：fastai book 第 5 章 "Image Classification" 关于 learning rate 的小节。

### 知识点 Y：…
…

---

## 5. 步骤-知识点关联图

让学生看见"抽象概念 ↔ 具体代码行 ↔ 我的表现"的对应。

| Step | AI 示范的关键代码（片段） | 涉及知识点 | 学生表现 |
|---|---|---|---|
| Step 2 | `df.groupby('student_id').size().describe()` | Group 结构识别 | ✅ 已掌握（CP-02） |
| Step 3 | 排除 `final_default_flag` 字段 | Target leakage | ✅ 已掌握（CP-04） |
| Step 5 | `Pipeline([("scale", StandardScaler()), ("clf", LogReg())])` | split-before-fit | ✅ 已掌握（CP-05） |
| Step 5 | `StratifiedKFold(n_splits=5)` | Stratified 切分理由 | ⚠️ 部分掌握（CP-06） |
| Step 6 | `learn.lr_find()` → 选 1e-3 | lr_find 取点策略 | ❌ 未掌握（CP-08） |
| Step 6 | `learn.fine_tune(2)` | fine_tune vs fit_one_cycle | ✅ 已掌握（补讲后，CP-09） |
| Step 7 | `interp.plot_confusion_matrix()` | 混淆矩阵中 FN/FP 与代价 | ⚠️ 部分掌握（CP-12） |
| Step 8 | `joblib.dump(pipeline, ...)` | 训练-部署一致性 | ✅ 已掌握（CP-15） |

---

## 6. 推荐下一步（基于未掌握清单的 2-3 条）

按优先级排：

1. **优先**：打开 `<student>-personalized-tutorial.md` 顺读 §1-§2（基础卡点）；读完做完每节末尾的练习题；
2. **中等**：跟着配套 `<task>.ipynb` 重跑一遍未掌握的 Step（例如 Step 5 Cell B），对照 Checkpoint 区块再答一次提问；
3. **可选**：换一个相似数据集，独立跑 Step 0 → Step 6 全流程；自己提问自己"我刚才为什么这么做"，对照本次 notebook 检查覆盖度。

---

## 7. 教师可见部分（供任课教师参考）

> 本节单独划出，**不作为给学生的"评分"**。是给老师看本班 / 本学生的画像，决定下一节课要不要补讲。

- **学生画像**：
  - 流程纪律：（强 / 中 / 待加强）
  - 数学/概率直觉：（如对 calibration、概率解读的反应）
  - 工程意识：（如对部署一致性、版本管理的反应）
  - 提问反应度：（学生在补讲后是否能转过来）
- **建议课上补讲**：
  - 例：本班至少 3 名学生在 lr_find 取点策略上出错 → 建议下次课用 5 分钟统一讲一次；
  - 例：本班对 `cache_resource` vs `cache_data` 普遍混淆 → 写一个对比 demo。
- **本次示范的代码产出**：
  - `notebook.ipynb` / `train.py` / `app.py` / `model.joblib` / 路径

---

## 8. 附件清单（三件套 + 产物）

| 类型 | 文件名 | 路径 | 用途 |
|---|---|---|---|
| 反馈报告（本文件） | `final-learning-report.md` | `~/Downloads/ml-teaching-<task>-<date>/` | 学习诊断 + 教师可见画像 |
| 完整可重跑 Notebook | `<task>.ipynb` | 同上 | 示范品 + 学生回看 |
| 个性化教程 | `<student>-personalized-tutorial.md` | 同上 | 针对你未掌握知识点的补课材料 |
| 模型文件 | `model.joblib` / `model.pkl` / `lda.model` | 同上 | 部署 / 复现用 |
| streamlit demo（如有） | `app.py` | 同上 | 部署演示 |

---

## 报告生成纪律（给 AI）

- ❌ 禁止凭印象总结：每条判定必须能在 `checkpoint-log.md` 里找到对应条目；
- ❌ 禁止贴情绪标签（"很好 / 很差 / 太糟"）→ 用四档中性词："已掌握 / 部分掌握 / 未掌握 / 需教师介入"；
- ❌ 禁止给数字打分（90/100 之类）——那是老师的事，不是 AI 的事；
- ✅ 学生原话引用必须保留——是诊断的证据；
- ✅ 复习建议必须**具体到资料 / 章节 / 练习**，不要写"建议加强练习"这种空话；
- ✅ §7 教师可见部分独立成节，不要混在前面给学生看的部分。
