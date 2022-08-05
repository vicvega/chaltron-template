# Chaltron-template
At the beginning [`chaltron`](https://github.com/vicvega/chaltron) was a `rails` engine.

Now `chaltron` is a `rails` template including `bootstrap` and `esbuild`, working with `rails6` and `rails7`.

For older rails version consider updating, otherwise use [the old gem](https://github.com/vicvega/chaltron).

To create a new app (`rails7`)

```
rails new myapp -m https://raw.githubusercontent.com/vicvega/chaltron-template/master/template.rb -j esbuild -c bootstrap
```

With `rails6`: 
```
rails new myapp -m https://raw.githubusercontent.com/vicvega/chaltron-template/master/template.rb --skip-javascript
```

Enjoy! 🍺🍺
