# subreddit-automod-rules

generate reddit automod rules from a structured YAML definition. this repo is
intended to be a general-purpose generator, so each subreddit can provide its
own input rule file.

## usage

generate the default output file from an example:

```bash
scripts/generate-automoderator-rules.sh examples/basic-rules.yaml
```

generate rules from a subreddit-specific input file:

```bash
scripts/generate-automoderator-rules.sh \
    path/to/your-automoderator-rules.yaml
```

the generated file is written to:

```text
dist/automoderator-rules.yaml
```

the command always prints the final generated path. if that path already
exists, the filename is incremented, for example
`dist/automoderator-rules-1.yaml`.

use a custom output directory:

```bash
scripts/generate-automoderator-rules.sh \
    examples/basic-rules.yaml \
    --output-dir generated
```

this writes `generated/automoderator-rules.yaml`, or an incremented filename
if that file already exists.

use an explicit output path. existing files are never overwritten; the path
is incremented when necessary:

```bash
scripts/generate-automoderator-rules.sh \
    examples/basic-rules.yaml \
    /tmp/automoderator-rules.yaml
```

the generator refuses to use the repository's `automoderator-rules.yaml` as
its output path as a safety policy.

## input format

input files define global values and ordered rules:

```yaml
globals:
  moderators_exempt: false
rules:
  - type: submission
    title (regex): '^test$'
    action: filter
    action_reason: "Test title"
```

check `examples/basic-rules.yaml` and `examples/minimal-rules.yaml` for
complete examples.
