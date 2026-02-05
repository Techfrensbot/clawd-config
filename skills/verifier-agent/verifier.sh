#!/bin/bash
# Claim Verifier Agent - Validates claims for accuracy, dates, and relevance

set -e

# Configuration
VERIFIER_STATE="/root/clawd/memory/verifier-state.json"
VERIFIER_LOG="/root/clawd/memory/verifier-log-$(date +%Y-%m-%d).md"
VERIFIER_STOP_FLAG="/root/clawd/memory/verifier-stop.flag"
EXA_SCRIPTS="/root/clawd/skills/exa-plus/scripts"

# Input/Output arguments
CLAIM_FILE=""
OUTPUT_FILE=""
INTERACTIVE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --claim)
            CLAIM_FILE="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check stop flag
if [ -f "$VERIFIER_STOP_FLAG" ]; then
    echo "Verifier agent stopped (flag detected)"
    exit 0
fi

# Initialize state
if [ ! -f "$VERIFIER_STATE" ]; then
    cat > "$VERIFIER_STATE" << 'EOF'
{
  "verifications": [],
  "stats": {
    "total_verifications": 0,
    "average_score": 0,
    "approved_claims": 0,
    "rejected_claims": 0,
    "warnings_issued": 0
  }
}
EOF
fi

# Log header
log_header() {
    local ts=$(date -Iseconds)
    cat >> "$VERIFIER_LOG" << LOGEOF
---

## Verification Report: $ts
LOGEOF
}

# Check URL
check_url() {
    local url="$1"
    curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null || echo "000"
}

# Extract numbers
extract_numbers() {
    local text="$1"
    echo "$text" | grep -oE '[0-9]+(\.[0-9]+)?%?|[0-9]{4}' | sort -u
}

# Validate date
validate_date() {
    local date_str="$1"
    date -d "$date_str" &>/dev/null
}

# Recency score
recency_score() {
    local date_str="$1"
    local source_date=$(date -d "$date_str" +%s 2>/dev/null || echo 0)
    local now=$(date +%s)
    local diff_days=$(( (now - source_date) / 86400 ))

    if [ $diff_days -le 30 ]; then
        echo 100
    elif [ $diff_days -le 90 ]; then
        echo 85
    elif [ $diff_days -le 180 ]; then
        echo 70
    elif [ $diff_days -le 365 ]; then
        echo 55
    else
        echo 40
    fi
}

# Verify data
verify_data() {
    local claim_json="$1"
    local score=100
    local issues=()

    local claim_text=$(echo "$claim_json" | jq -r '.claim // empty')
    local claim_numbers=$(extract_numbers "$claim_text")

    local evidence_count=$(echo "$claim_json" | jq '.evidence | length')
    local evidence_numbers=""
    for ((i=0; i<evidence_count; i++)); do
        local ev_text=$(echo "$claim_json" | jq -r ".evidence[$i].claim // empty")
        evidence_numbers+=$(extract_numbers "$ev_text")
    done

    # Check numbers in claim
    if [ -n "$claim_numbers" ]; then
        for num in $claim_numbers; do
            if ! echo "$evidence_numbers" | grep -q "$num"; then
                score=$((score - 15))
                issues+=("Number '$num' not found in evidence")
            fi
        done
    fi

    # Check dates
    local dates=$(echo "$claim_text" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9}{2}')
    for date in $dates; do
        if ! validate_date "$date"; then
            score=$((score - 20))
            issues+=("Invalid date: $date")
        fi
    done

    # Check confidence
    local confidence=$(echo "$claim_json" | jq -r '.confidence // empty')
    if [[ "$confidence" =~ ^[0-9]+%$ ]]; then
        local conf_val="${confidence%\%}"
        if [ "$conf_val" -gt 95 ]; then
            score=$((score - 10))
            issues+=("Confidence >95% needs exceptional evidence")
        elif [ "$conf_val" -lt 50 ]; then
            score=$((score - 5))
            issues+=("Confidence <50% is weak")
        fi
    fi

    jq -n --argjson p "$([ "$score" -ge 70 ] && echo true || echo false)" --argjson s "$score" --argjson i "$(printf '%s\n' "${issues[@]}" | jq -R -s -c 'split("\n") | map(select(length > 0))')" '{passed: $p, score: $s, issues: $i}'
}

