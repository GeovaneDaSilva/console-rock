# Product History

This document covers the historical context of RocketCyber from a product perspective. To understand where
you are, it is helpful to know where the product has been. Come child, sit down and enjoy The Tale of RocketCyber (Ch 1-3.4).

## In the Beginning (Jan 2017), there was OVAL

The original premise of RC was built around the idea of evaluation of CIS [provided](https://oval.cisecurity.org/repository/download)
OVAL, which was [converted](https://github.com/rocketcyber/oval2lua) into Lua, served to devices, evaluated, and the reported upon. Customers
were billed per device automatically monitored for security vulnerabilities identified by the OVAL evaluation.

This included tools like [proxy](https://github.com/rocketcyber/proxy), a nodejs HTTP proxy for exposing a single endpoint in a secure network
to proxy traffic, and [surveyor](https://github.com/rocketcyber/surveyor), an electron.js desktop application for managing evaluations.

The product has since pivoted. None of these components are actively used within the application, however, you may find legacy code scattered
around the code base which references these tools. Kill it with fire 🔥 if found.

## Then there was Threat Hunting

[Threat Hunting](https://en.wikipedia.org/wiki/Cyber_threat_hunting), in the context of RC, is the process of searching a `Group` of connected devices
for given matching characteristics. In English, "Show me all the systems that have a file notepad.exe, a browser visit to
http://verybad.com/notepad.exe, and a System Event Log of 1234". Hunts support iterative edits, so one could (theoretically) run a hunt, find devices,
then edit it to narrow down the results by adding/removing/modifying hunt test conditions. Thusly, a given hunt has N revisions, with N results per device.

Threat Hunting still exists in RC.

Expanding on Threat Hunting, is the concept of Threat Intel Feeds (Hunt Feeds in the code base). After finding that Threat Hunting itself is
good and great, we found that customers didn't really have the chops to know how to leverage it/what to hunt for. So we built Hunt Feeds, the
ability to take published "known bad" criteria (file hashes, IPs, URLs, etc) from external sources and automatically convert that data into
hunts. Overnight, hunts went from a deliberate and methodical process driven by human interaction to a steady (and sometimes overwhelming)
flow of constant checks. There are currently two Threat Intel Feed sources in use, AlienVault OTX, and our internal System Hunts. Others have
existed (VirusTotal, Cymon, ReversingLabs) but are not in use -- mostly for business reasons.

## Then there was Continuous Threat Hunting

Pivoting again, the demand for always-on style threat hunting was realized. Point-in-time evaluations are quick, but have limited value on
changing systems. So, instead of looking for a file with a given name once, we wanted to check for a file with a given name and then continuously
monitor all new files for that name. This concept would eventually transform into Apps, but we would bastardize Hunts first to achieve this. Hunts,
instead of being run once and supplying a result once per revision per device, that result may be overridden in the future. They become very complex.

Continuous hunts are no longer in use, but a lot of the code and UI around them still exist.

## Then there were RocketApps™️ and the RocketApp Store™️

Apps are simplified Continuous Threat Hunts. Minimal configuration and potentially 0 customer inputs, these chunks of Lua code run on endpoint devices,
carrying out their tasks in perpetuity. An example of this might be monitoring files on disk to see if they're known to be bad, or looking for network
connections to foreign countries.

Eventually Apps evolved to exclude endpoint devices in the form of Cloud Apps.

Apps are the core of RocketCyber at the time of this writing.
