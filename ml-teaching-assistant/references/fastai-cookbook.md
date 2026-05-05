# fastai Cookbook（课程默认深度学习模板）

> 本文件是 ml-teaching-assistant 在示范深度学习任务时使用的标准代码模板。学生看 AI 跑通后被 Checkpoint 提问。
>
> fastai v2（≥ 2.7）。以下代码是**示范品**，不是让学生自己写。

## 1. 起手式

```python
from fastai.vision.all import *
from fastai.text.all import *
from fastai.tabular.all import *
from fastai.collab import *
import torch

print("torch:", torch.__version__, "cuda:", torch.cuda.is_available())
```

VPS 无 GPU，CPU 上 demo 只能用极小数据/极少 epoch。真实训练任务建议打包给学生在本地 GPU / Colab 跑（见 SKILL.md 提到的 GPU 离线协作约定）。

## 2. 图像分类（最常用示范）

```python
path = untar_data(URLs.PETS)/"images"

dls = ImageDataLoaders.from_name_re(
    path, get_image_files(path),
    pat=r'(.+)_\d+.jpg$',
    item_tfms=Resize(224),
    batch_tfms=aug_transforms(),
    valid_pct=0.2, seed=42,
)

learn = vision_learner(dls, resnet34, metrics=[accuracy, error_rate])
learn.lr_find()
learn.fine_tune(2, base_lr=1e-3)

learn.show_results()
interp = ClassificationInterpretation.from_learner(learn)
interp.plot_confusion_matrix()
interp.plot_top_losses(9)
```

**示范要点**（用作 Checkpoint 素材）：
- `valid_pct=0.2, seed=42`：自动切验证集，可复现；
- `lr_find()` → 选下降最陡段而非最低 loss 点；
- `fine_tune` = 先冻结训 head，再解冻训全部（比 `fit_one_cycle` 多了冻结/解冻步骤）；
- `plot_top_losses` = 高 loss 错例审查（误差分析的入口）。

## 3. 表格深度学习（结构化数据 + fastai）

```python
from fastai.tabular.all import *

cat_cols = ["workclass", "education", "marital-status", "occupation"]
cont_cols = ["age", "fnlwgt", "education-num", "hours-per-week"]

splits = RandomSplitter(valid_pct=0.2, seed=42)(range_of(df))

to = TabularPandas(
    df, procs=[Categorify, FillMissing, Normalize],
    cat_names=cat_cols, cont_names=cont_cols,
    y_names="target", y_block=CategoryBlock(),
    splits=splits,
)
dls = to.dataloaders(bs=64)

learn = tabular_learner(dls, layers=[200, 100], metrics=accuracy)
learn.fit_one_cycle(5, lr_max=1e-3)
```

**示范要点**：
- `procs=[Categorify, FillMissing, Normalize]`：fastai 自动把训练折的统计量记下来用于 valid，不会泄漏；
- `Normalize` 等价 sklearn `StandardScaler`，但作用域是 fastai 内部 → split-before-fit 自动满足；
- 表格深度学习不一定比 sklearn `RandomForest` 好，**学生必须先看 baseline，再决定是否上 fastai**。

## 4. 文本分类（ULMFiT，仅作课程示范用）

```python
from fastai.text.all import *

dls_lm = TextDataLoaders.from_folder(path/"train", is_lm=True, valid_pct=0.1)
learn_lm = language_model_learner(dls_lm, AWD_LSTM, drop_mult=0.5, metrics=[accuracy, Perplexity()])
learn_lm.fit_one_cycle(1, 1e-2)
learn_lm.save_encoder("ft_enc")

dls_clas = TextDataLoaders.from_folder(path, valid="test", text_vocab=dls_lm.vocab)
learn_clas = text_classifier_learner(dls_clas, AWD_LSTM, drop_mult=0.5, metrics=accuracy)
learn_clas.load_encoder("ft_enc")
learn_clas.fine_tune(2, 1e-2)
```

**示范要点**：
- 经典 ULMFiT 流程：先 LM 预训练 → 再 classifier；
- 现代任务用 transformers 通常更好——这是"特殊情况"切换的典型触发点；
- 课程目的是让学生看 fine_tune 流程，不是追求 SOTA。

## 5. 协同过滤

```python
from fastai.collab import *

dls = CollabDataLoaders.from_df(ratings, item_name='title', bs=64, valid_pct=0.2, seed=42)
learn = collab_learner(dls, n_factors=50, y_range=(0, 5.5))
learn.fit_one_cycle(5, 5e-3)
```

**示范要点**：
- `y_range` 必须设成评分上下限附近（如 0.5-5.5），否则模型预测会被 sigmoid 挤到 (0,5) 内但接触不到边界；
- `n_factors` 是 embedding 维度，过大会过拟合。

## 6. 推理与导出（对接 streamlit）

```python
learn.export("model.pkl")            # 包含 preprocessing
# streamlit 端：
from fastai.tabular.all import load_learner
learn = load_learner("model.pkl")
row, clas, probs = learn.predict(some_row)
```

**示范要点**（Checkpoint 必考点）：
- `learn.export()` **会把整个 dataloader 的预处理都序列化**，部署时用 `load_learner` 加载即可，不需要在 streamlit 里重做 Normalize/Categorify；
- 推理输入的 schema 必须与训练时一致。

## 7. 常见坑（学生容易问到）

| 坑 | 现象 | 正解 |
|---|---|---|
| `valid_pct` 没设 seed | 每次 dls 不同 | 加 `seed=42` |
| 直接 `fit` 不 `fine_tune` | 预训练权重被毁 | 用 `fine_tune` |
| 把 test 集喂进 `valid_pct` 调参 | 间接污染 | test 单独留出，调参用 valid |
| GPU 内存爆 | 大模型 + 大 batch | `bs=` 调小 / 用 `to_fp16()` |
| 自己写 transform 忘了同步到 valid | val 没归一化 | 用 `batch_tfms` / fastai 内置 |

## 8. 与 sklearn 的桥梁

学生学完 sklearn 看 fastai 第一反应"这跟 sklearn 不一样"。指出：

- `dls = ImageDataLoaders.from_*` ≈ sklearn 的 `train_test_split` + DataLoader；
- `vision_learner(...)` ≈ sklearn 的 `Pipeline([prep, clf])`，但 prep 已经融在 dls 里；
- `fit_one_cycle` ≈ sklearn 的 `clf.fit()`，但带 lr scheduler；
- `interp.plot_confusion_matrix()` ≈ `sklearn.metrics.confusion_matrix`；
- `learn.export()` ≈ `joblib.dump(pipeline, ...)` —— **都是把"模型 + 预处理"打包**，这是 Checkpoint 8 的核心点。