# Verify citations
verify_citations() {
    local claim_json="$1"
    local score=100
    local issues=()
    local evidence_count=$(echo "$claim_json" | jq '.evidence | length')

    if [ "$evidence_count" -eq 0 ]; then
        score=0
        issues+=("No citations provided")
    else
        for ((i=0; i<evidence_count; i++)); do
            local url=$(echo "$claim_json" | jq -r ".evidence[$i].url // empty")
            local source=$(echo "$claim_json" | jq -r ".evidence[$i].source // empty")

            if [ -z "$url" ]; then
                score=$((score - 25))
                issues+=("Evidence #$((i+1)): No URL")
            else
                local http_status=$(check_url "$url")
                if [ "$http_status" != "200" ]; then
                    score=$((score - 30))
                    issues+=("Evidence #$((i+1)): URL returned $http_status")
                fi
            fi

            if [ -z "$source" ]; then
                score=$((score - 10))
                issues+=("Evidence #$((i+1)): No source")
            fi
        done
    fi

    jq -n --argjson p "$([ "$score" -ge 70 ] && echo true || echo false)" --argjson s "$score" --argjson i "$(printf '%s\n' "${issues[@]}" | jq -R -s -c 'split("\n") | map(select(length > 0))')" '{passed: $p, score: $s, issues: $i}'
}

