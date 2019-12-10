# comment-when-approved-action

This github action posts a comment to pull requests when they get approved. Inspired by [pullreminders/label-when-approved-action](https://github.com/pullreminders/label-when-approved-action).

## Usage
Create a new yaml file like the following script and add it to your `.github/workflow`.

```yaml
on: pull_request_review
name: Comment on approved pull requests
jobs:
  commentWhenApproved:
    name: Comment when approved
    runs-on: ubuntu-latest
    steps:
    - name: Comment when approved
      uses: basisai/comment-when-approved-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        COMMENT: "Awesome!"
        REACTION: "heart"
        TRIGGER_LABELS: "some label"
```

Environment Variables:
- `COMMENT`: Required. The content of the comment
- `REACTION`: Optional. The [github reaction](https://developer.github.com/v3/reactions/#reaction-types) to be added to the comment
- `TRIGGER_LABELS`: Optional. Only pull requests with these labels will trigger this action. Labels should be separated by a comma.

## Demo
<img src="https://github.com/basisai/comment-when-approved-action/raw/master/asset/example.png" width="540">
