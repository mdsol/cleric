# Cleric

Administration tools for the lazy software development manager.

Cleric automates the boring jobs a manager has to do when administrating
accounts on GitHub, HipChat and other services used by teams. It provides
commands such as:

* Add a GitHub user to a team
* Remove a GitHub user from an organization
* Create a GitHub repo, assign it to a team and hook up repo notifications to
  HipChat *all at once*
* Audit a local repo to ensure all commits are covered by pull requests

For any successful action, a configured HipChat room is notified, allowing other
managers to see what's going on in your organization.

Cleric is intended to be extensible, so it should ultimately be possible to plug
in other repo and chat services (assuming they have an adequate API) and provide
other management notification mechanisms beyond HipChat.

While Cleric currently provides a command line interface, the design is intended
to be reusable with other interfaces, e.g. a web UI.

## Install

Cleric is available as a gem through GitHub, hence you'll need to add it to the
`Gemfile` of an existing project or create a stub `Gemfile` to use it in
isolation. Add the following line:

```ruby
gem 'cleric', git: 'git@github.com:mdsol/cleric.git'
```

Then run:

```
bundle install
```

This assumes you have Ruby (1.9+) and the bundler gem installed already!

To use the Cleric from the command line, run this command in the top directory
for help:

```
[bundle exec] cleric help
```

## Configure

Cleric is configured using the `.clericrc` YAML file in your home directory.

### Management notifications

Management notification to a HipChat room is (currently) mandatory and requires
the following settings in `.clericrc`:

```yaml
hipchat:
  api_token: 1234567890abcdef1234567890abcd
  announcement_room_id: 1234
```

The `api_token` value should be an **Admin** token, to allow future commands to
perform actions such as adding accounts. As the HipChat API does not provide a
way to generate tokens, you will have to do this manually (once) through the
"Group admin" web UI.

The `announcement_room_id` is the management notification chat room's id. In
HipChat's chat web UI, this can be discovered by looking at the URL in the chat
history page. In future, Cleric should allow room names to be used or provide a
command to look up the id. Using an id *does* have the advantage of be resilient
to the chat room being renamed.

### GitHub authentication

By default, Cleric will prompt for your GitHub login and password on each
invocation. You can avoid this be running the following command:

```
[bundle exec] cleric auth
```

You will be prompted for your login and password one last time but then an API
token will be generated and stored in `.clericrc`.

Guard this token like you would a password! It allows the possessor full access
to every public and private repo your account has access to! The advantage API
tokens have over passwords is that they do not allow your account to be modified
and can be revoked individually from GitHub's account management UI; Cleric's
token will be named "Cleric (API)".

If you are uncomfortable with this level of risk, you can still enter your login
and password with each invocation, which is the default behavior.

### GitHub repo notifications to HipChat

The `repo create` command allows a new GitHub repo to (optionally) post
notifications to a HipChat room. Rather than configure GitHub with the
admin-level token used by Cleric itself, a separate **Notification** token
should be used and configured in `.clericrc` as follows:

```yaml
hipchat:
  api_token: 1234567890abcdef1234567890abcd
  announcement_room_id: 1234
  repo_api_token: abcdef1234567890abcdef12345678
```

## Contributors

* [Andrew Smith](https://github.com/asmith-mdsol)
* [Geoff Low](https://github.com/glow-mdsol)
* [Harry Wilkinson](https://github.com/harryw)

