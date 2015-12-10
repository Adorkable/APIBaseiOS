APIBase
===
[![Build Status](http://img.shields.io/travis/Adorkable/APIBaseiOS.svg?branch=master&style=flat)](https://travis-ci.org/Adorkable/APIBaseiOS)
[![codecov.io](https://img.shields.io/codecov/c/github/Adorkable/APIBaseiOS.svg)](https://codecov.io/github/Adorkable/APIBaseiOS?branch=master)
[![Pod Version](http://img.shields.io/cocoapods/v/AdorkableAPIBase.svg?style=flat)](http://cocoadocs.org/docsets/AdorkableAPIBase/)
[![Pod Platform](http://img.shields.io/cocoapods/p/AdorkableAPIBase.svg?style=flat)](http://cocoadocs.org/docsets/AdorkableAPIBase/)
[![Pod License](http://img.shields.io/cocoapods/l/AdorkableAPIBase.svg?style=flat)](http://cocoadocs.org/docsets/AdorkableAPIBase/)

**APIBase** a purdy simple base for an framework to access an API. Now with **iOS, OSX, watchos,** and **tvos** support!

It features two protocols: `API` and `Route`.

### `API` 

* defines overall settings and work for communicating with your API 
* usually is made to provide access to individual routes
* can be used statically or by creating an instance of the object that conforms to it

### `Route`

* defines a worker for accessing a single route of your API
* must be instantiated, usually created and managed by an `API` object to simplify the interface for consumers of your API accessing library
* includes a number of default implementations for accessing basic and JSON routes

Additionally `RouteBase` is a useful base class that includes common route functionality.


Example
---
Until this README is updated please see [BingAPIiOS](https://github.com/Adorkable/BingAPIiOS)


Contributing
---
If you have any ideas, suggestions or bugs to report please [create an issue](https://github.com/Adorkable/APIBaseiOS/issues/new) labeled *feature* or *bug* (check to see if the issue exists first please!). Or suggest a pull request!
