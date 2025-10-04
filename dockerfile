# Use Kali Linux rolling as base for pentesting tools
FROM kalilinux/kali-rolling

# Update and install base dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    git curl wget python3 python3-pip golang-go \
    nmap masscan naabu rustscan \
    gobuster feroxbuster dirsearch \
    wfuzz ffuf \
    sqlmap nosqlmap \
    commix corsy crlfsuite \
    thc-hydra gitleaks subjack nuclei \
    whatweb webanalyze \
    eyewitness aquatone gowitness \
    arjun && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Go-based tools
RUN go install github.com/projectdiscovery/subfinder/v2@latest && \
    go install github.com/projectdiscovery/assetfinder@latest && \
    go install github.com/hahwul/dalfox/v2@latest && \  # Assuming dalfox for XSS if needed
    go install github.com/tomnomnom/assetfinder@latest && \
    mv /root/go/bin/* /usr/local/bin/

# Install Python-based tools
RUN pip3 install --no-cache-dir \
    sublist3r findomain sudomy \
    wappalyzer-cli xsstrike xssor2 \
    linkfinder js-scan paramspider \
    ground-control dtd-finder

# Clone and install other git repos
RUN git clone https://github.com/aboul3la/Sublist3r.git /opt/Sublist3r && \
    cd /opt/Sublist3r && pip3 install -r requirements.txt && \
    ln -s /opt/Sublist3r/sublist3r.py /usr/local/bin/sublist3r && \
    git clone https://github.com/OWASP/Amass.git /opt/Amass && \
    cd /opt/Amass && go install ./... && \
    mv /root/go/bin/amass /usr/local/bin/ && \
    git clone https://github.com/drwetter/testssl.sh.git /opt/testssl && \
    ln -s /opt/testssl/testssl.sh /usr/local/bin/testssl && \
    git clone https://github.com/danielmiessler/SecLists.git /opt/SecLists

# Set working dir and entrypoint
WORKDIR /workspace
COPY pipeline.sh /usr/local/bin/pipeline.sh
RUN chmod +x /usr/local/bin/pipeline.sh

# Entry point: Run the script with args
ENTRYPOINT ["/usr/local/bin/pipeline.sh"]
CMD ["--help"]
