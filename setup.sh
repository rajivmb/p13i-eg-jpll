#!/bin/bash

echo "Initialising..."

# Get the Account Id first so that it is populated in the values sourced from setup_args.txt
#awsAccountId=$(aws sts get-caller-identity --query "Account" --output text)

# Load the necessary arguments from file
. setup_args.txt

echo -e "Commencing setup...\n"

read -t ${inputTimeout} -p "Enter component name [${projectName}]: " input

projectName=${input:-$projectName}

echo "Starting to setup ${projectName}"

echo "Deploying stack of ${projectName}"

aws cloudformation deploy \
    --template-file project.yaml \
    --stack-name "${projectName}" \
    --parameter-overrides \
        ArtifactName="${projectName}" \
        GitHubOwner="${githubOwner}" \
        CodeRepository="${codeRepository}" \
        GitHubTokenSecret="${gitHubTokenSecret}" \
        InternalRepoURL="${internalRepoURL}" \
        TagRoot="${tagRoot}" \
        TagProject="${tagProject}" \
        TagComponent="JPLL" \
    --capabilities CAPABILITY_IAM

echo "Completed setup of ${projectName}"
