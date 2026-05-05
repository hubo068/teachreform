# TeachReform — AI 赋能教学辅助系统

本项目是一套面向高校人工智能与机器学习课程的**交互式教学辅助工具集**，核心目标是将大模型从"代码生成器"转化为"教学流程生成器"，通过"AI 示范一步、暂停提问、诊断反馈"的闭环机制，解决学生在 AI 编程普及背景下"会运行代码、不会解释原理"的问题。

---

## 项目概览

| 模块 | 定位 | 适用场景 |
|---|---|---|
| `ml-teaching-assistant/` | 机器学习课堂示范助教 | 经典 ML、深度学习、主题建模、部署演示 |
| `asr-teaching-assistant/` | 语音识别课程交互式示范助教 | DNN 声学模型、MFCC/FBank、CTC、PyTorch 训练 |
| `asr-emotion-dnn-video/` | ASR/DNN 教学视频（HyperFrames） | 课堂视频演示、动画讲解 |
| `scripts/` | 辅助脚本 | 教学案例文档自动生成 |

---

## 核心教学理念

> **AI 是讲台上现场示范的数据科学家；学生坐在下面看，AI 每做完一步停下来问学生：「刚才这一步我为什么这么做？」**

学生不负责写代码，而是：
1. **看懂** AI 示范的每一步规范代码；
2. **回答** Checkpoint 提问，把步骤和知识点挂钩；
3. **被诊断**——任务结束拿到一份反馈报告，知道自己哪些知识点掌握了、哪些没有。

---

## 安装与环境要求

### 1. 克隆仓库

```bash
git clone https://github.com/hubo068/teachreform.git
cd teachreform
```

### 2. Python 环境（Notebook 教学模块）

```bash
# 创建虚拟环境
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate

# 安装基础依赖
pip install jupyter numpy pandas matplotlib scikit-learn torch torchaudio
```

### 3. 各模块额外依赖

#### ml-teaching-assistant

```bash
pip install fastai gensim streamlit seaborn joblib
```

版本要求：
- Python >= 3.10
- scikit-learn >= 1.3
- fastai >= 2.7
- gensim >= 4.x
- streamlit >= 1.28

#### asr-teaching-assistant

```bash
pip install jupyter numpy pandas matplotlib scikit-learn torch
```

#### asr-emotion-dnn-video（HyperFrames 视频渲染）

```bash
cd asr-emotion-dnn-video
npm install
```

需要 Node.js 18+。

#### scripts（教学案例文档生成）

```bash
pip install python-docx
```

---

## 使用说明

### ml-teaching-assistant（机器学习课堂助教）

本模块采用**标准数据科学流程**，每完成一步即设置 Checkpoint 考察学生理解：

**教学流程（Step 0~10）：**

```
Step 0: 任务模式判定（分类/回归/聚类/LDA/时间序列/部署）
Step 1: Context Card（问题定义与约束）
Step 2: Data Audit（数据审计）
Step 3: 机制假设 + 特征决策 + 风险特征
Step 4: Baseline（Dummy/线性模型先行）
Step 5: 切分 + 评估协议（split-before-fit 高压线）
Step 6: 迭代更强模型（sklearn/fastai/gensim）
Step 7: 误差分析（混淆矩阵/残差/子群体）
Step 8: Streamlit 部署（可选）
Step 9: 反思
Step 10: 三件套交付（强制）
```

**三件套交付物：**
- **(A) 学生学习反馈报告**：Checkpoint 统计、已掌握/未掌握知识点、步骤-知识点关联图
- **(B) 完整可重跑 Jupyter Notebook**：按 Step 组织，嵌入 Checkpoint 记录
- **(C) 个性化教程**：针对本学生薄弱知识点的专属补课材料

**教师/AI 使用方式：**

1. 读取 `ml-teaching-assistant/SKILL.md` 了解完整教学协议
2. 按 `templates/notebook-outline.md` 组织 notebook 结构
3. 按 `references/teaching-checkpoints.md` 准备每步提问
4. 任务结束按 `templates/final-learning-report.md` 生成反馈报告

---

### asr-teaching-assistant（语音识别课堂助教）

本模块是 `ml-teaching-assistant` 的语音识别课程子 skill，聚焦 PyTorch + ASR 知识点。

**支持三种运行模式：**

| 模式 | 说明 | 适用场景 |
|---|---|---|
| **安全分发模式（默认）** | 学生端只答题和导出记录；教师端读取记录生成反馈 | 正式课堂、大班作业、过程性评价 |
| **AI 在线助教模式** | AI 在对话中即时示范、提问、判断、补讲 | 小班、课堂投屏、教师监督陪练 |
| **自学自动判分模式** | Notebook 可自动判分和提示 | 低风险自学练习（不适合正式考核） |

**双端文件示例（安全分发模式）：**

| 文件 | 用途 |
|---|---|
| `ASR_DNN_student.ipynb` | 学生端：运行实验、回答 Checkpoint、导出 JSON 记录 |
| `ASR_DNN_teacher_rubric.ipynb` | 教师端：读取 JSON、按 rubric 诊断、生成反馈报告 |
| `ASR_DNN_checkpoint_records.json` | 学生答题记录（中间数据） |
| `ASR_DNN_teacher_feedback_report.md` | 生成的学生学习反馈报告 |

**使用流程：**

```bash
# 1. 学生端
jupyter notebook ASR_DNN_student.ipynb
# 学生运行所有 cell，回答 Checkpoint 问题，最后导出 JSON

# 2. 教师端
# 将学生导出的 JSON 与 ASR_DNN_teacher_rubric.ipynb 放在同一目录
jupyter notebook ASR_DNN_teacher_rubric.ipynb
# 运行后自动生成 ASR_DNN_teacher_feedback_report.md
```

