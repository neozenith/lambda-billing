#! /bin/bash

# Lambda
FUNCTION_NAME="automated_billing"
FUNCTION_DESC=""
LAMBDA_RUNTIME="nodejs4.3"

# CloudWatch Events
RULE_NAME="FourthDayOfMonth"
# http://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
RULE_EXP="cron(* * 4 * ? *)"

# Archive Code
BUILD_DIR="packages/"
OUTFILE="build-$(date +"%Y%m%d%H%M").zip"
FULL_OUTPATH=$BUILD_DIR$OUTFILE
OPTIONS="-cj"
FILELIST="lambda.js package.json node_modules/"
tar $OPTIONS -f $FULL_OUTPATH $FILELIST

aws events put-rule \
  --rule-name $RULE_NAME


# Assumes ~/.aws/credentials is configured.
# http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-config-files
aws lambda create-function --function-name $FUNCTION_NAME \
  --runtime $LAMBDA_RUNTIME \
  --role "service_role/lambda_s3_readonly" \
  --handler "lambda.event_handler" \
  --description $FUNCTION_DESC \
  --zip-file "fileb://$FULL_OUTPATH" \
  --memory-size 128 \
  --timeout 3 \
  --publish

aws lambda update-function-code --function-name $FUNCTION_NAME \
  --zip-file "fileb://$FULL_OUTPATH" \
  --publish
