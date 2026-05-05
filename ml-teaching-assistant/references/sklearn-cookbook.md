# sklearn Cookbook（课程默认经典 ML 模板）

> 本文件是 ml-teaching-assistant 推送给学生的"标准写法"。学生写出别的风格时，先问他"这样有什么风险"，再决定是否纠正。
>
> sklearn ≥ 1.3。

## 1. 标准切分（分类 / 回归）

```python
from sklearn.model_selection import train_test_split

X = df.drop(columns=["target"])
y = df["target"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,
    stratify=y,       # 分类任务且类别不平衡时必开
    random_state=42,
)
```

**教学点**：
- 永远先切分，再做 fit/transform。
- 回归不用 `stratify`；若目标分布偏态，可用 `pd.qcut(y, 5)` 做分层。
- 同一实体多次出现（如学号/病人/订单用户） → 用 `GroupShuffleSplit`。
- 时间序列 → 用 `TimeSeriesSplit`。

## 2. Pipeline + ColumnTransformer（核心模板）

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.linear_model import LogisticRegression

num_cols = ["age", "income"]
cat_cols = ["city", "gender"]

numeric_pipe = Pipeline([
    ("impute", SimpleImputer(strategy="median")),
    ("scale", StandardScaler()),
])

categorical_pipe = Pipeline([
    ("impute", SimpleImputer(strategy="most_frequent")),
    ("encode", OneHotEncoder(handle_unknown="ignore")),
])

preprocessor = ColumnTransformer([
    ("num", numeric_pipe, num_cols),
    ("cat", categorical_pipe, cat_cols),
])

pipe = Pipeline([
    ("prep", preprocessor),
    ("clf", LogisticRegression(max_iter=1000)),
])

pipe.fit(X_train, y_train)
```

**教学点**：
- `handle_unknown="ignore"` 防止部署时遇到新类别炸错。
- 所有预处理放 Pipeline 内部 → 自动遵守 split-before-fit。
- `sklearn.set_config(display="diagram")` 可显示 pipeline 结构图。

## 3. 交叉验证（调参前）

```python
from sklearn.model_selection import StratifiedKFold, cross_val_score

cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
scores = cross_val_score(pipe, X_train, y_train, cv=cv, scoring="f1")
print(scores, scores.mean(), scores.std())
```

**教学点**：
- 分类 → `StratifiedKFold`；回归 → `KFold`；分 group → `GroupKFold`；时间 → `TimeSeriesSplit`。
- `scoring` 必须贴任务代价。

## 4. 超参搜索（GridSearch / Randomized）

```python
from sklearn.model_selection import GridSearchCV

param_grid = {
    "clf__C": [0.01, 0.1, 1, 10],
    "clf__penalty": ["l2"],
}

grid = GridSearchCV(pipe, param_grid, cv=cv, scoring="f1", n_jobs=-1)
grid.fit(X_train, y_train)
print(grid.best_params_, grid.best_score_)
```

**教学点**：
- 超参名格式：`<step_name>__<param>`。
- 参数空间大 → `RandomizedSearchCV` + `n_iter`。
- **best_score 是 val CV 上的，不是 test 上的**；最终 test 再跑一次 `grid.best_estimator_.score(X_test, y_test)`。

## 5. 评估指标

```python
from sklearn.metrics import (
    classification_report, confusion_matrix,
    roc_auc_score, average_precision_score,
    precision_recall_curve, roc_curve,
)

y_pred  = pipe.predict(X_test)
y_proba = pipe.predict_proba(X_test)[:, 1]

print(classification_report(y_test, y_pred, digits=3))
print(confusion_matrix(y_test, y_pred))
print("ROC-AUC:", roc_auc_score(y_test, y_proba))
print("PR-AUC :", average_precision_score(y_test, y_proba))
```

**教学点**：
- 类别不平衡 → PR-AUC 比 ROC-AUC 更诚实。
- 回归 → `mean_absolute_error` / `mean_squared_error` / `r2_score`，必要时加分段误差。
- **最终上线阈值不默认 0.5**；按任务代价或 PR 曲线选。

## 6. 校准（高风险任务）

```python
from sklearn.calibration import CalibratedClassifierCV, calibration_curve

cal = CalibratedClassifierCV(pipe, method="isotonic", cv=5)
cal.fit(X_train, y_train)
```

**教学点**：
- 要用阈值做决策 → 检查 calibration curve。
- 偏离 45°线越多，说明概率越不可信。

## 7. 模型持久化（对接 streamlit）

```python
import joblib
joblib.dump(pipe, "model.joblib")

# 在 streamlit 端：
import joblib
model = joblib.load("model.joblib")
pred = model.predict(X_new)
```

**教学点**：
- **必须 dump 整个 pipeline**，不只是 classifier；否则部署时预处理丢失。
- 推理数据的列顺序/名字与训练一致。

## 8. 聚类（KMeans baseline）

```python
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import silhouette_score

X_scaled = StandardScaler().fit_transform(X)
km = KMeans(n_clusters=3, n_init=10, random_state=42)
labels = km.fit_predict(X_scaled)
print("silhouette:", silhouette_score(X_scaled, labels))
```

**教学点**：
- 不标准化 → 大量纲特征会主导距离。
- 报告每群规模、top 特征、是否可命名。

## 9. 常见坑（学生容易踩）

| 坑 | 现象 | 正解 |
|---|---|---|
| 先 `fit(X_all)` 再切分 | 泄漏 | Pipeline 内做 |
| `LabelEncoder` 处理输入特征 | 给模型"大小"假信号 | 用 `OneHotEncoder` 或 `OrdinalEncoder`（仅有序时） |
| 只看 Accuracy | 类别不平衡时假高分 | 看 F1 / PR-AUC / Recall |
| `train_test_split(shuffle=True)` 做时间序列 | 未来数据预测过去 | `TimeSeriesSplit` |
| 部署时用 `StandardScaler().fit(X_new)` | 每个 batch 均值变 | 训练时的 scaler 必须 dump 并加载 |
| 用 `test` 调参 | 过度乐观 | CV 调参，test 只终评 |
