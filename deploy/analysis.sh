#!/bin/bash

KUBECTL=${KUBECTL:-oc}

# Get the directory of the currently executing script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$( cd "$( dirname "${DIR}" )" && pwd )"
printf "DIR: ${DIR}, BASE_DIR: ${BASE_DIR}\n"

# Check if cluster name is provided
cluster_name=$1
if [ -z "$cluster_name" ]; then
    echo "Error: Cluster name is empty. Provide a valid cluster name."
    exit 1
fi

folder_name=$BASE_DIR/$cluster_name
analysis_file=$folder_name/acm_analysis
analysis_file_relative_path="./$cluster_name/acm_analysis"

# Function to gather metrics and perform analysis
gather_and_analyze() {
    local folder_name=$1
    local base_timestamp=$2
    local start_offset=$3
    local end_offset=$4

    if [ "$base_timestamp" = "null" ]; then
        echo "no base timestamp"
        return
    fi

    local base_unix_timestamp=$(date -u -d "$base_timestamp" +"%s")

    local start_unix_timestamp=$(echo "$base_unix_timestamp + $start_offset * 3600" | bc)
    local start_timestamp=$(date -u -d "@$start_unix_timestamp" +"%Y-%m-%d %H:%M:%S")

    local end_unix_timestamp=$(echo "$base_unix_timestamp + $end_offset * 3600" | bc)
    local end_timestamp=$(date -u -d "@$end_unix_timestamp" +"%Y-%m-%d %H:%M:%S")

    python3 $BASE_DIR/src/statistics/entry.py "$folder_name" "$start_timestamp" "$end_timestamp" >> $analysis_file
}

# managed cluster create time
mc_timestamp=$(${KUBECTL} get managedcluster $cluster_name  -o json | jq -r '.metadata.creationTimestamp')
gather_and_analyze "$folder_name" "$mc_timestamp" "-2" "0"
gather_and_analyze "$folder_name" "$mc_timestamp" "1" "6"

# app cron job schedule time
app_schedule_timestamp=$(${KUBECTL} get cronjob app-create-${cluster_name} -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$app_schedule_timestamp" "0.5" "1.5"

# policy cron job schedule time
policy_schedule_timestamp=$(${KUBECTL} get cronjob policy-create-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$policy_schedule_timestamp" "0.5" "1.5"

# obs cron job schedule time
obs_schedule_timestamp=$(${KUBECTL} get cronjob obs-create-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$obs_schedule_timestamp" "0.5" "1.5"

# enable-app
enable_app_schedule_timestamp=$(${KUBECTL} get cronjob enable-app-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$enable_app_schedule_timestamp" "0.5" "1.5"

# enable-policy-proxy
enable_policy_proxy_schedule_timestamp=$(${KUBECTL} get cronjob enable-policy-proxy-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$enable_policy_proxy_schedule_timestamp" "0.5" "1.5"

# enable-policy-search
enable_policy_search_schedule_timestamp=$(${KUBECTL} get cronjob enable-policy-search-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$enable_policy_search_schedule_timestamp" "0.5" "1.5"

# enable-all
enable_all_schedule_timestamp=$(${KUBECTL} get cronjob enable-all-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$enable_all_schedule_timestamp" "0.5" "1.5"
echo "The analysis is complete, details see $analysis_file_relative_path"
