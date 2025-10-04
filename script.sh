#!/bin/bash

# Disclaimer and help
if [ "$1" == "--help" ]; then
    echo "Usage: pipeline.sh -d <domain> -o <output_dir>"
    echo "Example: pipeline.sh -d example.com -o results"
    echo "Phases: Subdomain enum -> Port scan -> Screenshots -> Tech detect -> Content discovery -> Param discovery -> Fuzzing -> Vuln scan -> Exploitation attempts"
    exit 0
fi

# Parse args
while getopts d:o: opt; do
    case $opt in
        d) DOMAIN="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        *) echo "Invalid option"; exit 1 ;;
    esac
done

[ -z "$DOMAIN" ] && { echo "Domain required!"; exit 1; }
mkdir -p "$OUTPUT_DIR"
echo "[+] Starting pipeline for $DOMAIN. Output: $OUTPUT_DIR"
echo "[+] Date: $(date)" > "$OUTPUT_DIR/summary.txt"

# Phase 1: Subdomain Enumeration
subdomain_enum() {
    echo "[+] Subdomain Enumeration..."
    sublist3r -d "$DOMAIN" -o "$OUTPUT_DIR/sublist3r.txt" &
    amass enum -d "$DOMAIN" -o "$OUTPUT_DIR/amass.txt" &
    subfinder -d "$DOMAIN" -o "$OUTPUT_DIR/subfinder.txt" &
    assetfinder --subs-only "$DOMAIN" > "$OUTPUT_DIR/assetfinder.txt" &
    findomain -t "$DOMAIN" -u "$OUTPUT_DIR/findomain.txt" &
    sudomy -d "$DOMAIN" -o "$OUTPUT_DIR/sudomy" &
    massdns -r /opt/SecLists/Discovery/DNS/resolvers.txt -s 1000 -t A -o S -w "$OUTPUT_DIR/massdns.txt" <(cat /opt/SecLists/Discovery/DNS/subdomains-top1million-5000.txt | sed "s/$/$DOMAIN/g") &
    wait
    cat "$OUTPUT_DIR/"{sublist3r,amass,subfinder,assetfinder,findomain}.txt "$OUTPUT_DIR/sudomy/subdomains.txt" | sort -u > "$OUTPUT_DIR/subdomains.txt"
    echo "Unique subdomains: $(wc -l < "$OUTPUT_DIR/subdomains.txt")" >> "$OUTPUT_DIR/summary.txt"
}

# Phase 2: Port Scanning
port_scan() {
    echo "[+] Port Scanning on subdomains..."
    while read -r sub; do
        masscan -p1-65535 "$sub" --rate=1000 -oL "$OUTPUT_DIR/ports_masscan_$sub.txt" &
        nmap -sV -oN "$OUTPUT_DIR/ports_nmap_$sub.txt" "$sub" &
        naabu -host "$sub" -o "$OUTPUT_DIR/ports_naabu_$sub.txt" &
        rustscan -a "$sub" --ulimit 5000 > "$OUTPUT_DIR/ports_rustscan_$sub.txt" &
    done < "$OUTPUT_DIR/subdomains.txt"
    wait
}

# Phase 3: Screenshots
screenshots() {
    echo "[+] Taking Screenshots..."
    eyewitness --web -f "$OUTPUT_DIR/subdomains.txt" -d "$OUTPUT_DIR/eyewitness" &
    gowitness file -f "$OUTPUT_DIR/subdomains.txt" -P "$OUTPUT_DIR/gowitness" &
    aquatone -ports medium -out "$OUTPUT_DIR/aquatone" < "$OUTPUT_DIR/subdomains.txt" &
    wait
}

# Phase 4: Technology Detection
tech_detect() {
    echo "[+] Technology Detection..."
    while read -r sub; do
        whatweb "https://$sub" > "$OUTPUT_DIR/tech_whatweb_$sub.txt" &
        webanalyze -host "https://$sub" -crawl 1 > "$OUTPUT_DIR/tech_webanalyze_$sub.txt" &
        wappalyzer "https://$sub" > "$OUTPUT_DIR/tech_wappalyzer_$sub.txt" &
    done < "$OUTPUT_DIR/subdomains.txt"
    wait
}

