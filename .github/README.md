<h1 align="center">AdGuard-Tui</h1>
<p align="center">
	<i>Terminal-based, real-time traffic monitoring and statistics for your AdGuard Home instance</i>
</p>
<p align="center">
  <img width="200" src="https://i.ibb.co/25GNT0n/adguard-tui-banner-4.png" />
</p>

## About

AdGuardian Tui - Keep an eye on your traffic, with this (unofficial) buddy for your AdGuard Home instance

<p align="center">
<img width="600" src="https://i.ibb.co/Nrtd01d/adguardian-demo.gif?" >
</p>

Features:
- **Real-time Query Monitoring**: _Fetches and displays all DNS queries in real time, letting you see exactly what's happening on your network at any given moment_
- **Block and Allow Stats**: _Get a quick overview of the number of queries that have been allowed, filtered or blocked by AdGuard_
- **Historical Query Counts**: _Analyze network activity over time with historical query count data. This lets you track trends and spot any unusual activity_
- **Filter Lists**: _AdGuardian displays your active filter lists, showing which ones are doing the most work_
- **Top Domain Statistics**: _See which domains are getting the most queries (blocked, allowed and otherwise) in your network_
- **Easy and Lightweight**: _AdGuardian can be run either with a super tiny Docker image, or directly with the zero-dependency executable_
- **Good and Safe**: _Written in Rust and unit tested, the app runs locally with no external requests, and (of course) it's fully open source_

About AdGuard:

[AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) is a free and open source self-hosted (or managed) network-wide ad + tracker blocker. It operates as a DNS server that re-routes tracking domains to a "black hole", thus preventing your devices from connecting to those servers. It makes your internet, faster, safer and gives you a bunch of useful features, like encrypted DNS (DoH, DoT, DNSCrypt), parental controls, blocking of malware / phishing, per-device configs, custom DNS rules, etc.

<details>
<summary><b>Contents</b></summary>

