# Tech Stack（课程默认技术栈）

> 本文件是 ml-teaching-assistant 的硬约束。SKILL.md §技术栈硬约束是决策表，本文件是具体 import / 版本 / 模板。

## 默认栈

| 任务 | 框架 | 典型 import |
|---|---|---|
| 数据处理 | pandas, numpy | `import pandas as pd`, `import numpy as np` |
| 经典 ML（分类/回归/聚类/降维） | scikit-learn | `from sklearn.pipeline import Pipeline`, `from sklearn.model_selection import train_test_split, StratifiedKFold, GroupKFold, TimeSeriesSplit` |
| 主题建模 / 词向量 | gensim | `from gensim.models import LdaModel, Word2Vec`, `from gensim.corpora import Dictionary` |
| 深度学习（图像/文本/表格/协同过滤） | fastai v2 | `from fastai.vision.all import *`, `from fastai.text.all import *`, `from fastai.tabular.all import *`, `from fastai.collab import *` |
| 应用部署 / 演示 | streamlit | `import streamlit as st` |
| 可视化 | matplotlib, seaborn | `import matplotlib.pyplot as plt`, `import seaborn as sns` |

## 版本偏好

- Python 3.10+；
- scikit-learn ≥ 1.3（Pipeline、ColumnTransformer、set_config 显示 pipeline 图）；
- fastai ≥ 2.7（DataBlock API 稳定）；
- gensim ≥ 4.x（API 与 3.x 不同）；
- streamlit ≥ 1.28（`st.cache_resource` / `st.cache_data` 已分家）。

如果本机没有对应版本，先装再开始；不要用老版本写新 API，也不要用新 API 写老版本能跑的代码。

## "特殊情况"切换条件

只有满足以下条件之一，才允许切换到非默认框架。**每次切换都是一个 Checkpoint**：告诉学生切换原因 + 新风险。

| 场景 | 切换目标 | 触发条件 |
|---|---|---|
| sklearn 跑不动（样本量大 / GBDT 优势明显） | LightGBM / XGBoost / CatBoost | 样本 > 100 万行；或特征间交互复杂且 sklearn GradientBoosting 明显不足 |
| fastai 太黑盒 / 需要自定义训练循环 | 原生 PyTorch | 需要自定义 loss、自定义 sampler、或模型结构 fastai 不支持 |
| streamlit 不满足部署需求 | FastAPI | 需要 JSON REST API 对接生产后端，且课程已讲过 API |
| 文本任务 fastai ULMFiT 效果差 | HuggingFace transformers（可配合 fastai wrapper 或独立） | 明显是预训练模型时代才有效的任务（如小样本 fine-tune SOTA 分类） |
| 主题建模需要神经主题模型 | BERTopic | 仅当课程进度已经讲过 BERT 类模型 |

## 禁止事项

- ❌ **不要** 在同一项目里 sklearn + TensorFlow 混用 —— 学生会被两套 API 淹没；
- ❌ **不要** 用 Keras（课程栈是 fastai/PyTorch，混用反而拖慢学习）；
- ❌ **不要** 用 Gradio / Flask 替换 streamlit 只因为"我更熟" —— 课程统一用 streamlit 让学生能互相看代码；
- ❌ **不要** 在 sklearn Pipeline 没走通之前就跳去 fastai —— Pipeline 是课程基础，跳过等于挖坑；
- ❌ **不要** 随意 `pip install` 冷僻库；确需第三方库时告诉学生为什么默认栈不够。

## 本地环境

本 Skill 运行在 VPS 上（Linux，无 GPU）。

- 经典 ML / gensim：VPS CPU 即可；
- fastai 深度学习：
  - 小数据 demo 可在 CPU 上跑通流程（只求跑通，不求 SOTA）；
  - 真实训练任务建议学生在自己 M 系列 Mac / Colab / 学校 GPU 上跑；
  - 见 CLAUDE.md §GPU 任务离线协作 —— 打包脚本给学生带回去跑；
- streamlit：本地开发 + 可选 Streamlit Community Cloud 部署。

## 常见 import 模板

```python
# 经典 ML 起手式
import numpy as np
import pandas as pd
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.model_selection import train_test_split, StratifiedKFold, cross_val_score
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score

# fastai 图像
from fastai.vision.all import *
path = untar_data(URLs.PETS)
dls = ImageDataLoaders.from_name_re(path, get_image_files(path/"images"),
                                    pat=r'(.+)_\d+.jpg$', item_tfms=Resize(224))
learn = vision_learner(dls, resnet34, metrics=accuracy)
learn.fine_tune(2)

# fastai 表格
from fastai.tabular.all import *
dls = TabularDataLoaders.from_df(df, y_names="target",
    cat_names=cat_cols, cont_names=cont_cols,
    procs=[Categorify, FillMissing, Normalize])
learn = tabular_learner(dls, metrics=accuracy)
learn.fit_one_cycle(5)

# gensim LDA
from gensim.corpora import Dictionary
from gensim.models import LdaModel
dictionary = Dictionary(texts)
corpus = [dictionary.doc2bow(t) for t in texts]
lda = LdaModel(corpus, num_topics=5, id2word=dictionary, passes=10, random_state=42)

# streamlit
import streamlit as st
import joblib
@st.cache_resource
def load_model():
    return joblib.load("model.joblib")
```
