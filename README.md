ProxyHarvester: The Ultimate SOCKS5 Proxy Scraper & Tester

Features:

1- Scrapes SOCKS5 proxies from multiple sources.
2- Deduplicates proxies to ensure a clean list.
3- Tests proxies against a specified target URL.
4- Customizable connection timeout and target URL settings.

Quick Start Guide: 

1- Clone the repository:

    git clone https://github.com/omersayak/ProxyHarvester.git
    
2- Navigate into the cloned directory:
    
    cd ProxyHarvester

3- Make the script executable:

    chmod +x proxyharvester.sh

4- Run the script:
  - To run with default settings:

        ./proxyharvester.sh
  - To specify a timeout and target URL:

        ./proxyharvester.sh --timeout 5 --target http://example.com


Usage:

    ./proxyharvester.sh [options]
    Options:
      --timeout <seconds>    Set the connection timeout for testing proxies.
      --target <URL>         Set the target URL to test the proxies against.
      -h, --help             Show this help message and exit.


Enjoy your freshly harvested and tested SOCKS5 proxies with ProxyHarvester!
