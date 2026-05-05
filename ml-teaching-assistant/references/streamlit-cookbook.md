# Streamlit Cookbook（课程默认部署模板）

> ml-teaching-assistant 在示范部署任务时使用的标准 streamlit 模板。streamlit ≥ 1.28（`st.cache_resource` / `st.cache_data` 已分家）。
>
> 本文件配合 `templates/streamlit-app-outline.md` 使用——cookbook 提供片段，template 提供整体骨架。

## 1. 最小可跑骨架（sklearn 模型）

```python
import streamlit as st
import joblib
import pandas as pd

st.set_page_config(page_title="ML Demo", page_icon="🧪", layout="centered")
st.title("机器学习模型演示")
st.caption("课程示范：本 demo 不用于真实决策。")

@st.cache_resource
def load_model():
    return joblib.load("model.joblib")

model = load_model()

with st.form("predict"):
    age = st.number_input("年龄", min_value=0, max_value=120, value=30)
    income = st.number_input("月收入", min_value=0, value=5000)
    city = st.selectbox("城市", ["北京", "上海", "广州", "其他"])
    submitted = st.form_submit_button("预测")

if submitted:
    X = pd.DataFrame([{"age": age, "income": income, "city": city}])
    pred = model.predict(X)[0]
    proba = model.predict_proba(X)[0]
    st.metric("预测类别", str(pred))
    st.write("各类别概率：", dict(zip(model.classes_, proba.round(3))))
```

**示范要点**：
- `@st.cache_resource` 装饰模型加载（不是 `@st.cache_data`）；
- 整个 sklearn Pipeline 一起 `joblib.load`，包含预处理；
- 输入 DataFrame 的列名/顺序与训练时一致——**这是部署最常炸的地方**。

## 2. fastai 模型加载

```python
@st.cache_resource
def load_learner_cached():
    from fastai.tabular.all import load_learner
    return load_learner("model.pkl")

learn = load_learner_cached()

if submitted:
    row = pd.DataFrame([{"age": age, "income": income, "city": city}])
    _, pred_class, probs = learn.predict(row.iloc[0])
    st.metric("预测类别", str(pred_class.item()))
    st.write("概率：", probs.tolist())
```

**示范要点**：
- fastai `learn.export()` → `load_learner()` 已经把 `Categorify / FillMissing / Normalize` 一起序列化；
- 不需要在 streamlit 里重新跑预处理。

## 3. gensim LDA 模型加载（主题查询）

```python
@st.cache_resource
def load_lda():
    from gensim.models import LdaModel
    from gensim.corpora import Dictionary
    return LdaModel.load("lda.model"), Dictionary.load("lda.dict")

lda, dictionary = load_lda()

text = st.text_area("输入一段文本")
if st.button("分析主题"):
    from cookbook_preprocess import zh_preprocess  # 复用训练时的预处理函数
    tokens = zh_preprocess(text)
    bow = dictionary.doc2bow(tokens)
    topic_dist = lda.get_document_topics(bow, minimum_probability=0.0)
    st.bar_chart({"prob": dict(topic_dist)})
    for tid, prob in sorted(topic_dist, key=lambda x: -x[1])[:3]:
        st.write(f"Topic {tid}: {lda.show_topic(tid, topn=8)}")
```

## 4. CSV 上传 + 缺失字段防御

```python
REQUIRED_COLS = ["age", "income", "city"]

uploaded = st.file_uploader("上传 CSV", type=["csv"])
if uploaded:
    df = pd.read_csv(uploaded)
    missing = [c for c in REQUIRED_COLS if c not in df.columns]
    if missing:
        st.error(f"缺少字段：{missing}。请补全后重试。")
        st.stop()
    preds = model.predict(df[REQUIRED_COLS])
    df["pred"] = preds
    st.dataframe(df.head(20))
    st.download_button("下载预测结果", df.to_csv(index=False).encode("utf-8"), "preds.csv")
```

**示范要点**（Checkpoint 必考）：
- 用户上传的 CSV 缺列直接 `model.predict` 会抛 KeyError → 必须先校验；
- `st.stop()` 防止后续代码继续执行；
- 给用户友好错误提示，不是栈追溯。

## 5. 缓存策略

| 装饰器 | 用途 | 例子 |
|---|---|---|
| `@st.cache_resource` | 不可序列化的全局资源 | 模型、数据库连接、tokenizer |
| `@st.cache_data` | 可序列化的数据 | DataFrame、计算结果、API 响应 |

不要用错——用错最常见症状是"模型每次刷新都重新加载"。

## 6. 适用边界声明（非选）

```python
with st.expander("⚠️ 本 demo 的适用边界"):
    st.markdown("""
- 本模型仅在 **2023 年某市某高校** 数据上训练；
- 对其他地区/年级 **不保证可用**；
- 模型准确率 ~85%，但子群体（如某些专业）误差更大；
- **不得** 用于真实招生 / 评奖学金 / 心理评估等决策。
""")
```

**示范要点**：
- 部署 ≠ 上线；任何课程 demo 都要写边界声明；
- 这是伦理与责任的最低线，也是 Checkpoint 8 的固定考点。

## 7. 本地运行 + 部署

```bash
# 本地
streamlit run app.py

# Streamlit Community Cloud（免费部署）：
# 1. 把 app.py + model.joblib + requirements.txt 推到 GitHub
# 2. 到 share.streamlit.io 关联 repo
# 3. 注意：模型文件 < 100MB；超过的话用 git lfs 或外部存储
```

requirements.txt 至少含：

```
streamlit>=1.28
scikit-learn>=1.3
pandas
numpy
joblib
# 按需添加 fastai / gensim / torch
```

## 8. 常见坑

| 坑 | 现象 | 正解 |
|---|---|---|
| 用 `st.cache_data` 缓存模型 | 模型反复反序列化、慢 | 改 `st.cache_resource` |
| 部署时 sklearn 版本不一致 | `pickle.UnpicklingError` | requirements.txt 锁版本 |
| 训练时用了未保存的预处理函数 | 部署找不到 | 把整个 Pipeline dump，或函数移到独立模块 |
| 用户输入超出训练时的取值范围 | 预测奇怪但不报错 | 输入控件限定 `min_value` / `max_value` / `selectbox` |
| 没写适用边界 | 用户当真 | 必加 expander 声明 |
