# Time-Series Guardrails（时间序列护栏 — 教学版）

> 仅当任务属于"按时间顺序预测未来值/状态/区间"时加载。简化自 `domain-aware-data-analyst/references/time-series-guardrails.md`。

## 1. 区分两件事

- **时间戳只是普通字段**：例如"按用户特征预测违约"，时间戳只是出生日期之类。仍走标准 ML 流程。
- **真正的时间序列预测**：例如"用历史销量预测未来 4 周销量"。**禁止随机切分**，必须 rolling backtest。

→ Checkpoint 0 必考：让学生区分。

## 2. 切分

- ❌ `train_test_split(shuffle=True)`：用未来数据预测过去；
- ✅ `TimeSeriesSplit`（sklearn）；
- ✅ rolling-origin / expanding window / sliding window；
- 若标签确认 / 数据修订 / 特征窗口需要缓冲区 → 显式 `gap`；
- 评估必须按 horizon 分别报告（短/中/长 horizon），不要混合一个总分。

## 3. baseline

- 必比 **naive**（用昨天预测今天）；
- 若有明确季节周期，必比 **seasonal naive**（用去年同期预测）；
- `rolling mean` 只能算弱 baseline；
- **复杂模型必须在 rolling backtest 上稳定超过最佳 baseline**，才能称 forecast 有效。

## 4. 特征

时间序列特征只允许使用**预测时点前可知的信息**：
- ✅ lag features（t-1, t-7, t-30）
- ✅ rolling window stats（trailing mean / std）
- ✅ calendar / holiday
- ✅ 已确认未来已知的 covariates（如下周已排好的促销）
- ❌ 任何"未来才知道"的外生变量（如未来天气真值——预报值是另一回事）

→ Checkpoint 3 必考：让学生分辨什么 covariate 是 future-known。

## 5. 评估指标

- 优先 **MAE / RMSE / WAPE / sMAPE / quantile loss**；
- ❌ **MAPE 在 0 或接近 0 的序列上不可靠**——直接发散；
- 若需要预测区间，用分位数预测或 conformal prediction。

## 6. 数据审计补充

- 时间戳是否单调、是否有重复、是否有缺口；
- 频率（日/周/月）是否规则；
- 是否有数据修订 / 回填；
- 季节性 / 趋势 / 结构突变；
- 历史窗口是否足够支撑当前 horizon（horizon 4 周但只有 2 个月历史 → 不可信）。

## 7. 课程示范栈

- 简单 baseline / 探索：sklearn `TimeSeriesSplit` + `LinearRegression` / 自写 naive；
- 进阶：`statsmodels` 的 ARIMA / SARIMAX，或 `prophet`；
- 深度学习：fastai 没有强 time-series 模块——若任务必须用深度学习，属于"特殊情况"，可考虑 `pytorch-forecasting` / `darts`，并显式告诉学生"这超出课程默认栈"。