# Phase 5: Content Discovery
content_discovery() {
    echo "[+] Content Discovery..."
    while read -r sub; do
        gobuster dir -u "https://$sub" -w /opt/SecLists/Discovery/Web-Content/common.txt -o "$OUTPUT_DIR/content_gobuster_$sub.txt" &
        feroxbuster -u "https://$sub" -w /opt/SecLists/Discovery/Web-Content/raft-medium-directories.txt -o "$OUTPUT_DIR/content_ferox_$sub.txt" &
        dirsearch -u "https://$sub" -o "$OUTPUT_DIR/content_dirsearch_$sub.txt" &
    done < "$OUTPUT_DIR/subdomains.txt"
    wait
}

# Phase 6: Links and Parameters Discovery
param_discovery() {
    echo "[+] Params and Links Discovery..."
    while read -r sub; do
        URL="https://$sub"
        paramspider -d "$sub" -o "$OUTPUT_DIR/params_paramspider_$sub.txt" &
        arjun -u "$URL" -oT "$OUTPUT_DIR/params_arjun_$sub.txt" &
        linkfinder -i "$URL" -o cli > "$OUTPUT_DIR/links_linkfinder_$sub.txt" &
        js-scan "$URL" > "$OUTPUT_DIR/js_js-scan_$sub.txt" &
    done < "$OUTPUT_DIR/subdomains.txt"
    wait
}

# Phase 7: Fuzzing
fuzzing() {
    echo "[+] Fuzzing..."
    while read -r sub; do
        URL="https://$sub"
        wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/quickhits.txt --hc 404 "$URL/FUZZ" > "$OUTPUT_DIR/fuzz_wfuzz_$sub.txt" &
        ffuf -u "$URL/FUZZ" -w /opt/SecLists/Discovery/Web-Content/raft-small-words.txt -o "$OUTPUT_DIR/fuzz_ffuf_$sub.txt" &
    done < "$OUTPUT_DIR/subdomains.txt"
    wait
}

# Phase 8: Vulnerability Scanning and Exploitation
vuln_scan() {
    echo "[+] Vulnerability Scanning..."
    nuclei -l "$OUTPUT_DIR/subdomains.txt" -severity low,medium,high,critical -o "$OUTPUT_DIR/nuclei.txt" &
    subjack -w "$OUTPUT_DIR/subdomains.txt" -o "$OUTPUT_DIR/subjack.txt" &
    gitleaks detect --source="$OUTPUT_DIR" -v > "$OUTPUT_DIR/gitleaks.txt" &
    
    # Injection scans (low risk)
    while read -r sub; do
        URL="https://$sub"
        sqlmap -u "$URL" --batch --level=1 --risk=1 -o -f "$OUTPUT_DIR/sqlmap_$sub" &
        nosqlmap --url "$URL" --batch > "$OUTPUT_DIR/nosqlmap_$sub.txt" &
        xsstrike -u "$URL" --crawl -l 2 > "$OUTPUT_DIR/xsstrike_$sub.txt" &
        xssor2 "$URL" > "$OUTPUT_DIR/xssor2_$sub.txt" &
        ground-control -u "$URL" > "$OUTPUT_DIR/xxe_ground_$sub.txt" &
        dtd-finder "$URL" > "$OUTPUT_DIR/xxe_dtd_$sub.txt" &
        
        # Exploitation attempts (detect only)
        commix -u "$URL" --batch --level=1 > "$OUTPUT_DIR/commix_$sub.txt" &
        corsy -u "$URL" > "$OUTPUT_DIR/corsy_$sub.txt" &
        crlfsuite -u "$URL" > "$OUTPUT_DIR/crlf_$sub.txt" &
        thc-hydra -L /opt/SecLists/Usernames/top-usernames-shortlist.txt -P /opt/SecLists/Passwords/darkweb2017-top100.txt "$sub" http-get-form "/login:username=^USER^&password=^PASS^:F=incorrect" -o "$OUTPUT_DIR/hydra_$sub.txt" &  # Example path, customize
    done < "$OUTPUT_DIR/subdomains.txt"
    wait
}

# Run all phases
subdomain_enum
port_scan
screenshots
tech_detect
content_discovery
param_discovery
fuzzing
vuln_scan

echo "[+] Pipeline completed! Check $OUTPUT_DIR/summary.txt and logs." >> "$OUTPUT_DIR/summary.txt"
