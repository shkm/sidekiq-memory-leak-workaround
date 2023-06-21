# Sidekiq Memory Leak Workaround

This repo presents an extremely basic way to work around memory leaks happening in Sidekiq jobs: above a certain memory threshold, the sidekiq process is exited.

It demonstrates that jobs that do not finish during the grace period (the timeout option) get pushed back to redis to be picked up by another Sidekiq process.

This is only a reasonable workaround assuming the sidekiq process will be restarted in some way after it has exited, and your jobs are idempotent (they should be anyway).


## Running stuff

Three things need to be running at the same time: a redis container, sidekiq, and the job simulator. You'll probably want different terminal panes for each.

```
docker run --rm -p 6379:6379 redis # if you need it
bundle && bundle exec sidekiq --config sidekiq.yml
./simulate
```
