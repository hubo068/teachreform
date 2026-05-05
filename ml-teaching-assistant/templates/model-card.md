# Model Card（教学版）

> AI 在 Step 6 完成后填写，作为最终学习反馈报告 §1 任务摘要的素材。

## 基本信息
- 任务模式：分类 / 回归 / 聚类 / LDA / 时间序列预测 / 图像 / 文本 / 表格 DL
- 框架：sklearn / gensim / fastai
- 数据集 + 快照：
- 切分方式：（time / group / stratification 组合）
- 主指标 + 阈值（如适用）：

## 模型清单（按对比顺序）

| 模型 | 框架 | 关键超参 | 验证指标 | test 指标 | 备注 |
|---|---|---|---|---|---|
| Dummy / Naive | sklearn | most_frequent | — | — | baseline 下限 |
| Logistic Regression | sklearn | C=1, l2 | — | — | 可解释 baseline |
| Random Forest | sklearn | n_estimators=200, max_depth=10 | — | — | 升级模型 |
| ResNet34 (fastai) | fastai | lr=1e-3, fine_tune 2 | — | — | 仅当 baseline 不够时 |

## 最终选用模型
- 模型名：
- 选用理由（vs baseline 提升多少 / 可解释性 / 部署可行性）：
- 训练时间 / 推理时间：
- 模型文件路径：

## 适用边界
- 适用人群 / 时段 / 场景：
- ❌ 不适用：

## 风险与未解决问题
- 子群体表现差异（如适用）：
- 概率校准（如适用）：
- 标签噪声估计：
- 上线前还缺什么：

## 复现要素
- 随机种子：
- sklearn 版本：
- fastai 版本（如适用）：
- gensim 版本（如适用）：
- 数据快照：
- 主要 commit / notebook 路径：
