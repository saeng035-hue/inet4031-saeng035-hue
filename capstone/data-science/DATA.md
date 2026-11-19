# Applied Data Science – Dataset Documentation

## Dataset Overview
For Lab 11, I created a synthetic IT support ticket dataset using Python. I used synthetic data because my existing database contains only open tickets and does not have category or resolution time fields.

## Dataset Details
- Total records: 10,003
- Date range: July 1 – November 14, 2026
- Days covered: 136
- Categories: Network, Database, Application, Security, Hardware
- Ticket statuses: Open and Closed

## Data Generation
I used Python to generate ticket records with random categories, statuses, and creation dates. Closed tickets include resolution times, while open tickets do not.

## Data Quality
The dataset contains no missing categories and no closed tickets with missing resolution times. The results are saved in `output/data_quality.csv`.

## Assumptions and Limitations
The dataset is synthetic and does not represent actual support ticket activity. Categories and resolution times were randomly generated, so the results should be used for practice rather than real business decisions.