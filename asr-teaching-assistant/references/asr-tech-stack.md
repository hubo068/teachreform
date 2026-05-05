# ASR Tech Stack

## 默认栈

| 用途 | 默认工具 | 说明 |
|---|---|---|
| 深度学习 | PyTorch | ASR 课程默认框架 |
| 音频 I/O 与特征 | torchaudio | 优先用于 waveform、resample、MFCC、MelSpectrogram |
| 备用音频处理 | librosa | 仅当 torchaudio 不方便或用户课程已使用 librosa |
| 数值处理 | numpy | 构造特征、标签、统计量 |
| 数据表 | pandas | 元数据、manifest、实验记录 |
| 可视化 | matplotlib | 波形、谱图、loss 曲线、混淆矩阵 |
| 评价 | jiwer 或自写 CER/WER | 无依赖时可实现最小编辑距离 |
| 部署演示 | streamlit | 仅当用户要求 app/demo |

## 常用 import

```python
import random
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader, TensorDataset

import torchaudio
import torchaudio.transforms as T

import matplotlib.pyplot as plt
```

辅助工具可以使用：

```python
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report
from sklearn.preprocessing import StandardScaler
```

## 切换条件

- 使用 sklearn：仅用于数据划分、标准化、传统 baseline 或指标展示，不作为 DNN 主模型。
- 使用 librosa：当课程材料已有 librosa，或需要更直观展示 STFT/MFCC。
- 使用 HuggingFace transformers：仅当课程章节明确是 wav2vec2、Whisper、预训练 ASR。
- 使用 fastai：仅当用户明确要求复用 fastai 课程栈；ASR 默认不使用 fastai。

## 课堂最小示例策略

没有真实语音数据时，可以使用：

- 合成二维“声学特征”解释 DNN 分类；
- 合成 waveform 展示采样率、分帧、谱图；
- 小型标签序列展示 CTC collapse 和 blank；
- 极小字符表演示 greedy decoding 与 CER。

必须在 markdown 中说明：玩具数据只服务概念理解，真实 ASR 需要音频特征、对齐/弱对齐、解码和更复杂评价。
