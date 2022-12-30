# Docker Cleaner v0.6.0

Small ruby script to remove old containers and old images.

For containers, this removes containers that have been stopped for more than 2 hours.
For images, this removes unused and untagged images.

## Release a New Version

Bump new version number in:
- README.md
- lib/docker_cleaner/version.rb
- Gemfile.lock (docker-cleaner specs entry)

Commit, tag and create a new release:
```shell
git add README.md lib/docker_cleaner/version.rb
git commit -m "release: Bump v0.6.0"
git tag v0.6.0
git push origin master v0.6.0
hub release create v0.6.0
```

The title of the release should be the version number.
