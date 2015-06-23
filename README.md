# TheRubyRacer vs Node.js

Some time ago [I wrote a blogpost about using Node with ExecJS](http://nerdblog.pl/post/120106238519/node-on-execjs-is-sloooooow) and my conclusion was that it's slow and should not be used. Since then, my friend [Paweł](https://twitter.com/katafrakt_pl) [has commented with completely different results](http://nerdblog.pl/post/120106238519/node-on-execjs-is-sloooooow#comment-2051243519) and it kind of blew my mind.

This app was created to test our assumptions and see if we can narrow down what exactly is happening here and why.

## How to use it

```
rake test:jsruntime TEST_MULTIPLIER=10
```

If you skip `TEST_MULTIPLIER` it will default to 1.

**WARNING** This test skips assets:precompile output completely. This is caused by the task not honoring both `-q` and `-s` options. **Make sure your assets are compiling before using.**

I could add sanity checks but it's a POC and I've already spent too much time on this.
