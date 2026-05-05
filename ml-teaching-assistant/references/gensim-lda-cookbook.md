# gensim LDA Cookbook（课程默认主题建模模板）

> ml-teaching-assistant 在示范主题建模 / 词向量任务时使用的标准模板。gensim ≥ 4.x。
>
> **gensim 4.x API 与 3.x 不同**，不要用 3.x 的写法。

## 1. 文本预处理（中文 + 英文）

英文：

```python
import re
from gensim.utils import simple_preprocess
from gensim.parsing.preprocessing import STOPWORDS

def en_preprocess(text):
    tokens = simple_preprocess(text, deacc=True, min_len=2, max_len=20)
    return [t for t in tokens if t not in STOPWORDS]

texts = [en_preprocess(doc) for doc in raw_docs]
```

中文：

```python
import jieba
zh_stop = set(open("stopwords_zh.txt", encoding="utf-8").read().split())

def zh_preprocess(text):
    text = re.sub(r"[^\u4e00-\u9fa5a-zA-Z0-9]+", " ", text)
    return [t for t in jieba.lcut(text) if len(t) > 1 and t not in zh_stop]

texts = [zh_preprocess(doc) for doc in raw_docs]
```

**示范要点**：
- 预处理必须保留可复现脚本（停用词表、分词器版本）；
- 主题建模对预处理高度敏感——这是 Checkpoint 必问点。

## 2. 构建词典与 corpus

```python
from gensim.corpora import Dictionary

dictionary = Dictionary(texts)
dictionary.filter_extremes(no_below=5, no_above=0.5, keep_n=20000)
corpus = [dictionary.doc2bow(t) for t in texts]
```

**示范要点**：
- `no_below=5`：词频太低剔除（噪声）；
- `no_above=0.5`：出现在过半文档的词剔除（接近停用词）；
- 这两个参数对主题质量影响极大。

## 3. 训练 LDA

```python
from gensim.models import LdaModel

lda = LdaModel(
    corpus=corpus,
    id2word=dictionary,
    num_topics=8,
    passes=10,
    iterations=100,
    chunksize=2000,
    alpha="auto",
    eta="auto",
    random_state=42,
)

for tid, words in lda.print_topics(num_words=10):
    print(f"Topic {tid}: {words}")
```

**示范要点**：
- `num_topics` 是核心超参，需用 coherence 选；
- `passes` × `iterations` 决定收敛程度；
- `alpha="auto"`（文档-主题分布）和 `eta="auto"`（主题-词分布）让模型自学先验，是默认推荐。

## 4. 用 coherence 选 num_topics

```python
from gensim.models import CoherenceModel

scores = []
for k in [4, 6, 8, 10, 12, 15]:
    m = LdaModel(corpus, id2word=dictionary, num_topics=k, passes=5, random_state=42)
    cm = CoherenceModel(model=m, texts=texts, dictionary=dictionary, coherence="c_v")
    scores.append((k, cm.get_coherence()))

for k, s in scores:
    print(f"k={k:>2}: coherence={s:.3f}")
```

**示范要点**（Checkpoint 必考）：
- **不用 perplexity**：与人类主题质量评判相关性弱；
- `coherence="c_v"` 是常用默认；
- 选拐点（coherence 不再明显上升）+ 主题可解释性双重判断。

## 5. 文档归属

```python
def doc_topic_dist(text):
    bow = dictionary.doc2bow(text)
    return lda.get_document_topics(bow, minimum_probability=0.0)

print(doc_topic_dist(texts[0]))  # [(topic_id, prob), ...]
```

**示范要点**：
- LDA 给的是"文档在每个主题上的分布"，不是单一标签；
- 学生常误以为 LDA 输出"这篇文章属于主题 3"——实际上是软分配。

## 6. 可视化

```python
import pyLDAvis
import pyLDAvis.gensim_models as gensimvis

vis = gensimvis.prepare(lda, corpus, dictionary)
pyLDAvis.save_html(vis, "lda_vis.html")
```

**示范要点**：
- pyLDAvis 的相互距离图能直观判断主题是否过度重叠；
- 主题之间圆圈高度重合 → `num_topics` 可能太大。

## 7. 持久化（对接 streamlit）

```python
lda.save("lda.model")
dictionary.save("lda.dict")

# streamlit 端：
from gensim.models import LdaModel
from gensim.corpora import Dictionary
lda = LdaModel.load("lda.model")
dictionary = Dictionary.load("lda.dict")
```

**示范要点**：
- 模型 + 词典 + 预处理函数三件必须同版本；
- 部署时输入文本要经过**同一个预处理链**（同一个分词器、同一个停用词表）。

## 8. 词向量（Word2Vec 简单示范）

```python
from gensim.models import Word2Vec

w2v = Word2Vec(sentences=texts, vector_size=100, window=5, min_count=5, workers=4, epochs=10, seed=42)
print(w2v.wv.most_similar("机器学习", topn=10))
```

**示范要点**：
- 训练语料越大越好；小语料的 word2vec 效果差到不能用；
- 如果学生数据 < 几万句子，应该用预训练词向量（属于"特殊情况"）。

## 9. 常见坑

| 坑 | 现象 | 正解 |
|---|---|---|
| 不去停用词 | 主题全是"the / 的 / 了" | `STOPWORDS` / 中文停用词表 |
| `num_topics` 拍脑袋 | 主题过密或过散 | coherence 选 + 人工判读 |
| 用 perplexity 选 k | 误以为越低越好 | 改用 coherence |
| 把训练数据洗一次、推理数据不洗 | 部署崩 | 预处理函数必须复用 |
| `random_state` 不固定 | 主题每次不同 | 固定 seed |
