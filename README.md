
# Greengrid Energy Procurement Optimization

A Data Driven Decision Making project applying Mixed-Integer Linear Programming (MILP) in R to optimize renewable energy procurement for GreenGrid Energy, considering supplier selection, minimum commitments, supplier alliances, concentration limits, and pricing fairness.

## Project Overview

GreenGrid Energy faces the challenge of meeting electricity demand across multiple delivery periods while minimizing procurement costs and satisfying operational and contractual restrictions.

The project develops an optimization model to determine:
- Which renewable energy suppliers should be selected.
- How much electricity should be procured from each supplier in each delivery period.
- How supplier minimum commitments affect procurement decisions.
- How supplier and alliance concentration limits influence sourcing strategies.
- Whether an additional pricing fairness constraint changes the procurement solution.

The model is evaluated using three datasets of different sizes to examine computational performance and scalability.

## Objectives

- Minimize total renewable energy procurement costs.
- Satisfy electricity demand across all delivery periods.
- Enforce supplier minimum commitment requirements.
- Limit individual supplier and supplier alliance concentration.
- Compare the performance of HiGHS and GLPK optimization solvers.
- Evaluate the effect of an additional pricing fairness constraint.

## Methodology

The project uses a Mixed-Integer Linear Programming (MILP) formulation.

### Decision Variables

- `x[i,j]`: Quantity of electricity procured from supplier `i` during period `j`.
- `y[i]`: Binary variable indicating whether supplier `i` is selected.

### Objective Function

Minimize total procurement expenditure across suppliers and delivery periods.

### Key Constraints

1. Demand satisfaction.
2. Supplier concentration limits.
3. Minimum supplier commitments.
4. Big-M linking constraints.
5. Supplier alliance concentration limits.
6. Pricing fairness constraint (Part D).

The Big-M parameter is defined using the maximum electricity demand across delivery periods.

## Dataset Description

Three datasets are used to evaluate the model at different scales.

| Dataset | Suppliers | Delivery Periods | Alliances |
|---|---:|---:|---:|
| Small | 8 | 3 | 2 |
| Medium | 30 | 300 | 8 |
| Large | 50 | 400 | 10 |

The datasets are generated programmatically using R, with a fixed random seed to support reproducibility.

## Tools and Technologies

- **Language:** R
- **Optimization:** Mixed-Integer Linear Programming (MILP)
- **Packages:** `ompr`, `ompr.roi`, `ROI.plugin.highs`, `ROI.plugin.glpk`, `magrittr`
- **Optimization Solvers:** HiGHS and GLPK
- **Analysis:** Solver performance comparison and LP relaxation analysis

## Requirements

The project was developed using R.

The following R packages are required:

- ompr
- ompr.roi
- ROI
- ROI.plugin.highs
- ROI.plugin.glpk
- magrittr

Install the packages using:

```r
install.packages(c(
  "ompr",
  "ompr.roi",
  "ROI",
  "ROI.plugin.highs",
  "ROI.plugin.glpk",
  "magrittr"
))```

## Results and Solver Comparison

The following results are taken from the computational experiments documented in the project report.

### Part B — Original Optimization Model

| Dataset | HiGHS Objective | GLPK Objective | HiGHS Runtime (sec) | GLPK Runtime (sec) |
|---|---:|---:|---:|---:|
| Small | 63,063.32 | 63,063.32 | 0.04 | 0.03 |
| Medium | 8,012,167 | 8,038,668 | 117.48 | 3,609.39 |
| Large | 10,927,262 | 10,996,045 | 3,636.38 | 3,640.23 |

### Part D — Pricing Fairness Model

| Dataset | HiGHS Objective | GLPK Objective | HiGHS Runtime (sec) | GLPK Runtime (sec) |
|---|---:|---:|---:|---:|
| Small | 63,063.32 | 63,063.32 | 0.04 | 0.03 |
| Medium | 8,012,167 | 8,050,136 | 250.39 | 3,610.32 |
| Large | 10,927,262 | 11,018,786 | 3,637.92 | 3,651.56 |

*Note: Reported runtimes are reproduced as documented in the assignment report. Some exceed the configured 3,600-second solver time limit.*

## Key Findings

- HiGHS produced lower objective values than GLPK for the medium and large datasets.
- Solver performance deteriorated as the number of suppliers and delivery periods increased.
- The LP relaxation provided a lower-bound benchmark for evaluating MILP solutions.
- Supplier alliance restrictions reduced the flexibility to source exclusively from the lowest-priced suppliers.
- Minimum commitment requirements introduced additional rigidity into procurement decisions.
- The pricing fairness constraint did not change the HiGHS objective values in the tested datasets.
- Although non-binding in these experiments, the additional fairness constraint increased computational time.

## Managerial Implications

The results demonstrate that procurement decisions should not be based solely on individual supplier prices.

Supplier alliances, minimum contractual commitments, and concentration limits influence the overall procurement strategy. The optimization framework provides a structured way to balance cost efficiency, supplier diversification, and operational requirements.

The solver comparison also highlights the importance of selecting an appropriate optimization engine when dealing with larger decision problems.

## Repository Structure

```text
renewable-energy-procurement-optimization/
│
├── data/
│   ├── small.csv
│   ├── medium.csv
│   └── large.csv
│
├── scripts/
│   ├── data_file_generation.R
│   └── Greengrid Optimisation Model.R
│
├── results/
│   └── solver_comparison.csv
│
└── README.md
```

## Reproducibility

The datasets are generated using an R script with a fixed random seed. The optimization model uses the generated datasets to solve the procurement problem using HiGHS and GLPK.

To reproduce the analysis, ensure that the required R packages and optimization solvers are installed and that the dataset paths in the scripts match the repository structure.

## Acknowledgement

This project was developed as part of the Data Driven Decision Making module of the MSc Business Analytics programme at Queen's University Belfast.
