# Project Cerulean

![](https://raw.githubusercontent.com/projectcerulean/cerulean-img/master/img/screenshots/2022/test_scene.jpg)

Just me making a video game.


## Running prebuilt version

1. Download the Godot game engine, version 4.0 beta 3: https://godotengine.org/article/dev-snapshot-godot-4-0-beta-3
2. Grab the latest Cerulean PCK file from the build service: https://builds.sr.ht/~gullik/cerulean
3. Place the Cerulean PCK and the Godot executable in the same directory
4. Rename the Godot executable to 'cerulean' and run it

## Input map

Using a gamepad is highly recommended.

| Input                    | Gamepad                                     | Keyboard + mouse     |
| ------------------------ | ------------------------------------------- | -------------------- |
| Move                     | Left stick                                  | WASD                 |
| Jump/Glide/Swim upwards  | Left bumper                                 | Space                |
| Air-brake/Swim downwards | Right bumper                                | Ctrl                 |
| Interact                 | A                                           | E                    |
| Rotate camera            | Right stick                                 | Move mouse           |
| Zoom camera in/out       | Press left stick + move right stick up/down | Scroll wheel up/down |
| Pause menu               | Start                                       | Escape               |
| Performance statistics   | Select                                      | F12                  |

![](https://raw.githubusercontent.com/projectcerulean/cerulean-img/master/img/screenshots/2022/test_dungeon_bounce.jpg)


## Development

Clone the repository.

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

![](https://raw.githubusercontent.com/projectcerulean/cerulean-img/master/img/screenshots/2022/test_dungeon_button.jpg)


## License

* Source code (`src/` folder): GPLv3-or-later
* Assets (`assets/` folder): CC BY-SA 4.0

Some files are available under other (compatible) licenses. This is indicated by their license files and/or license headers.


## Links

* Main repo: https://github.com/projectcerulean/cerulean
* Repo mirrors:
    * https://bitbucket.org/gullik/cerulean
    * https://git.sr.ht/~gullik/cerulean
* Build service: https://builds.sr.ht/~gullik/cerulean