# Verify relevance
verify_relevance() {
    local claim_json="$1"
    local score=100
    local issues=()

    local evidence_count=$(echo "$claim_json" | jq '.evidence | length')
    local recency_scores=(85 85 85)

    local avg_recency=$(printf '%d\n' "${recency_scores[@]}" | awk '{s+=$1} END {print s/NR}')
    score=$((score + (avg_recency - 100)))

    # Keyword overlap
    local claim_title=$(echo "$claim_json" | jq -r '.title // ""' | tr '[:upper:]' '[:lower:]')
    local claim_prediction=$(echo "$claim_json" | jq -r '.prediction // ""' | tr '[:upper:]' '[:lower:]')

    local relevant_evidence=0
    for ((i=0; i<evidence_count; i++)); do
        local ev_claim=$(echo "$claim_json" | jq -r ".evidence[$i].claim // """ | tr '[:upper:]' '[:lower:]")

        local overlap=0
        local claim_words=$(echo "$claim_title $claim_prediction" | grep -oE '[a-z]{3,}' | sort -u)
        for word in $claim_words; do
            if echo "$ev_claim" | grep -q "$word"; then
                overlap=$((overlap + 1))
            fi
        done

        if [ "$overlap" -ge 2 ]; then
            relevant_evidence=$((relevant_evidence + 1))
        fi
    done

    if [ "$evidence_count" -gt 0 ]; then
        local relevance_ratio=$((relevant_evidence * 100 / evidence_count))
        if [ "$relevance_ratio" -lt 70 ]; then
            score=$((score - 20))
            issues+=("Only $relevant_evidence/$evidence_count evidence relevant")
        fi
    fi

    jq -n --argjson p "$([ "$score" -ge 70 ] && echo true || echo false)" --argjson s "$score" --argjson i "$(printf '%s\n' "${issues[@]}" | jq -R -s -c 'split("\n") | map(select(length > 0))')" '{passed: $p, score: $s, issues: $i}'
}

# Verify contradictions
verify_contradictions() {
    local claim_json="$1"
    local score=100
    local issues=()

    local confidence=$(echo "$claim_json" | jq -r '.confidence // "0%"')
    local conf_val="${confidence%\%}"
    local timeline=$(echo "$claim_json" | jq -r '.timeline // ""')

    if [[ "$timeline" =~ (year|24|18|12) ]] && [ "$conf_val" -gt 85 ]; then
        score=$((score - 15))
        issues+=("High confidence with long timeline")
    fi

    if [[ "$timeline" =~ (month|3|6) ]] && [ "$conf_val" -lt 60 ]; then
        score=$((score - 10))
        issues+=("Low confidence with short timeline")
    fi

    local claim_text=$(echo "$claim_json" | jq -r '.claim // ""')
    if [[ "$claim_text" =~ (before [0-9]{4}|past [0-9]{4}) ]]; then
        local past_year=$(echo "$claim_text" | grep -oE '[0-9]{4}')
        local current_year=$(date +%Y)
        if [ "$past_year" -lt "$current_year" ]; then
            score=$((score - 25))
            issues+=("Past date in future prediction")
        fi
    fi

    jq -n --argjson p "$([ "$score" -ge 70 ] && echo true || echo false)" --argjson s "$score" --argjson i "$(printf '%s\n' "${issues[@]}" | jq -R -s -c 'split("\n") | map(select(length > 0))')" '{passed: $p, score: $s, issues: $i}'
}

# Main verification function
verify_claim() {
    local claim_json="$1"
    local start_time=$(date +%s)

    log_header

    # Run all checks
    local data_result=$(verify_data "$claim_json")
    local citation_result=$(verify_citations "$claim_json")
    local relevance_result=$(verify_relevance "$claim_json")
    local contradiction_result=$(verify_contradictions "$claim_json")

    # Calculate overall score
    local data_score=$(echo "$data_result" | jq '.score')
    local citation_score=$(echo "$citation_result" | jq '.score')
    local relevance_score=$(echo "$relevance_result" | jq '.score')
    local contradiction_score=$(echo "$contradiction_result" | jq '.score')

    local overall_score=$(((data_score * 30 + citation_score * 30 + relevance_score * 20 + contradiction_score * 20) / 100))

    local status="rejected"
    [ "$overall_score" -ge 90 ] && status="ready"
    [ "$overall_score" -ge 70 ] && [ "$overall_score" -lt 90 ] && status="needs_review"

    # Build report
    local report=$(jq -n \
        --argjson s "$overall_score" \
        --arg st "$status" \
        --argjson dv "$data_result" \
        --argjson cv "$citation_result" \
        --argjson rc "$relevance_result" \
        --argjson cd "$contradiction_result" \
        '{overall_score: $s, status: $st, checks: {data_validation: {passed: $dv.passed, issues: $dv.issues}, citation_verification: {passed: $cv.passed, issues: $cv.issues}, relevance_check: {passed: $rc.passed, issues: $rc.issues}, contradiction_detection: {passed: $cd.passed, issues: $cd.issues}}')

    local end_time=$(date +%s)
    local time_taken=$((end_time - start_time))

    # Log
    echo "### Overall Score: $overall_score/100 ($status)" >> "$VERIFIER_LOG"
    echo "**Time taken:** ${time_taken}s" >> "$VERIFIER_LOG"
    echo "" >> "$VERIFIER_LOG"

    local data_passed=$(echo "$data_result" | jq -r '.passed')
    local data_icon="❌"
    [ "$data_passed" = "true" ] && data_icon="✅"
    echo "**Data Validation:** $data_icon" >> "$VERIFIER_LOG"
    echo "$data_result" | jq -r '.issues[]? // empty' | sed 's/^/- /' >> "$VERIFIER_LOG"
    echo "" >> "$VERIFIER_LOG"

    local citation_passed=$(echo "$citation_result" | jq -r '.passed')
    local citation_icon="❌"
    [ "$citation_passed" = "true" ] && citation_icon="✅"
    echo "**Citation Verification:** $citation_icon" >> "$VERIFIER_LOG"
    echo "$citation_result" | jq -r '.issues[]? // empty' | sed 's/^/- /' >> "$VERIFIER_LOG"
    echo "" >> "$VERIFIER_LOG"

    local relevance_passed=$(echo "$relevance_result" | jq -r '.passed')
    local relevance_icon="❌"
    [ "$relevance_passed" = "true" ] && relevance_icon="✅"
    echo "**Relevance Check:** $relevance_icon" >> "$VERIFIER_LOG"
    echo "$relevance_result" | jq -r '.issues[]? // empty' | sed 's/^/- /' >> "$VERIFIER_LOG"
    echo "" >> "$VERIFIER_LOG"

    local contradiction_passed=$(echo "$contradiction_result" | jq -r '.passed')
    local contradiction_icon="❌"
    [ "$contradiction_passed" = "true" ] && contradiction_icon="✅"
    echo "**Contradiction Detection:** $contradiction_icon" >> "$VERIFIER_LOG"
    echo "$contradiction_result" | jq -r '.issues[]? // empty' | sed 's/^/- /' >> "$VERIFIER_LOG"
    echo "" >> "$VERIFIER_LOG"

    # Update state
    local timestamp=$(date -Iseconds)
    local claim_id=$(echo "$claim_json" | jq -r '.title // "unknown" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | head -c20)

    local dp=$(echo "$data_result" | jq '.passed')
    local cp=$(echo "$citation_result" | jq '.passed')
    local rp=$(echo "$relevance_result" | jq '.passed')
    local ccp=$(echo "$contradiction_result" | jq '.passed')

    local new_verifications
    new_verifications=$(jq -n --arg ts "$timestamp" --arg cid "$claim_id-$RANDOM" --argjson s "$overall_score" --arg st "$status" --argjson dp "$dp" --argjson cp "$cp" --argjson rp "$rp" --argjson ccp "$ccp" --argjson t "$time_taken" '{timestamp: $ts, claim_id: $cid, score: $s, status: $st, checks: {data_validation: $dp, citation_verification: $cp, relevance_check: $rp, contradiction_detection: $ccp}, time_taken_seconds: $t}')

    local approved_delta=0
    local rejected_delta=0
    [ "$status" = "ready" ] && approved_delta=1 || rejected_delta=1

    local updated_state
    updated_state=$(jq --argjson nv "$new_verifications" --argjson ad "$approved_delta" --argjson rd "$rejected_delta" '.verifications += [$nv] | .stats.total_verifications += 1 | .stats.approved_claims += $ad | .stats.rejected_claims += $rd' "$VERIFIER_STATE")

    local total_verif=$(echo "$updated_state" | jq '.stats.total_verifications')
    local old_avg=$(echo "$updated_state" | jq '.stats.average_score')
    local new_score="$overall_score"
    local new_avg=$(( (old_avg * (total_verif - 1) + new_score) / total_verif ))

    updated_state=$(jq --argjson na "$new_avg" '.stats.average_score = $na' <<< "$updated_state")

    echo "$updated_state" > "$VERIFIER_STATE"

    echo "$report"
}

# Interactive mode
interactive_mode() {
    echo "=== Claim Verifier Agent - Interactive Mode ==="
    echo ""
    echo "Paste your claim as JSON, or press Ctrl+D to exit."
    echo ""

    local input=""
    while IFS= read -r line; do
        input+="$line"$'\n'
    done

    [ -z "$input" ] && echo "No input provided." && exit 1

    if ! echo "$input" | jq empty 2>/dev/null; then
        echo "Invalid JSON."
        exit 1
    fi

    local report=$(verify_claim "$input")
    echo ""
    echo "--- VERIFICATION REPORT ---"
    echo "$report" | jq -C .
    echo ""
    echo "Detailed log: $VERIFIER_LOG"
}

# Main execution
main() {
    local start_time=$(date)

    if [ "$INTERACTIVE" = true ]; then
        interactive_mode
    elif [ -n "$CLAIM_FILE" ]; then
        [ ! -f "$CLAIM_FILE" ] && echo "Claim file not found: $CLAIM_FILE" && exit 1

        local claim_json=$(cat "$CLAIM_FILE")
        local report=$(verify_claim "$claim_json")

        if [ -n "$OUTPUT_FILE" ]; then
            echo "$report" | jq '.' > "$OUTPUT_FILE"
            echo "Verification report saved to: $OUTPUT_FILE"
        else
            echo "$report" | jq -C .
        fi

        echo ""
        echo "Detailed log: $VERIFIER_LOG"
    else
        echo "Usage: $0 --claim <file> --output <file> | --interactive"
        exit 1
    fi

    local duration=$(( $(date +%s) - $(date -d "$start_time" +%s) ))
    echo "Verifier completed in: ${duration}s"
}

main "$@"
