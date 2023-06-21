# fcos-ignition-config

Fedora CoreOS settings for my kubernetes nodes

[![Run butane to generate ignition file](https://github.com/juanlu-sanz/fcos-ignition-config/actions/workflows/main.yml/badge.svg)](https://github.com/juanlu-sanz/fcos-ignition-config/actions/workflows/main.yml)

## What this is for

I have a small cluster at home, and ever since I read about Red Hat CoreOS and Fedora CoreOS, the idea has intrigued me: an immutable OS that is meant as a base for containerized workloads? Sounds amazing! So I'll be adding to this repository all my progressions and goals towards making a somewhat clean and usable Fedora CoreOS setup.

> ⚠ NOTE
> These are my configs for my own servers!
> I'll try to keep everything as "boilerplate-y" as possible, and make an extra effort to mark every single config someone else might need to change for them to work, but it's up to you to do it!

## My current setup

Long story short: Fedora CoreOS uses something called an `ignition` file (.ign) to setup your PC, instead of having to set it up manually on every setup. These ignition files are glorified .json files that are generated from `butane` files (which are, in turn, glorified .yaml files)

Like so:

```mermaid
flowchart LR
    A[Butane file] -->|butane --pretty --strict| B(Ignition file)
```

This ignition file can either:

1. Be manually put into the server you want to install this to (via pendrive)
2. Be embedded onto the ISO itself
3. Be downloaded on the go from a URL

I decided to go with option number 3, so let's host it on github!

### Github workflow

Since I'm doing some testing and I need to reinstall often (until I get it just right), I wanted to automate it all so:

```mermaid
flowchart LR
    subgraph Github
        direction LR
        subgraph Repository
            A[Server butane file]
        end
        subgraph Releases
            B(Server ignition file)
        end
        A -->|GH Action: \nbutane --pretty --strict| B
    end
    subgraph Your local computer
        I[Fedora CoreOS .iso]
    end
    subgraph USB Drive
        UI[Burned .iso]
    end
    subgraph Server you want to install FCOS to
        IN[coreos-intaller]
    end
    F[Fedora servers] --> I
    I --> |Burn| UI
    UI --> IN
    B --> |Downloads at \n install time| IN
```

To install you can do either of two things:

#### The easy way: pass the URL on every installation

You simply boot your Fedora CoreOS live USB on your server, wait for it to "boot" and run

```bash
lsblk  # To make sure which drive is which on your server
sudo coreos-installer install <Drive you want to install it to> \
    --ignition-url https://yourdomain.com/yourIgnitionFile.ign
```

So, for example

```bash
sudo coreos-installer install /dev/sda \
    --ignition-url https://github.com/juanlu-sanz/fcos-ignition-config/releases/latest/download/k8s-node.ign
```

> ⚠ Don't use this exact command directly on your server! It'll install my configs!

Now if you make changes, you only need to push to git, a GH action will generate the appropiate ignition file and publish it, run the installer again and you have a brand new install!

### The automatic way: make the installer pull the config on every install

This is only if you want to reinstall often! (ignition testing for example)

You can create another, small ignition file which is embedded in the ISO before burning and makes the ISO automatically set the two properties you need (destination disk and ignition file). The diagram looks like this:

```mermaid
flowchart LR
    subgraph Github
        direction LR
        subgraph Repository
            A[Server butane file]
            AL[Live butane file for ISO]
        end
        subgraph Releases
            B(Server ignition file)
            BL(Live ignition file for ISO)
        end
        A -->|GH Action: \nbutane --pretty --strict| B
        AL -->|GH Action: \nbutane --pretty --strict| BL
    end
    subgraph Your local computer
        I[Fedora CoreOS .iso]
    end
    subgraph USB Drive
        UI[Burned .iso]
    end
    subgraph Server you want to install FCOS to
        IN[coreos-intaller]
    end
    F[Fedora servers] --> I
    I --> |Burn| UI
    UI --> IN
    B --> |Downloads at \n install time| IN
    BL --> UI
```

The graph is more complex, but it certainly makes life easier! Now instead of having to plug a keyboard on the server and type the install command, just running the ISO will reinstall Fedora CoreOS with the latest version of your ignition file!