- [About](#about)
- [Getting Started](#getting-started)
	- [Docker](#docker)
	- [Executable](#executable)
	- [Install from Crates.io](#install-from-cratesio)
	- [Build from Source](#build-from-source)
	- [One-Liner](#one-liner)
- [Configuring](#configuring)
		- [With Flags](#with-flags)
		- [With Env Vars](#with-env-vars)
		- [In Docker](#in-docker)
- [Web Mode](#web-mode)
- [Development](#development)
	- [Prerequisites](#prerequisites)
	- [Run](#run)
	- [Technical Docs](#technical-docs)
	- [Testing and Quality](#testing-and-quality)
	- [Building](#building)
	- [CI / CD](#ci--cd)
- [Credits](#credits)
	- [Sponsors](#sponsors)
	- [Dependencies](#dependencies)
- [Mirror](#mirror)
- [Contributing](#contributing)
		- [New here?](#new-here)
		- [Not a coder?](#not-a-coder)
- [License](#license)
	
</details>

---

## Getting Started

There are several options for running...

### Docker

```bash
docker run -it obaraelijah/adguard-tui
```

> You may also pass in your AdGuard info with env vars (using `-e`), see the [Configuring](#configuring) section for an example, and list of availible config params.<br>
> If you experience issues with DockerHub, or would rather use a different registry, the image is also available via GHCR - just replace the image name with: `ghcr.io/obaraelijah/adguard-tui`. Alternatively, if you'd like to build it yourself from source, you can do so with `docker buildx build -t  adguard-tui .` then run it with `docker run -it adguard-tui`.

### Executable

```bash
curl -o adguard-tui https://github.com/obaraelijah/adguard-tui/releases/latest/download/download/1.0.0/adguard-tui-linux && \
chmod +x adguard-tui && \
./adguard-tui
```

> In the above example, don't forget to update the URL to download the latest stable version for your operating system<br>
> You may also just head over the the [Releases](https://github.com/obaraelijah/adguard-tui/releases) tab, download the latest executable, and double-click on it to run

### Install from Crates.io

```
cargo install adguard-tui
adguard-tui
```

> adguard-tui is published as a crate to [crates.io/crates/adguard-tui](https://crates.io/crates/adguard-tui). So providing you've got Cargo installed, you can pull the binary directly, and then execute it as above. Again, see the [Configuring](#configuring) section below for how to pass in your AdGuard info.
> 
### Build from Source

```bash
git clone git@github.com:obaraelijah/adguard-tui.git && \
cd adguard-tui && \
make
```

> You'll need `git`, `cargo` and `make` (see [here](#development) for installation notes). You can also run the cargo commands defined in the Makefile directly, e.g. `cargo run`

### One-Liner

```bash
bash <(curl -sL https://raw.githubusercontent.com/obaraelijah/adguard-tui/main/quick-start.sh)
```

> This will run the [quick-start.sh](https://github.com/obaraelijah/adguard-tui/blob/main/quick-start.sh) Bash script, which downloads and executes the latest binary for your system type. Be sure to read and understand the file first

<details>

<summary><h4>Not sure which method to choose?</h4></summary>

- Docker is the easiest but needs to be installed, and adds a bit of overhead (12Mb, to be precise)
- Where as using the executable won't require any additional dependencies
- If you've got Rust installed, fetching from crates.io will also be both easy and performant
- If your system architecture isn't supported you'll need to build from source, as you also will if you wish to run a fork or make amendments to the code

</details>

---

## Configuring

The app requires the details of an AdGuard instance to connect to.
This info can be provided either as environmental variables, or passed in as flag parameters.
If any of these fields are missing or incomplete, you'll be prompted to enter a value once the app starts.

The following params are accepted:


- `ADGUARD_IP` / `--adguard-ip` - The IP address of your local AdGuard Home instance
- `ADGUARD_PORT` / `--adguard-port` - The port that AdGuard is running on
- `ADGUARD_USERNAME` / `--adguard-username` - An AdGuard Home username
- `ADGUARD_PASSWORD` / `--adguard-password` - An AdGuard Home password

There's also some additional optional environment variables that you may set:

- `ADGUARD_PROTOCOL` - The protocol to use when connecting to AdGuard (defaults to `http`)
- `ADGUARD_UPDATE_INTERVAL` - The rate at which to refresh the UI in seconds (defaults to `2`)

<details>
<summary>Examples</summary>

#### With Flags
	
```bash
adguard-tui -- \
	--adguard-ip "192.168.180.1" \
	--adguard-port "3000" \
	--adguard-username "admin" \
	--adguard-password "bobs-your-uncle"
```
	
#### With Env Vars
	
```bash
ADGUARD_IP="192.168.180.1" ADGUARD_PORT="3000" ADGUARD_USERNAME="admin" ADGUARD_PASSWORD="bobs-your-uncle" adguard-tui
```
	
#### In Docker
	
```bash
docker run \
	-e "ADGUARD_IP=192.168.180.1" \
	-e "ADGUARD_PORT=3000" \
	-e "ADGUARD_USERNAME=admin" \
	-e "ADGUARD_PASSWORD=bobs-your-uncle" \
	-it obaraelijah/adguard-tui
```
	
</details>

---

## Web Mode

The terminal dashboard can also be viewed via a browser, thanks to [ttyd](https://github.com/tsl0922/ttyd).

AdGuardian is fully compatible with ttyd, so once you've [installed](https://github.com/tsl0922/ttyd#installation) it, you can just precede your run command with ttyd.
E.g. `ttyd docker run -it obarelijah/adguardian` or `ttyd adguardian`

<p align="center">
<img width="500" src="https://i.ibb.co/YNYq3xv/adguardian-browser.png">
</p>

Another great option is [gotty](https://github.com/yudai/gotty), which works in a similar way. Note that if you want to allow user input, you'll need to pass the `-w` option.

You can also combine this with a service like [ngrok](https://ngrok.com/) to forward the port, and access the dashboard from anywhere. But be careful to apply the correct access controls!

---

## Development

### Prerequisites

You'll need Rust installed. Run: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh` - see the [installation docs](https://forge.rust-lang.org/infra/other-installation-methods.html). You'll also need [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), if you don't already have it.

Then clone the repo, and cd into it, with: `git clone git@github.com:obaraelijah/adguard-tui.git` && `cd adguard-tui`

You can view the full list of availible project commands in the [Makefile](https://github.com/obaraelijah/adguard-tui-Term/blob/main/Makefile)

### Run

To build and run the project for development, run `cargo run`

### Technical Docs

The documentation can be viewed at: 

### Testing and Quality

- `cargo test` - Run unit tests
- `cargo check` - Ensure app is compilable
- `cargo bench` - Execute benchmarks
- `cargo clippy` - Analyse areas for improvement
- `cargo doc` - Generate the documentation

### Building

Once your finished developing, you can build the project for production with: `cargo build --release`
The binaries for your system will then be available in the `./target/release/` directory of the project.
You can execute this directly, e.g. by running `./target/release/adguard-tui` (add .exe if on Windows)

### CI / CD

The testing, building, and publishing of the app is done with GitHub Actions.

<details>
<summary>View Current Workflow Status</summary>

- Build Docker image and push to registry
  - [![Build Docker Image 🐳](https://github.com/obaraelijah/adguard-tui/actions/workflows/build-docker.yml/badge.svg)](https://github.com/obaraelijah/adguard-tui/actions/workflows/build-docker.yml)
- Compile binaries and upload artifacts to release
  - [![Compile Release 🚀](https://github.com/obaraelijah/adguard-tui/actions/workflows/release-binaries.yml/badge.svg)](https://github.com/obaraelijah/adguard-tui/actions/workflows/release-binaries.yml)
- Publish compiled app to crates.io
  - [![Publish to Crates.io 📦](https://github.com/obaraelijah/adguard-tui/actions/workflows/push-cargo.yml/badge.svg)](https://github.com/obaraelijah/adguard-tui/actions/workflows/push-cargo.yml)
- Generate documentation from Rustdoc, upload to GH pages
  - [![Generate Rust Docs 📝](https://github.com/obaraelijah/adguard-tui/actions/workflows/publish-docs.yml/badge.svg)](https://github.com/obaraelijah/adguard-tui/actions/workflows/publish-docs.yml)
- Insert list of contributors + sponsors into readme
  - [![Insert Contributors 👥](https://github.com/obaraelijah/adguard-tui/actions/workflows/insert-contributors.yml/badge.svg)](https://github.com/obaraelijah/adguard-tui/actions/workflows/insert-contributors.yml)

</details>

---

## Credits

### Sponsors

### Dependencies

This project was made possible by the maintainers of the following dependencies
- [anyhow](https://github.com/dtolnay/anyhow) - Error objecr for idiomatic error handling
- [base64](https://github.com/marshallpierce/rust-base64) - Base 64 encoding
- [chrono](https://github.com/chronotope/chrono) - Date + time parsing and manipulating
- [colored](https://github.com/mackwic/colored) - Handling of terminal colors
- [crossterm](https://github.com/crossterm-rs/crossterm) - Term manipulation for kb + mouse events
- [futures](https://github.com/rust-lang/futures-rs) - Extension of futures for async computation
- [reqwest](https://github.com/seanmonstar/reqwest) - HTTP client
- [serde](https://github.com/serde-rs/serde) - Decerilization of JSON responses
- [tokio](https://github.com/tokio-rs/tokio) - Improved futures
- [tui-rs](https://github.com/tui-rs-revival/ratatui) - Terminal graphing
---

## Mirror

---

## Contributing

Contributions of any kind are very welcome (and would be much appreciated!)
For Code of Conduct, see [Contributor Convent](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).
For project setup, see the [Development](#development) section.

#### New here?
To get started, fork the repo, make your changes, add, commit and push the code, then come back here to open a pull request. If you're new to GitHub or open source, [this guide](https://www.freecodecamp.org/news/how-to-make-your-first-pull-request-on-github-3#let-s-make-our-first-pull-request-) or the [git docs](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) may help you get started, but feel free to reach out if you need any support.

#### Not a coder?
You can support the project in other ways too, drop us a star, consider sponsoring us on GitHub, share within your network, and report any bugs you come across.

---

## License


> _**[obaraelijah/adguard-tui](https://github.com/obaraelijah/adguard-tui)** is licensed under [MIT](https://github.com/obaraelijah/adguard-tui/blob/HEAD/LICENSE) © [Elijah Samson](https://elijahsam.com) 2025._<br>
> <sup align="right">For information, see <a href="https://tldrlegal.com/license/mit-license">TLDR Legal > MIT</a></sup>

<details>
<summary>Expand License</summary>

```
The MIT License (MIT)
Copyright (c) Elijah Samson <elijahsam@omg.com> 

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal 
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sub-license, and/or sell 
copies of the Software, and to permit persons to whom the Software is furnished 
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included install 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT ABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

</details>

<!-- License + Copyright --

<!-- Dinosaur -->
<!-- 
                        . - ~ ~ ~ - .
      ..     _      .-~               ~-.
     //|     \ `..~                      `.
    || |      }  }              /       \  \
(\   \\ \~^..'                 |         }  \
 \`.-~  o      /       }       |        /    \
 (__          |       /        |       /      `.
  `- - ~ ~ -._|      /_ - ~ ~ ^|      /- _      `.
              |     /          |     /     ~-.     ~- _
              |_____|          |_____|         ~ - . _ _~_-_
-->
