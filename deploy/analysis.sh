#!/bin/bash
# Check if cluster name is provided
cluster_name=$1
if [ -z "$cluster_name" ]; then
    echo "Error: Cluster name is empty. Provide a valid cluster name."
    exit 1
fi

folder_name=$PWD/$cluster_name
analysis_file=$folder_name/acm_analysis

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
    python3 ./entry.py "$folder_name" "$start_timestamp" "$end_timestamp" >> $analysis_file
}

# gether metrics
mkdir $folder_name
DURATION=$(oc get managedclusters $cluster_name --no-headers | awk '{gsub(/h/,"",$6); $6+=1; print $6"h"}')
docker run -e OC_CLUSTER_URL=$OC_CLUSTER_URL -e OC_TOKEN=$OC_TOKEN -e DURATION=$DURATION -e CLUSTER=spoke -v $folder_name:/acm-inspector/output quay.io/haoqing/acm-inspector:latest > $folder_name/logs
echo "The metrics has been collected and placed in $folder_name, details see $folder_name/logs"

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

# enable-app
enable_app_schedule_timestamp=$(kubectl get cronjob enable-app-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$enable_app_schedule_timestamp" "0.5" "1.5"

# enable-policy-proxy
enable_policy_proxy_schedule_timestamp=$(kubectl get cronjob enable-policy-proxy-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$enable_policy_proxy_schedule_timestamp" "0.5" "1.5"

# enable-policy-search
enable_policy_search_schedule_timestamp=$(kubectl get cronjob enable-policy-search-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$enable_policy_search_schedule_timestamp" "0.5" "1.5"

# enable-all
enable_all_schedule_timestamp=$(kubectl get cronjob enable-all-$cluster_name -o json | jq -r '.status.lastScheduleTime')
gather_and_analyze "$folder_name" "$enable_all_schedule_timestamp" "0.5" "1.5"
echo "The analysis is complete, details see $analysis_file"
