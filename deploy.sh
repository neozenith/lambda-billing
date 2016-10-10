#! /bin/bash

# Lambda
FUNCTION_NAME="automated_billing"
FUNCTION_DESC="Automated_BillingOf_AWS_Resources_by_tags"
LAMBDA_RUNTIME="nodejs4.3"
if [ -z "$AWS_ACCOUNT_ID" ]; then
  eval "$(cat .env | grep AWS_ACCOUNT_ID)"
fi
echo $AWS_ACCOUNT_ID
AWS_REGION="us-west-2"

# CloudWatch Events
# http://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
RULE_NAME="FourthDayOfMonth"
RULE_EXP="cron(* * 4 * ? *)"

# Archive Code
BUILD_DIR="output/"
OUTFILE="build-$(date +"%Y%m%d%H%M").zip"
FULL_OUTPATH=$BUILD_DIR$OUTFILE

function check_install_aws_cli () {
  echo "Checking for AWS CLI tool"
  if [ -z "$(which aws)" ]; then
    echo "Installing AWS CLI tool"
    check_install_pip
    sudo pip install --upgrade awscli
  fi

  # Assumes ~/.aws/credentials is configured.
  AWS_CREDENTIALS_HELP_URL="http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-config-files"
  echo "Checking credentials are installed"
  if [ -f "~/.aws/credentials" ]; then
    echo "AWS Credentials not found!!"
    echo "Openning web page in 5 sec: $AWS_CREDENTIALS_HELP_URL"
    sleep 5
    open "$AWS_CREDENTIALS_HELP_URL"
    kill -INT $$
  fi
}

function check_install_pip () {
  echo "Checking for Pip..."
  if [ -z "$(which pip)" ]; then
    echo "Installing Pip"
    curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py -o "get-pip.py"
    sudo python get-pip.py
  fi
}

function build_package () {
  OPTIONS="-r"
  FILELIST="lambda.js package.json"
  zip $OPTIONS $FULL_OUTPATH $FILELIST
}

function create_lambda_function(){
  ZIP_BUILD_PATH="fileb://$FULL_OUTPATH"
  ls -laFGh $FULL_OUTPATH 
  echo $FUNCTION_NAME 
  echo $LAMBDA_RUNTIME
  echo $ZIP_BUILD_PATH
  AWS_ROLE="arn:aws:iam::$AWS_ACCOUNT_ID:role/service-role/lambda_s3_readonly" 
  echo $AWS_ROLE

  aws lambda create-function --function-name $FUNCTION_NAME \
    --runtime $LAMBDA_RUNTIME \
    --handler "lambda.event_handler" \
    --zip-file "$ZIP_BUILD_PATH" \
    --description $FUNCTION_NAME \
    --role $AWS_ROLE 
}

function update_lambda_function(){
  aws lambda update-function-code --function-name $FUNCTION_NAME \
    --zip-file "fileb://$FULL_OUTPATH" \
    --publish
}

function create_rule(){
  aws events put-rule \
    --name "$RULE_NAME" \
    --schedule-expression "$RULE_EXP" \
    --state ENABLED \
    --description "$RULE_NAME" 
}

function create_update_lambda () {
  FUNCTION_EXISTS="$(aws lambda list-functions | grep $FUNCTION_NAME)"
  echo $FUNCTION_EXISTS
  if [ -z "$FUNCTION_EXISTS" ]; then
    create_lambda_function
  else
    update_lambda_function
  fi
}

function create_update_event_trigger (){
  echo "Check if rule $RULE_NAME with expression $RULE_EXP exists..."
  RULE_EXISTS="$(aws events list-rules | grep $RULE_NAME)"
  echo $RULE_EXISTS
  if [ -z "$RULE_EXISTS" ]; then
    echo "No rule found. Creating..."
    create_rule
  fi

  TARGET_ARN="arn:aws:lambda:$AWS_REGION:$AWS_ACCOUNT_ID:function:$FUNCTION_NAME"
  echo "TargetArn: $TARGET_ARN"
  TARGET_JSON="{\"Id\":\"1\", \"Arn\":\"$TARGET_ARN\"}"
  echo $TARGET_JSON

  echo "Check if $RULE_NAME is targetting $TARGET_ARN..."
  RULE_TARGETTED="$(aws events list-targets-by-rule --rule $RULE_NAME | grep $FUNCTION_NAME)" 
  if [ -z "$RULE_TARGETTED" ]; then
    echo "Targetting Rule: $RULE_NAME --> $TARGET_JSON"
    aws events put-targets \
      --rule $RULE_NAME \
      --targets "$TARGET_JSON"
  fi

  echo "Targets for Rule: $RULE_NAME"
  aws events list-targets-by-rule --rule $RULE_NAME
}

function  cleanup_build() {
  echo "DELETING: $FULL_OUTPATH"
  rm -v "$FULL_OUTPATH"
}

function build(){
  check_install_aws_cli
  build_package
  create_update_lambda
  create_update_event_trigger
  cleanup_build
}

build

