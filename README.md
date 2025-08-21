# Docker Cleaner v0.7.1

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
version="0.6.0"

git switch --create release/${version}
git add Gemfile.lock README.md lib/docker_cleaner/version.rb
git commit -m "release: Bump v${version}"
git push --set-upstream origin release/${version}
gh pr create --reviewer=EtienneM --title "$(git log -1 --pretty=%B)"
```

Once the pull request merged, you can tag the new release.

```shell
git tag v${version}
git push origin master v${version}
gh release create v${version}
```

The title of the release should be the version number.
