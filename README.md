# FIDL C++ SDK Tests

Build tests for the FIDL C++ bindings against an SDK with various build flags.

## Building

This is built around a GNU `Makefile` that uses a Fuchsia SDK to build some
googletest based tests. The `Makefile` has a concept of a `CONFIG` which is
currently either `cpp14` or `cpp17`. The build can be invoked by specifying a
config like:
```sh
make CONFIG=cpp17
```
or if none is specified then both `cpp14` and `cpp17`.

## SDKs

This needs a Fuchsia SDK whose location is specified by passing `SDK=path` to
the `make` invocation or putting a Fuchsia SDK into the default location: `sdk/`

This can either be a Fuchsia SDK downloaded from:
https://fuchsia.dev/fuchsia-src/development/idk/download
or one linked from a local build.

### Linking SDKs

There's a script `link-sdk.py` that takes the path to a Fuchsia tree and a
destination directory (eg: `sdk`). The Fuchsia tree must be built with
`build_sdk_archives = true`. The `link-sdk.py` script will create symbolic
links from the directory structure of an SDK into the Fuchsia source tree and
build directory. This is useful when iterating on the SDK.


## Future work

- Add many more tests
- Support LLCPP tests
- Run tests
- Make this work on not-Linux
- Better dependency tracking