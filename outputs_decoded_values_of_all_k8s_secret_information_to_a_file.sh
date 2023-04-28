#!/bin/bash

# 시크릿 정보를 저장할 파일 경로
OUTPUT_FILE=output.txt

# 모든 시크릿의 명과 네임스페이스 가져오기
secrets=$(kubectl get secrets --all-namespaces -o=jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}')

# 시크릿 정보 출력 및 파일에 저장
while read -r secret; do
  namespace=$(echo "$secret" | awk '{print $1}')
  name=$(echo "$secret" | awk '{print $2}')
  echo "Namespace: $namespace, Secret Name: $name"

  # 시크릿 정보 가져오기
  secret_data=$(kubectl get secret -n $namespace $name -o json | jq -r '.data | to_entries | map("\(.key) \(.value)") | .[]')

  # 시크릿 정보를 파일에 저장
  echo "[ $namespace-$name ]" >> $OUTPUT_FILE
  echo "$secret_data" | while read -r line; do
    key=$(echo "$line" | awk '{print $1}')
    value=$(echo "$line" | awk '{print $2}')
    decoded_value=$(echo "$value" | base64 --decode)
    echo "$key : $decoded_value" >> $OUTPUT_FILE
  done
done <<< "$secrets"
