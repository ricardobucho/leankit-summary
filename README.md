# LeanKit Summary

Generate summary reports for LeanKit boards.

![Preview](https://github.com/ricardobucho/leankit-summary/blob/main/html-report-preview.png?raw=true)

## Requirements

* Ruby 2.6.6 (working on 3.0.1, untested with other versions)

## Setup

* Clone this repo somewhere
* `cd` into it and run `bundle` to install all dependencies
* Duplicate `.env.example` to `.env` and fill in your info

## Environment Configuration

* `LK_API_BASE_URL`: The base URL for a LeanKit account
* `LK_API_TOKEN`: A LeanKit API token (see below how to get one)
* `LK_BOARD_ID`: The id of the board intended for the reports
* `LK_LANES`: The lanes of the board intended for the reports split by `;`
* `GH_API_BASE_URL`: The base URL for the GitHub API
* `GH_PERSONAL_TOKEN`: A GitHub Personal Token (see below how to get one)
* `GH_REPOSITORY`: The repository where to search for pull requests in the `owner/repo` format
* `INCLUDE_TASK_CARDS`: If the report should include task cards data
* `INCLUDE_PULL_REQUESTS`: If the report should include pull request data

## Generating a LeanKit API Token

1. After entering your LeanKit account click on your avatar and select `API Tokens`.
2. On the modal that popped up click `Create Token` and give it a name.
3. Afterwards copy the generated token to the `LK_API_TOKEN` env.

## Generating a GitHub Personal Token

1. After logging in to GitHub go to `Seetings`.
2. Then head to `Developer Settings` and `Personal Access Tokens`.
3. Generate a token with full `repo` access and give it a name and expiration as you see fit.
4. Copy the generated token into the `GH_PERSONAL_TOKEN` env.

## Picking the Board Lanes

To fill in `LK_LANES` you can either use the id or name of the lane.
If there are multilple lanes with the same name they will all be included.
In such cases you might need to use the id instead.
Running `ruby ./app/lanes.rb` will show you the list of lanes for the board.
From there, pick the ones you need and add them to the environment variable.

## Generating the Reports

Running `ruby ./app/report.rb` will generate a json and an html report that will be saved in the `reports` directory.
The HTML version will be launched automatically in your browser once it's ready.

## Execution Shortcuts

Alternatively, you can use the included `bin/*` files to run a command directly without prepending `ruby` to it.

1. First allow them to be executed with `$ chmod +x ./bin/*`
2. Then simply execute them as `$ ./bin/{name}`

When executing from either `apps/*` or `bin/*` make sure you're on the parent directory, otherwise execution fails.

## Alias

```bash
# LeanKit Summary
alias lk_report="(cd ~/.../leankit-summary && ./bin/report)"
alias lk_lanes="(cd ~/.../leankit-summary && ./bin/lanes)"
```
