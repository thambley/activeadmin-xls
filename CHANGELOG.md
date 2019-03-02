# Changelog

## [Unreleased]

## 2.0.1

### Fixed

* fix issue with xls_builder retaining data between requests when there is an exception on a computed field [#13][]

## 2.0.0

### Changed

* Drop support for ruby 1.9, rails 3.2, and ActiveAdmin 0.6.6.
* Add support for rails 5.1 [#8][]

## 1.1.0

### Added

* Add only_columns [#7][]

### Fixed

* Fix typo in README.md [#11][] by [@cpunion][]

### Changed

* Update tests for ActiveAdmin 1.2

## 1.0.5

### Fixed

* Fix #1 - Unnecessary database access
* Fix broken tests

## 1.0.4

### Fixed

* Minor bug fixes / typo corrections

## 1.0.3

### Fixed

* Move require rake from gemspec to lib/activeadmin-xls.rb [#4][] by [@ejaypcanaria][]

## 1.0.2

### Fixed

* Fixes undefined local variable or `method max_per_page` [#3][] by [@rewritten][]

<!--- Link List --->
[#3]: https://github.com/thambley/activeadmin-xls/issues/3
[#4]: https://github.com/thambley/activeadmin-xls/pull/4
[#7]: https://github.com/thambley/activeadmin-xls/issues/7
[#8]: https://github.com/thambley/activeadmin-xls/issues/8
[#11]: https://github.com/thambley/activeadmin-xls/pull/11
[#13]: https://github.com/thambley/activeadmin-xls/issues/13

[@rewritten]: https://github.com/rewritten
[@ejaypcanaria]: https://github.com/ejaypcanaria
[@cpunion]: https://github.com/cpunion