# DeskBrief: support ticket triage with open models

For each IT support ticket: a one-line summary, a category, a priority with a reply time, and a draft reply an agent
can send. Open-weight models served by Groq read the ticket and find the customer's own words for six warning signs (data
at risk, security risk, locked out, cannot work, slows work, deadline); a written desk rule turns that evidence into the
priority, and code checks every draft reply (length, no promises outside policy, no times other than the policy's
first-reply time, left for the agent to sign). On the client's 21 tickets and 10 test tickets, `qwen/qwen3.8-27b` gets
**every category right**, **74% of priorities** (1 of 16 High tickets missed) and **29 of 31 replies** through every
check; where the rule and the model's own judgement disagree, the ticket is marked for an agent, and all 5 marked tickets
were ones the rule got wrong.

| | |
|---|---|
| **Live app** | [deskbrief-support-ticket-application.streamlit.app](https://deskbrief-support-ticket-application.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/deskbrief-support-ticket-application](https://github.com/ahmadhassan-aiops/deskbrief-support-ticket-application) |
| **Notebook** | [Support_Ticket_Triage.ipynb](Support_Ticket_Triage.ipynb) |
| **Data** | `Support_ticket_text_data_mid_term.csv` (21 client tickets), `test_tickets.csv` (10 written for the evaluation), `reference_labels.csv` (hand labels written before any model ran) |
| **Model calls** | `llm_cache.jsonl`: every call, so the notebook re-runs without a key or cost |

The first version ran Mistral 7B on a Colab GPU with no reference labels: it called 19 of 21 tickets High (57% right
against the labels), cut its JSON out of free text, and its replies promised shipping labels, technician visits and
resolution times no one had set. Its answers are kept in `first_version_outputs.csv` and scored in the notebook.
