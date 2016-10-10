# AWS Lambda Automated Billing
[![Build Status](https://travis-ci.org/neozenith/lambda-billing.svg?branch=master)](https://travis-ci.org/neozenith/lambda-billing)

## Acceptance Criteria
This project is a NodeJS Lambda function that:
- [x] Scheduled for the 4th day of the month to run
 - [x] Script Deploy to lambda
 - [x] Script creation of CloudWatch Event Rule
 - [x] Script targeting event rule to lambda function
 - [ ] Script dev/stage/prod process to integrate changes to lambda function
 - [ ] Script creation of IAM service role
- [ ] scan S3 billing bucket (as configured by environment variables) for prior month detailed billing information with tags
- [ ] separate out all costs by tags `billing:name`, `billing:email`, `billing:project`
- [ ] generate PDF Invoice
 - [ ] section line items per `billing:project`
 - [ ] one line item per AWS `ProductName` billable
 - [ ] Embed PayPal PayNow link
- [ ] email Invoice to `billing:email`

## Getting Started

`npm install`

`npm test`

## Local Development

Test fixtures are located in the `fixtures/` directory. This contains `event.json`
and `context.json`. This should represent the data you are trying to mock.

Run the following to test your event handler

`npm test`

## Deployment

`. deploy.sh`

At this stage there is only a bash script which runs the AWS CLI for the deploy process
