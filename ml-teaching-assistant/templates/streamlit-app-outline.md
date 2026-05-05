# Streamlit App Outline（部署最小骨架）

> Step 8 部署示范的完整 `app.py` 骨架。具体片段见 `references/streamlit-cookbook.md`。本骨架包含一个 demo 必备的所有"必有项"。

```python
"""
课程示范 streamlit app
- 模型：见 model.joblib（sklearn pipeline）
- 训练脚本：见 train.py
- 适用边界：见底部 expander
"""

import streamlit as st
import joblib
import pandas as pd

# ---- 1. 页面元信息（必有） ----
st.set_page_config(page_title="ML 课程示范", page_icon="🧪", layout="centered")
st.title("机器学习模型演示")
st.caption("课程示范用，**不用于真实决策**。")

# ---- 2. 模型加载（必有，cache_resource） ----
@st.cache_resource
def load_model():
    return joblib.load("model.joblib")

model = load_model()

# ---- 3. 输入控件（必有） ----
st.subheader("输入特征")
with st.form("predict"):
    # 数值字段加 min/max 限制，防止离群输入
    age = st.number_input("年龄", min_value=0, max_value=120, value=30)
    income = st.number_input("月收入", min_value=0, value=5000)
    # 类别字段用 selectbox，防止用户拼错
    city = st.selectbox("城市", ["北京", "上海", "广州", "其他"])
    submitted = st.form_submit_button("预测")

# ---- 4. 推理 + 输出（必有） ----
if submitted:
    X = pd.DataFrame([{"age": age, "income": income, "city": city}])
    pred = model.predict(X)[0]
    proba = model.predict_proba(X)[0]
    st.metric("预测类别", str(pred))
    st.write("各类别概率：", dict(zip(model.classes_, proba.round(3))))

# ---- 5. （可选）批量 CSV 上传 + 缺失字段防御 ----
st.subheader("批量预测（上传 CSV）")
REQUIRED = ["age", "income", "city"]
uploaded = st.file_uploader("上传 CSV（需含字段：" + ", ".join(REQUIRED) + ")", type=["csv"])
if uploaded:
    df = pd.read_csv(uploaded)
    missing = [c for c in REQUIRED if c not in df.columns]
    if missing:
        st.error(f"缺少字段：{missing}。请补齐后重新上传。")
        st.stop()
    df["pred"] = model.predict(df[REQUIRED])
    df["pred_proba"] = model.predict_proba(df[REQUIRED]).max(axis=1).round(3)
    st.dataframe(df.head(20))
    st.download_button(
        "下载预测结果", df.to_csv(index=False).encode("utf-8"),
        "predictions.csv", mime="text/csv",
    )

# ---- 6. 适用边界声明（必有） ----
with st.expander("⚠️ 本 demo 的适用边界"):
    st.markdown("""
- 训练数据来源 + 时间范围 + 样本量：（填具体值）
- 主指标 + 阈值：（如 PR-AUC=0.78，阈值=0.42）
- 子群体性能差异：（如有）
- ❌ 不得用于真实招生 / 评奖学金 / 心理评估 / 金融审批等高风险决策
- 课程演示，仅供理解模型行为
""")

# ---- 7. （可选）调试信息折叠区 ----
with st.expander("调试信息"):
    st.write("model classes:", list(model.classes_))
    try:
        st.write("model steps:", [name for name, _ in model.steps])
    except AttributeError:
        st.write("non-pipeline model")
```

## 部署前自检清单（Step 8 Checkpoint 素材）

- [ ] `joblib.dump` 的是**整个 Pipeline**，不只是 classifier；
- [ ] `@st.cache_resource` 装饰模型加载，不是 `@st.cache_data`；
- [ ] 数值输入控件设了 min/max；
- [ ] 类别输入控件用 selectbox，不让用户自由输入；
- [ ] CSV 上传做了缺失字段校验 + `st.stop()`；
- [ ] 写了适用边界 expander；
- [ ] requirements.txt 锁了 sklearn / fastai / gensim 版本。

## fastai 版骨架

把 §2 的模型加载替换为：

```python
@st.cache_resource
def load_learner_cached():
    from fastai.tabular.all import load_learner
    return load_learner("model.pkl")
learn = load_learner_cached()
```

推理：

```python
if submitted:
    row = pd.DataFrame([{"age": age, "income": income, "city": city}])
    _, pred_class, probs = learn.predict(row.iloc[0])
    st.metric("预测类别", str(pred_class.item()))
```

## gensim LDA 版骨架

见 `references/streamlit-cookbook.md` §3。
