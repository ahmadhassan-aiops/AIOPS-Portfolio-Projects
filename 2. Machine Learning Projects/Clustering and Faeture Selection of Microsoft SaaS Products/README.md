# Microsoft commercial marketplace: publisher segments and what drives revenue

A client project on a billing extract from the Microsoft commercial marketplace (467,875 billing rows for 2,397
publishers). The notebook groups publishers into segments with K-Means and tests which listing attributes, known
without looking at revenue, tell a top-earning publisher apart.

| | |
|---|---|
| **Notebook** | [Feature_selection_project_(Finalized).ipynb](Feature_selection_project_(Finalized).ipynb) |
| **Data** | Private client data, **not included** in this repository. The notebook was run on the full extract, so its outputs show results and a few sample rows; to re-run it, place the extract at `data/marketplace_billing.csv` (the folder is git-ignored). |

**Findings.** Revenue is extremely concentrated (the top 1% of publishers earn 60% of it, and 831 publishers earn
nothing). Five segments summarise the publishers, from 186 leaders with 65% of revenue to two no-revenue groups.
Using only how long a publisher has been live, how many of its offers are live and transactable, and its ratings,
gradient boosting separates top-quarter publishers with a cross-validated ROC-AUC of 0.77; time on the marketplace
and transactability matter most.

The first version dropped every zero-amount row and refund (59% of the data) through a parsing error and predicted a
label built from the same revenue columns it then "selected"; the notebook explains what changed.
