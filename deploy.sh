#! /bin/bash

# Lambda
FUNCTION_NAME="automated_billing"
FUNCTION_DESC="Automated_BillingOf_AWS_Resources_by_tags"
LAMBDA_RUNTIME="nodejs4.3"

# CloudWatch Events
RULE_NAME="FourthDayOfMonth"
# http://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
RULE_EXP="cron(* * 4 * ? *)"

# Archive Code
BUILD_DIR="output/"
OUTFILE="build-$(date +"%Y%m%d%H%M").zip"
FULL_OUTPATH=$BUILD_DIR$OUTFILE
OPTIONS="-r"
FILELIST="lambda.js package.json node_modules/"
zip $OPTIONS $FULL_OUTPATH $FILELIST


function create_lambda_function(){
  # Assumes ~/.aws/credentials is configured.
  # http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-config-files
  ZIP_BUILD_PATH="fileb://$FULL_OUTPATH"
  ls -laFGh $FULL_OUTPATH 

  echo $FUNCTION_NAME 
  echo $LAMBDA_RUNTIME
  echo $ZIP_BUILD_PATH

  if [ -z "$AWS_ACCOUNT_ID" ]; then
    eval "$(cat .env | grep AWS_ACCOUNT_ID)"
  fi

  echo $AWS_ACCOUNT_ID
  AWS_ROLE="arn:aws:iam::$AWS_ACCOUNT_ID:role/service-role/lambda_s3_readonly" 
  echo $AWS_ROLE

aws lambda create-function --function-name $FUNCTION_NAME \
  --runtime $LAMBDA_RUNTIME \
  --handler "lambda.event_handler" \
  --zip-file "$ZIP_BUILD_PATH" \
  --role $AWS_ROLE 
}

function update_lambda_function(){
  aws lambda update-function-code --function-name $FUNCTION_NAME \
    --zip-file "fileb://$FULL_OUTPATH" \
    --publish
}
function create_rule(){
  aws events put-rule \
    --name $RULE_NAME
    --schedule-expression $RULE_EXP
    --state ENABLED
    --description $RULE_NAME 
}

FUNCTION_EXISTS="$(aws lambda list-functions | grep $FUNCTION_NAME)"
echo $FUNCTION_EXISTS
if [ -z "$FUNCTION_EXISTS" ]; then
  echo "The function does NOT exist!!"
  create_lambda_function
else
  echo "The function exists!!"
fi

echo "DELETING:"
rm -v output/*.zip
