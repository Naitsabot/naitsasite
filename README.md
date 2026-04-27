# naitsasite
Naitsa homepage

## Building and running

```bash
nimble install
```

```bash
nimble run
```

Runs on:
```
http://localhost:8080/
http://localhost:8080/blog
http://localhost:8080/blog/hello-there
```

## Static Target

```bash
nim c -d:static -r src/app.nim
```

Run static server (locally):
```bash
cd dist && python -m http.server 8080
# remember to leace dist/ again
```

## Requires
- nim
- imagemagick