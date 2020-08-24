#!/bin/bash

echo "Initialising..."

# Get the Account Id first so that it is populated in the values sourced from setup_args.txt
#awsAccountId=$(aws sts get-caller-identity --query "Account" --output text)

spinner="/-\|"

fetch_pipeline_status() {
  aws codepipeline list-pipeline-executions \
        --pipeline-name ${pipelineName} \
        --max-items 1 \
        --query "pipelineExecutionSummaries[0].status" \
        --output text | head -n 1
}

#<REF/> https://stackoverflow.com/a/12694189
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then DIR="${PWD}"; fi
printf "DIR is %s\n" ${DIR}

# Load the necessary arguments from file
. ${DIR}/setup_args.txt

printf "Commencing setup...\n"

read -t ${inputTimeout} -p "Enter component name [${projectName}] or press <Enter> to accept default, you have ${inputTimeout}s: " inputProjectName

projectName=${inputProjectName:-$projectName}

printf "\n"

read -t ${inputTimeout} -p "Enter your Secret name of GitHub token stored in AWS Secrets Manager [${gitHubTokenSecret}], you have ${inputTimeout}s: " inputGitHubTokenSecret

gitHubTokenSecret=${inputGitHubTokenSecret:-$gitHubTokenSecret}

printf "\n"

read -t ${inputTimeout} -p "Enter your GitHub Packages (repo) URL to use as private Maven repo [${internalRepoURL}], you have ${inputTimeout}s: " inputGitHubMavenRepoURL

internalRepoURL=${inputGitHubMavenRepoURL:-$internalRepoURL}

printf "\nStarting to setup %s\n" ${projectName}

printf "Deploying stack of %s\n" ${projectName}

aws cloudformation deploy \
    --template-file ${DIR}/project.yaml \
    --stack-name "${projectName}" \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides \
        ArtifactName="${projectName}" \
        GitHubOwner="${githubOwner}" \
        CodeRepository="${codeRepository}" \
        GitHubTokenSecret="${gitHubTokenSecret}" \
        InternalRepoURL="${internalRepoURL}" \
        TagRoot="${tagRoot}" \
        TagProject="${tagProject}" \
        TagComponent="JPLL" \
        #CreateGitHubWebHook=${createGitHubWebHook}

pipelineName=$(aws cloudformation describe-stacks \
    --stack-name "${projectName}" \
    --query "Stacks[*].Outputs[?OutputKey=='PipelineName'].OutputValue" \
    --output text)

printf "Deploying Lambda Layer via Pipeline: %s\n" ${pipelineName}

pipelineStatus=$(fetch_pipeline_status)
waitTime=0
until [[ ${pipelineStatus} == "Succeeded" ]]; do
    minutes=$((${waitTime}/60))
    seconds=$((${waitTime}%60))
    printf "\rPipeline status is: ${pipelineStatus}. Waiting... ${spinner:i++%${#spinner}:1} [ %02dm %02ds ]" ${minutes} ${seconds}
    sleep 5
    waitTime=$((${waitTime}+5))
    pipelineStatus=$(fetch_pipeline_status)
done
printf "\nPipeline status is: %s\n" ${pipelineStatus}

printf "Completed setup of %s\n" ${projectName}
