# Project Cerulean

Just me making a video game. There isn't much to see right now, but check back later!


## Syncing assets

Assets are synced using IPFS (https://ipfs.io) to prevent having to check in large binary files into the repository.

1. Install IPFS by installing the package `go-ipfs`
2. Initialize: `ipfs init`
3. Run the IPFS daemon: `ipfs daemon`
4. Enable the `git-ipfs` filter by adding the section following to `cerulean/.git/config`:
```
[filter "git-ipfs"]
        smudge = src/tools/git-ipfs/git-ipfs.sh smudge
        clean = src/tools/git-ipfs/git-ipfs.sh clean
        required = true
```
5. Sync assets: `rm -r assets && git reset --hard`


## Godot version

```
4.0.dev.custom_build.a2d5f191d
```
