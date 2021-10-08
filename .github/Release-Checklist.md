## Preparing the release
- [ ] Fetch the tip of `main`:
```shell
$ git checkout main
$ git pull
```

- [ ] Create a new branch for the release:

```shell
$ git checkout -b your-name/bump-release/YYYY-MM-DD
```

- [ ] Using the workflow dispatch trigger in the browser version of Github, run the `sanity-check` github action to make sure that everything is good to go (should automatically check if the versions are correct and that the CHANGELOG is included)
   - [ ] If the pre-release sanity check fails, please fix any of the issues noted by the `sanity-check` then open a pull request to submit the modified files
   - [ ] Ask one of the administrators to review and merge the PR for you

- [ ] Trigger a release build on CI (Github Actions) and wait for the build artifacts to be published on the Github release page.

    ```shell
    $ git push origin refs/tags/vYYYY-MM-DD
    ```

  Where `YYYY-MM-DD` should be replaced by the actual date of the release

## Create the release notes

- [] Write release notes in the [release page](https://github.com/Topl/BramblDart/releases) using the CHANGELOG.md section that you have written earlier. Fill in any empty sections that you may have not filled in on the first pass. 

- [] Remove items that are irrelevant to users (e.g pure refactoring, improved test coverage, etc...)

- [] You may want to polish the language around the PR titles to make it sound like actual release notes (if you generated the CHANGELOG.md from the PR/commit titles)

## Verify release artifacts

- [ ] Run the dartdoc github action
   - [ ] Verify that the documentation has been correctly exported onto the gh-pages branch [gh-pages](https://github.com/Topl/BramblDart/tree/gh-pages)

- [ ] Update the Github wiki and make sure that it is up to date

## Publication
- [ ] Once everyone has signed off (i.e Tech Lead, Engineering Manager), publish the release draft
   - [ ] First, run the CI (Github Action) for deploy_npm
   - [ ] Next, run the CI (Github Action) for deploy_pub