# bug-automation
this repo for automation bug hounting 
# Bug Automation Tool

An advanced Docker-based automation pipeline for bug bounty hunting and penetration testing. Covers recon (subdomain enum, port scanning) to exploitation (SQLi, XSS, etc.) using tools like Subfinder, Nuclei, SQLMap.

## Features
- Subdomain enumeration (Sublist3r, Amass, Subfinder).
- Port scanning (Nmap, Masscan, RustScan).
- Screenshots & Tech detection (EyeWitness, WhatWeb).
- Content discovery & fuzzing (Gobuster, FFUF).
- Vuln scanning (Nuclei, SQLMap, XSStrike).
- Basic exploitation attempts (Commix, Hydra).

## Quick Start
1. Clone: `git clone https://github.com/ajimulxyz/bug-automation`
2. Build: `docker build -t bug-automation .`
3. Run: `docker run -v $(pwd)/results:/workspace/results bug-automation -d example.com -o results`

## Disclaimer
Use only for authorized testing. Unauthorized use may violate laws.

## License
MIT License - see LICENSE file.

## Contributing
Pull requests welcome! Fork and submit PRs.
