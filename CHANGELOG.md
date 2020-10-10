# Changelog

## v2.0.0

### Breaking changes

* Rename `:datetime` to `:published_at`.
* `Nabo.Repo.get/1` returning.

### Improvements

* Fix a compilation bug.

## v1.0.1

* Mark post paths as `@external_resource` for better recompilation.

## v1.0.0

* Introduce new parser `Nabo.Parser.Front`.
* Replace `poison` with `jason`.
* Make `jason` and `earmark` optional dependencies.
* Log compile errors.

**Brearking changes:**

Version 1.0 has **many breaking changes** to prior versions.

* Removed `Nabo.Compilers.Markdown` in favor of `Nabo.Parser.Markdown`.
* Changed many `Nabo.Repo` options. See [documentation](http://hexdocs.pm/nabo) for the module for more information.
  * `:compiler` option no longer supports `{compiler, options}` format, it now
    has four sub-options: `:log_level`, `:body_parser`, `:front_parser`,
    `:excerpt_parser`.
