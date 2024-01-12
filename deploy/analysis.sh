#!/bin/bash
# Check if cluster name is provided
cluster_name=$1
if [ -z "$cluster_name" ]; then
    echo "Error: Cluster name is empty. Provide a valid cluster name."
    exit 1
fi

# Check if folder name is provided
folder_name=$2
if [ -z "$folder_name" ]
then
      echo "folder name is empty"
      exit 1
fi

# Function to gather metrics and perform analysis
gather_and_analyze() {
    local folder_name=$1
    local base_timestamp=$2
    local start_offset=$3
    local end_offset=$4

    local base_unix_timestamp=$(date -u -d "$base_timestamp" +"%s")

    local start_unix_timestamp=$(echo "$base_unix_timestamp + $start_offset * 3600" | bc)
    local start_timestamp=$(date -u -d "@$start_unix_timestamp" +"%Y-%m-%d %H:%M:%S")

    local end_unix_timestamp=$(echo "$base_unix_timestamp + $end_offset * 3600" | bc)
    local end_timestamp=$(date -u -d "@$end_unix_timestamp" +"%Y-%m-%d %H:%M:%S")

    cd /root/go/src/github.com/bjoydeep/acm-inspector/src/statistics
    python3 ./entry.py "$folder_name" "$start_timestamp" "$end_timestamp"
}

# managed cluster create time
mc_timestamp=$(kubectl get managedcluster $cluster_name  -o json | jq -r '.metadata.creationTimestamp')
gather_and_analyze "$folder_name" "$mc_timestamp" "1" "6"

# app cron job schedule time
app_schedule_timestamp=$(kubectl get cronjob app-create-${cluster_name} -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$app_schedule_timestamp" "0.5" "1.5"

# policy cron job schedule time
policy_schedule_timestamp=$(kubectl get cronjob policy-create-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$policy_schedule_timestamp" "0.5" "1.5"

# obs cron job schedule time
obs_schedule_timestamp=$(kubectl get cronjob obs-create-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$obs_schedule_timestamp" "0.5" "1.5"
