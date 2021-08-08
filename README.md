# Project Cerulean

Just me making a video game. There isn't much to see right now, but check back later!


## Syncing assets

Assets are synced using IPFS (https://ipfs.io) to prevent having to check in large binary files into the repository.

1. Install IPFS by installing the package `go-ipfs`
2. Initialize: `ipfs init`
3. Run the IPFS daemon: `ipfs daemon`
4. Enable the `git-ipfs` filter by adding the following section to `cerulean/.git/config`:
```
[filter "git-ipfs"]
        smudge = src/tools/git-ipfs/git-ipfs.sh smudge
        clean = src/tools/git-ipfs/git-ipfs.sh clean
        required = true
```
5. Sync assets: `rm -r assets && git reset --hard`


## Godot version

```
4.0.dev.custom_build.ff52996e5
```


## License

* Source code (`src/` folder): GPLv3-or-later
* Assets (`assets/` folder): CC BY-SA 4.0


## Links

* Main repo: https://github.com/projectcerulean/cerulean
* Repo mirrors:
    * https://bitbucket.org/gullik/cerulean
    * https://git.sr.ht/~gullik/cerulean
* Build service: https://builds.sr.ht/~gullik/cerulean
