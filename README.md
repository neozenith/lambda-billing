# AWS Lambda Automated Billing

## Acceptance Criteria
This project is a NodeJS Lambda function that:
- [/] Scheduled for the 4th day of the month to run
- [ ] scan S3 billing bucket (as configured by environment variables) for prior month detailed billing information with tags
- [ ] separate out all costs by tags `billing:name`, `billing:email`, `billing:project`
- [ ] generate PDF Invoice
- [ ] email Invoice to `billing:email`

## Getting Started

`npm install`

`npm test`

## Local Development

Test fixtures are located in the `fixtures/` directory. This contains `event.json`
and `context.json`. This should represent the data you are trying to mock.

Run the following to test your even handler

`npm test`

## Deployment

`. deploy.sh`

At this stage there is only a bash script which runs the AWS CLI
