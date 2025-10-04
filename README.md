# Bug Automation Tool

An advanced Docker-based automation pipeline for bug bounty hunting and penetration testing. Covers recon (subdomain enum, port scanning) to exploitation (SQLi, XSS, etc.) using tools like Subfinder, Nuclei, SQLMap.

## Features
- **Recon**: Subdomain enumeration (Sublist3r, Amass, Subfinder).
- **Port Scanning**: Nmap, Masscan, RustScan.
- **Screenshots**: EyeWitness, Gowitness, Aquatone.
- **Tech Detection**: WhatWeb, Wappalyzer.
- **Content Discovery**: Gobuster, FFUF, Dirsearch.
- **Vuln Scanning**: Nuclei, SQLMap, XSStrike.
- **Exploitation**: Commix, Corsy, THC-Hydra (detection only).

## Quick Start
1. Clone: `git clone https://github.com/ajimulxyz/bug-automation`
2. Build: `docker build -t bug-automation .`
3. Run: `docker run -v $(pwd)/results:/workspace/results bug-automation -d example.com -o results`

## Disclaimer
Use only for authorized testing. Unauthorized use may violate laws (e.g., CFAA).

## License
MIT License - see [LICENSE](LICENSE) file.

## Contributing
Pull requests welcome! Open issues for bugs/features.

## Releases
- [v1.0 (Upcoming)](https://github.com/ajimulxyz/bug-automation/releases) - Initial stable release.