**Rubric 诊断档位：**

| 档位 | 判定依据 |
|---|---|
| 已掌握 | 能说明核心原因，术语基本准确，能联系代码或结果 |
| 部分掌握 | 方向正确，但缺少关键机制或表达不完整 |
| 需补讲 | 回答暴露明显误解，需课堂即时补充讲解 |
| 需教师介入 | 多次无法解释，或暴露前置知识断点 |

---

### asr-emotion-dnn-video（教学视频制作）

使用 [HyperFrames](https://hyperframes.heygen.com/) 框架以编程方式创建教学视频。

```bash
cd asr-emotion-dnn-video

# 预览编辑
npm run dev

# 检查校验
npm run check

# 渲染为 MP4
npm run render

# 发布并获取分享链接
npm run publish
```

项目结构：
- `index.html` — 主合成（根时间线）
- `compositions/` — 子合成
- `meta.json` — 项目元数据
- `assets/narration.wav` — 旁白音频

---

### scripts（辅助脚本）

`fill_ai_teaching_case_template.py` — 自动生成广东民办高校 AI 赋能优秀教学案例 Word 文档。

```bash
cd scripts
python fill_ai_teaching_case_template.py
# 输出：基于大模型Skills的交互式Notebook语音识别课程教学案例.docx
```

---

## 技术栈总览

| 任务类型 | 默认框架 | 说明 |
|---|---|---|
| 经典 ML | scikit-learn | 分类/回归/聚类/降维 |
| 主题建模 | gensim | LDA、Word2Vec、Doc2Vec |
| 深度学习 | fastai (PyTorch) | 图像/文本/表格/协同过滤 |
| 语音识别 | PyTorch + torchaudio | DNN/CNN/RNN/CTC 声学模型 |
| 部署演示 | streamlit | 最小应用部署 |
| 视频制作 | HyperFrames | HTML 合成视频渲染 |
| 文档生成 | python-docx | Word 案例模板填充 |

---

## 项目结构

```
teachreform/
├── README.md                               # 本文件
│
├── ml-teaching-assistant/                  # 机器学习课堂助教
│   ├── SKILL.md                            # 核心教学协议
│   ├── references/                         # 参考手册
│   │   ├── tech-stack.md                   # 技术栈硬约束
│   │   ├── teaching-checkpoints.md         # 知识点清单与提问范例
│   │   ├── sklearn-cookbook.md             # sklearn 标准模板
│   │   ├── fastai-cookbook.md              # fastai 标准模板
│   │   ├── gensim-lda-cookbook.md          # gensim LDA 模板
│   │   ├── streamlit-cookbook.md           # streamlit 部署模板
│   │   ├── analysis-guardrails.md          # 分析硬约束
│   │   └── time-series-guardrails.md       # 时间序列护栏
│   └── templates/                          # 交付物模板
│       ├── final-learning-report.md        # 学习反馈报告模板
│       ├── notebook-outline.md             # Notebook 结构规范
│       ├── personalized-tutorial.md        # 个性化教程模板
│       ├── checkpoint-log.md               # Checkpoint 记录模板
│       ├── context-card.md                 # 问题定义模板
│       ├── data-audit.md                   # 数据审计模板
│       ├── model-card.md                   # 模型记录模板
│       └── streamlit-app-outline.md        # 部署骨架模板
│
├── asr-teaching-assistant/                 # 语音识别课堂助教
│   ├── SKILL.md                            # ASR 教学协议
│   ├── references/                         # ASR 参考手册
│   │   ├── asr-tech-stack.md               # ASR 技术栈
│   │   └── asr-teaching-checkpoints.md     # ASR 知识点题库
│   └── templates/                          # ASR 交付物模板
│       ├── asr-notebook-outline.md         # ASR Notebook 结构
│       └── asr-final-learning-report.md    # ASR 反馈报告模板
│
├── asr-emotion-dnn-video/                  # 教学视频项目
│   ├── index.html                          # 主合成
│   ├── package.json                        # 脚本配置
│   ├── hyperframes.json                    # 框架配置
│   ├── narration.txt                       # 旁白文本
│   └── assets/                             # 音视频资产
│
├── scripts/                                # 辅助脚本
│   └── fill_ai_teaching_case_template.py   # 案例文档生成
│
├── rendered_case/                          # 渲染后的案例图片
│
└── [示例文件]                              # ASR DNN 双端演示
    ├── ASR_DNN_student.ipynb               # 学生端
    ├── ASR_DNN_teacher_rubric.ipynb        # 教师端
    ├── ASR_DNN_checkpoint_records.json     # 答题记录示例
    ├── ASR_DNN_teacher_feedback_report.md  # 反馈报告示例
    └── ASR_DNN_final_learning_report.md    # 使用说明
```

---

## 教学效果

本系统已在广东民办高校人工智能、智能科学、软件工程等专业课程中应用，核心效果：

- **降低答案泄露风险**：学生端/教师端分离，学生端不暴露标准答案或判分规则
- **过程性评价闭环**：从课堂互动 → 个体诊断 → 个性化补学全覆盖
- **标准工程纪律内化**：split-before-fit、baseline 先行、指标贴代价等规范通过示范自然传递
- **AI 协同学习能力**：引导学生从"运行 AI 代码"转向"解释模型原理"

---

## 致谢

感谢 **王树义老师** 的视频启发，其关于 AI 赋能教学与智能体辅助课堂的分享为本项目的设计思路提供了重要参考。

---

## 贡献与许可

本项目为教学研究用途，欢迎高校教师和技术助教参考使用。

如有问题或改进建议，请通过 GitHub Issues 反馈。
