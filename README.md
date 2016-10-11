# VascTrac

Notes
===========

The *ResearchKit™ framework* doesn't have a working podspec (the one commited is not working) and has some difficulties with it, please see https://github.com/ResearchKit/ResearchKit/issues/642 .
Therefore please follow the guide below to clone and link ResearchKit with Vasctrac.


Installation
------------

The latest stable version of *ResearchKit framework* can be cloned with

```
git clone -b stable https://github.com/ResearchKit/ResearchKit.git
```


Building
--------

Build the *ResearchKit framework* by opening `ResearchKit.xcodeproj` and running the `ResearchKit`
framework target. Optionally, run the unit tests too.


Adding the ResearchKit framework to your App
------------------------------

This walk-through shows how to embed the *ResearchKit framework* in your app as a dynamic framework,
and present a simple task view controller.

### 1. Add the ResearchKit framework to Your Project

To get started, drag `ResearchKit.xcodeproj` from your checkout into your *iOS* app project
in *Xcode*:


<center>
<figure>
<img src="https://github.com/ResearchKit/ResearchKit/wiki/AddingResearchKitXcode.png" alt="Adding the ResearchKit framework to your
project" align="middle"/>
</figure>
</center>

Then, embed the *ResearchKit framework* as a dynamic framework in your app, by adding it to the
*Embedded Binaries* section of the *General* pane for your target as shown in the figure below.

<center>
<figure>
<img src="https://github.com/ResearchKit/ResearchKit/wiki/AddedBinaries.png" width="100%" alt="Adding the ResearchKit framework to
Embedded Binaries" align="middle"/>
<figcaption><center>Adding the ResearchKit framework to Embedded Binaries</center></figcaption>
</figure>
</center>
