#!/bin/bash

echo "Initialising..."

delete_stack () {
    echo "Deleting stack ${1}"
    aws cloudformation delete-stack --stack-name ${1}
}

# Load the necessary arguments from the same setup args file
. setup_args.txt

echo -e "Commencing tear down...\n"

read -t ${inputTimeout} -p "Enter component name [${projectName}]: " input
projectName=${input:-$projectName}

stacks=("${projectName}")

echo "Starting to tear down ${projectName}"

for stack in ${stacks[@]}; do
  delete_stack ${stack}
done

echo "Completed tearing down ${projectName}"
