# DailyValue: a nutrition assistant that cites its sources

A retrieval-augmented assistant for questions about nutritional disorders (vitamin and mineral deficiencies, anemia,
malnutrition, obesity and the metabolic syndrome, diet-related digestive conditions). It answers only from
public-domain NIH pages (MedlinePlus, NHLBI, NIDDK), gives every sentence its source, says when the pages do not
cover a question, and screens messages for crises and dangerous requests before anything is generated. Hybrid search
(BM25 + `bge-small` embeddings) finds a page that answers the question in the top 5 for 39 of 40 hand-written
questions; with `qwen/qwen3.8-27b` answering, 91% of answers had every claim supported by their sources (80% for
`openai/gpt-oss-120b`), all 8 questions outside the pages were declined and all 8 safety cases were caught with the
right label. Everything runs on free tiers.

| | |
|---|---|
| **Live app** | [dailyvalue-nutrition-assistant.streamlit.app](https://dailyvalue-nutrition-assistant.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/dailyvalue-nutrition-assistant-application](https://github.com/ahmadhassan-aiops/dailyvalue-nutrition-assistant-application) |
| **Notebook** | [Nutrition_Assistant.ipynb](Nutrition_Assistant.ipynb) |
| **Data** | `data/`: the collected pages (`sources.jsonl`), 358 passages and their embeddings, the hand-written evaluation questions and the saved runs of both answer models |

The first version (a course project with LangChain, LangGraph, Chroma, mem0 and a paid `gpt-4o-mini` proxy) answered
from a copyrighted Merck Manual chapter; its deployed app never ran the retrieval workflow or the safety filter, and
it had no evaluation. The notebook replaces it.

Sources: MedlinePlus (National Library of Medicine), NHLBI and NIDDK (National Institutes of Health), public domain.
General information, not medical advice.
