# AWS Lambda Automated Billing

## Acceptance Criteria
This project is a NodeJS Lambda function that:
- Scheduled for the 4th day of the month to run
- scan S3 billing bucket (as configured by environment variables) for prior month detailed billing information with tags
- separate out all costs by tags `billing:name`, `billing:email`, `billing:project`
- generate PDF Invoice
- email Invoice to `billing:email`
