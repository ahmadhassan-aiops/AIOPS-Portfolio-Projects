# Microsoft commercial marketplace: free trials, free plans, conversion and revenue

A client project on Microsoft commercial marketplace billing extracts (2020 to 2024): 1.28 million billing lines for
939 products with free trials, 4.6 million lines for 7,265 products with free plans, and product-level trial funnels,
ratings and customer segments.

| | |
|---|---|
| **Notebook** | [Microsoft_Marketplace_Analysis.ipynb](Microsoft_Marketplace_Analysis.ipynb) |
| **Data** | Private client data, **not included** in this repository. The notebook was run on the full extracts, so its outputs show results and a few sample rows; to re-run it, place the extracts in `data/` as described in its first section (the folder is git-ignored). |

**Questions answered:** how revenue grew and where it comes from (service, sales channel, billing action, MACC
enrolment, plans, products, publishers, customers), what gets refunded, whether ratings relate to revenue and
conversion, how often free-plan customers start paying and whether a free trial helps, how long customers take to
convert, and how small-business, corporate and enterprise customers buy through each channel.

**Findings.** Revenue from free-trial products grew from $48M (FY21) to $112M (FY24) but flattened in the last year.
It is concentrated in virtual-machine licences, field-led enterprise sales and a few large security and infrastructure
publishers; half of customers never pay. Free plans convert on day one or not at all, free trials around day 30;
adding a free trial to a free-plan product does not raise conversion. Rated products convert far more often, but the
star score itself is unrelated to conversion. Enterprise customers are 18% of segmented customers and 74% of revenue.

This notebook replaces five earlier deliveries on the same data. Among the fixes: two of the monthly free-plan files
repeated another file's rows (495,260 rows were counted twice or three times), conversion is now measured per
customer instead of per billing line, and group comparisons use rank-based tests and effect sizes instead of t-tests
on heavily skewed revenue.
